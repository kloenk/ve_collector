defmodule VeCollector.VE.ClearText do
  use GenServer
  alias VeCollector.VE.ClearText.Store

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :ve_collector_cleartext)
  end

  def start_link(_arg) do
    # FIXME: arguments?
    start_link()
  end

  def init(state) do
    {:ok, state}
  end

  def parse(line, name) do
    GenServer.call(:ve_collector_cleartext, {:parse, line, name})
  end

  defp parse_checksum(state, name) do
    # IO.puts("unimplemented, parse: #{inspect(state)}")
    Store.parse(state, name)

    []
  end

  # callbacks
  def handle_call({:parse, line, name}, _from, state) do
    cond do
      String.starts_with?(line, ":") -> {:reply, {:error, :hex_command}, state}
      String.starts_with?(line, "Checksum") -> {:reply, {:ok}, Map.put(state, name, parse_checksum(Map.get(state, name, []) ++ [line], name))}
      true -> {:reply, {:ok}, Map.put(state, name, Map.get(state, name, []) ++ [line])}
    end
  end
end
