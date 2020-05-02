defmodule VeCollector.VE.Message do
  require Logger

  # TODO: extra Option (flags)
  def build_message({:get, register}) do
    register = build_list(register)
    checksum = build_checksum([7] ++ register)
    ":7#{encode(register)}00#{encode(checksum, 1)}"
    # [7] ++ register ++ [checksum]
  end

  defp build_list(n) when is_number(n) do
    n
    |> :binary.encode_unsigned()
    |> :binary.bin_to_list()
  end

  def check(list) when is_list(list) do
    do_check(list) == 0x55
  end

  defp do_check([head | tail]) do
    <<head + do_check(tail)>>
    |> :binary.decode_unsigned()
  end

  defp do_check([]) do
    0
  end

  @doc """
    build the checksum to append to an querry
  """
  def build_checksum(value)

  def build_checksum(value) when is_integer(value) do
    build_checksum([value])
  end

  def build_checksum(list) when is_list(list) do
    <<0xFF - do_build_checksum(list)>>
    |> :binary.decode_unsigned()
  end

  defp do_build_checksum([head | tail]) do
    v = <<head + do_build_checksum(tail)>>
    :binary.decode_unsigned(v)
  end

  defp do_build_checksum([]) do
    170
  end

  @doc """
   encode a number into the hex value for the ve protocoll (little endian)
  """
  def encode(msg, size \\ 2)

  def encode(msg, size) when is_integer(msg) do
    msg
    |> :binary.encode_unsigned(:big)
    |> :binary.bin_to_list()
    |> encode(size)
  end

  def encode(msg, size) when is_list(msg) do
    cond do
      length(msg) > size -> {:error, :msg_to_big}
      length(msg) < size -> encode([0] ++ msg, size)
      true -> msg |> :binary.list_to_bin() |> encode(size)
    end
  end

  def encode(msg, size) when is_binary(msg) do
    msg
    |> :binary.decode_unsigned(:little)
    |> :binary.encode_unsigned(:big)
    |> Base.encode16()
  end

  def decode(msg) when is_binary(msg) do
    res = Base.decode16(msg, case: :mixed)

    case res do
      :error -> {:error, :hex_decode}
      {:ok, v} -> decode_bitstring(v)
    end
  end

  def decode_bitstring(msg) do
    msg =
      msg
      |> :binary.decode_unsigned(:little)

    {:ok, msg}
  end
end
