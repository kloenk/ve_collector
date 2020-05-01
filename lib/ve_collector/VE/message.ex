defmodule VeCollector.VE.Message do
  @check_constant 0x55
  require Logger


  def build_checksum(list) do
    <<0xff - do_build_checksum(list)>>
    |> :binary.decode_unsigned 
  end

  defp do_build_checksum([head | tail]) do
    Logger.debug(Integer.to_string(head))
    v = <<head + do_build_checksum(tail)>>
    Logger.debug("decode #{inspect(v)}")
    :binary.decode_unsigned v
    #head = head - build_checksum(tail, checksum)
    #head = flip_num head
    #Logger.debug(Integer.to_string(head))
    #head
  end

  defp do_build_checksum([]) do
    170
  end

  defp flip_num v do
    v = if v < 0, do: v + 0xff, else: v
    v = if v > 255, do: v - 0xff, else: v
    v
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
    Logger.debug(inspect(msg))
    msg
    |> :binary.decode_unsigned(:little)
    |> :binary.encode_unsigned(:big)
    |> Base.encode16()
  end


  def decode(msg) when is_binary(msg) do
    res = Base.decode16(msg, case: :mixed)

    case res do
      :error -> {:error, :hex_decode}
      {:ok, v} -> decode_bitstring v
    end
  end

  def decode_bitstring msg do
  msg = msg
    |> :binary.decode_unsigned(:little)

  {:ok, msg}
  end
end
