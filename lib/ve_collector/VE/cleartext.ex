defmodule VeCollector.VE.ClearText do
  use GenServer
  alias VeCollector.VE.ClearText.Store

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :ve_collector_cleartext)
  end

  def start_link(_arg) do
    # FIXME: arguments?
    start_link()
  end

  def init(_) do
    {:ok, []}
  end

  def parse(line) do
    GenServer.call(:ve_collector_cleartext, {:parse, line})
  end

  defp parse_checksum(state) do
    # IO.puts("unimplemented, parse: #{inspect(state)}")
    Store.parse(state)

    []
  end

  # callbacks
  def handle_call({:parse, line}, _from, state) do
    cond do
      String.starts_with?(line, ":") -> {:reply, {:error, :hex_command}, state}
      String.starts_with?(line, "Checksum") -> {:reply, {:ok}, parse_checksum(state ++ [line])}
      true -> {:reply, {:ok}, state ++ [line]}
    end
  end
end
