Code.require_file "test_helper.exs", __DIR__

defmodule Pi do
  import Exredis

  # set/get
  def get, do: start_link() |> elem(1) |> query(["GET", "Pi"])
  def set, do: start_link() |> elem(1) |> query(["SET", "Pi", "3.14"])
end

defmodule ExredisTest do
  use ExUnit.Case, async: true
  alias Exredis, as: E

  setup do
    {:ok, client} = E.start_link

    # clean up database and set test value
    client |> E.query(["FLUSHALL"])
    client |> E.query(["SET", "key", "value"])

    { :ok, [c: client] }
  end

  test "mixin Pi.get", ctx do
    ctx[:c] |> E.query(["SET", "Pi", "3.14"])

    assert Pi.get == "3.14"
  end

  test "mixin Pi.set", ctx do
    Pi.set

    assert (ctx[:c] |> E.query(["GET", "Pi"])) == "3.14"
  end

  test "connect" do
    assert E.start_link |> elem(1) |> is_pid
  end

  test "connect, erlang way" do
    {:ok, pid} = E.start_link

    assert pid |> is_pid
  end

  test "connect using connection string" do
    assert E.start_using_connection_string("redis://127.0.0.1:6379") |> is_pid
  end

  test "disconnect" do
    assert (E.start_link |> elem(1) |> E.stop) == :ok
  end

  test "set returns OK", ctx do
    assert (ctx[:c] |> E.query(["SET", "foo", "bar"])) == "OK"
  end

  test "set works", ctx do
    ctx[:c] |> E.query(["SET", "foo", "bar"])

    assert (ctx[:c] |> E.query(["GET", "foo"])) == "bar"
  end

  test "get", ctx do
    assert (ctx[:c] |> E.query(["GET", "key"])) == "value"
  end

  test "mset returns OK", ctx do
    values = ["key1", "value1", "key2", "value2"]

    assert (ctx[:c] |> E.query(["MSET" | values])) == "OK"
  end

  test "mset works", ctx do
    ctx[:c] |> E.query(["MSET" | ["key1", "value1", "key2", "value2"]])

    values = ctx[:c] |> E.query(["MGET" | ["key1", "key2"]])

    assert values == ["value1", "value2"]
  end

  test "transactions" do
    {:ok, client} = E.start_link

    status = E.query(client, ["MULTI"])
    assert status == "OK"

    status = E.query(client, ["SET", "foo", "bar"])
    assert status == "QUEUED"

    status = E.query(client, ["SET", "bar", "baz"])
    assert status == "QUEUED"

    status = E.query(client, ["EXEC"])
    assert status == ["OK", "OK"]

    values = E.query(client, ["MGET" | ["foo", "bar"]])
    assert values == ["bar", "baz"]
  end

  test "pipelining" do
    query  = [["SET", :a, "1"], ["LPUSH", :b, "3"], ["LPUSH", :b, "2"]]
    {:ok, client} = E.start_link

    status = E.query_pipe(client, query)
    assert status == ["OK", "1", "2"]
  end

  test "pipelining with explicit timeout" do
    query  = [["SET", :a, "1"], ["LPUSH", :b, "3"], ["LPUSH", :b, "2"]]
    {:ok, client} = E.start_link

    status = E.query_pipe(client, query, 10)
    assert status == ["OK", "1", "2"]
  end

  test "explicit timeout", ctx do
    {reason, _} = catch_exit(ctx[:c] |> E.query(["INFO"], 0))
    assert reason == :timeout
  end
end
