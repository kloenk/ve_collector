defmodule VeCollector.VE.MessageTest do
  use ExUnit.Case
  alias VeCollector.VE.Message
  doctest VeCollector.VE.Message

  describe "checksum" do
    test "invalid checksum" do
      message = [0x7, 0xf, 0xff]
      assert not Message.check message
    end
    test "valid checksum" do
      message = [0x7, 0xf0, 0xed, 0x0, 0x96, 0x0, 0xdb]
      assert Message.check message
    end
    test "generate_and_check" do
      message = [0x7, 0xf0, 0xed, 0x50]
      message = message ++ [Message.build_checksum message]

      assert Message.check message
    end
  end

  describe "de/encoding" do
    test "decode" do
      {:ok, 150} = Message.decode("9600")
    end

    test "encode (size 2)" do
      assert Message.encode(150) == "9600"
    end
    test "encode (size 4)" do
      assert Message.encode(150, 3) == "960000"
    end
  end
end
