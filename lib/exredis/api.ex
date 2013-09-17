defmodule Exredis.Api do
  @moduledoc """
  High-level API
  """

  import Exredis, only: [query: 2]

  defmacro __using__(_opts) do
    quote do
      import Exredis.Api
    end
  end

  @type c  :: pid
  @type k  :: binary
  @type kl :: k | list
  @type kv :: list
  @type v  :: binary | list | :undefined

  @type sts_reply :: :ok
  @type int_reply :: integer
  @type blk_reply :: list
  @type str_reply :: binary | :undefined
  @type err_reply :: binary

  ##
  # Keys
  ##

  @spec del(c, k) :: int_reply
  def del(c, k), do:
    c |> query(["DEL", k]) |> int_reply

  @spec keys(c, kl) :: blk_reply
  def keys(c, kl), do:
    c |> query(["KEYS", kl])

  @spec pexpire(c, k, v) :: int_reply
  def pexpire(c, k, v), do:
    c |> query(["PEXPIRE", k, v]) |> int_reply

  @spec renamenx(c, k, k) :: int_reply
  def renamenx(c, k, nk), do:
    c |> query(["RENAMENX", k, nk]) |> int_reply

  @spec dump(c, k) :: blk_reply
  def dump(c, k), do:
    c |> query(["DUMP", k])

  # TODO
  # def migrate do: :undefined

  @spec pexpireat(c, k, v) :: int_reply
  def pexpireat(c, k, v), do:
    c |> query(["PEXPIREAT", k, v]) |> int_reply

  # TODO
  # def restore do: :undefined

  @spec exists(c, k) :: int_reply
  def exists(c, k), do:
    c |> query(["EXISTS", k]) |> int_reply

  # TODO
  # def move do: :undefined

  @spec pttl(c, k) :: int_reply
  def pttl(c, k), do:
    c |> query(["PTTL", k]) |> int_reply

  # TODO
  # def sort do: :undefined

  @spec expire(c, k, v) :: int_reply
  def expire(c, k, v), do:
    c |> query(["EXPIRE", k, v]) |> int_reply

  # TODO
  # def object do: :undefined

  @spec randomkey(c) :: blk_reply
  def randomkey(c), do:
    c |> query(["RANDOMKEY"])

  @spec ttl(c, k) :: int_reply
  def ttl(c, k), do:
    c |> query(["TTL", k]) |> int_reply

  @spec expireat(c, k, v) :: int_reply
  def expireat(c, k, v), do:
    c |> query(["EXPIREAT", k, v]) |> int_reply

  @spec persist(c, k) :: int_reply
  def persist(c, k), do:
    c |> query(["PERSIST", k]) |> int_reply

  @spec rename(c, k, k) :: sts_reply
  def rename(c, k, nk), do:
    c |> query(["RENAME", k, nk]) |> sts_reply

  @spec type(c, k) :: str_reply
  def type(c, k), do:
    c |> query(["TYPE", k])

  ##
  # Strings
  ##

  @spec append(c, k, v) :: int_reply
  def append(c, k, v), do:
    c |> query(["APPEND", k, v]) |> int_reply

  @spec bitcount(c, k) :: int_reply
  def bitcount(c, k), do:
    c |> query(["BITCOUNT", k]) |> int_reply

  @spec bitcount(c, k, v, v) :: int_reply
  def bitcount(c, k, v, v), do:
    c |> query(["BITCOUNT", k, v, v]) |> int_reply

  # bitop
  
  @spec decr(c, k) :: int_reply
  def decr(c, k), do:
    c |> query(["DECR", k]) |> int_reply

  # decrby

  @spec get(c, k) :: str_reply
  def get(c, k), do:
    c |> query(["GET", k])

  # getbit
  # getrange
  # getset
  # incr
  # incrby
  # incrbyfloat

  @spec mget(c, kv) :: blk_reply
  def mget(c, kv), do:
    c |> query(["MGET" | kv])
    
  @spec mset(c, kv) :: sts_reply
  def mset(c, kv), do:
    c |> query(["MSET" | kv]) |> sts_reply

  # msetnx
  # psetex

  @spec set(c, k, v) :: sts_reply
  def set(c, k, v), do:
    c |> query(["SET", k, v]) |> sts_reply

  # setbit
  # setex
  # setnx
  # setrange
  # strlen

  ##
  # Pub/Sub
  ##

  @spec publish(c, k, v) :: int_reply
  def publish(c, ch, msg), do:
    c |> query(["PUBLISH", ch, msg]) |> int_reply

  ##
  # Server
  ##

  @spec flushall(c) :: sts_reply
  def flushall(c), do:
    c |> query(["FLUSHALL"]) |> sts_reply

  ##
  # Reply parsers
  ##

  defp int_reply(reply), do:
    reply |> binary_to_integer

  defp sts_reply("OK"), do:
    :ok

  defp sts_reply(reply), do:
    reply

end
