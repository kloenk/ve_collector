defmodule VeCollector.Serial.Discover do
  alias VeCollector.Serial.Store
  alias VeCollector.Serial

  def start_link(_opts \\ []) do
    pid =
      spawn_link(fn ->
        run(true)
      end)

    {:ok, pid}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def run(forever \\ false) do
    devices =
      Circuits.UART.enumerate()
      |> Map.to_list()
      |> Stream.map(&get_name(&1))
      |> Enum.into([])

    start_device(devices)

    if forever do
      :timer.sleep(5000)
      run(forever)
    end
  end

  defp start_device([name | tail]) do
    start_device(name)
    start_device(tail)
  end

  defp start_device([]) do
  end

  defp start_device(name) when is_binary(name) do
    Store.reset()

    # {pid, _online} = if {pid, online} = Store.get(name), do: {pid, online}, else: do_start_device name
    if Store.get(name) == nil do
      do_start_device(name)
    end
  end

  defp do_start_device(name) do
    {:ok, pid} = DynamicSupervisor.start_child(VeCollector.SerialSupervisor, VeCollector.Serial)
    Serial.open(pid, name)
    Store.put(name, pid)
    {pid, false}
  end

  defp get_name({name, _v}) do
    name
  end
end

# defmodule VeCollector.Serial.Discover do
#  use GenServer
#  require Logger
#
#  def start_link(_ \\ []) do
#    GenServer.start_link(__MODULE__, %{}, name: VeCollector.Serial.Discover)
#  end
#
#  def init(state) do
#
#    {:ok, state}
#  end
#
#  def update(pid \\ VeCollector.Serial.Discover) do
#    GenServer.cast(pid, {:update})
#  end
#
#  defp get_name({name, _v}) do
#    name
#  end
#
#  #callbacks
#  def handle_cast({:update}, state) do
#    devices = Circuits.UART.enumerate()
#    |> Map.to_list()
#    |> Stream.map(&get_name(&1))
#    |> Enum.into([])
#
#
#    IO.inspect(devices)
#    {:noreply, state, {:continue, {:update, devices}}}
#  end
#
#  def handle_continue({:update, [head | tail]}, state) do
#    #Map.get(state, head)
#    #|> IO.inspect()
#
#    device = Map.get(state, head)
#    if device == nil do
#      pid = DynamicSupervisor.start_child(VeCollector.SerialSupervisor, VeCollector.Serial)
#
#    else
#    end
#
#    {:noreply, state, {:continue, {:update, tail}}}
#  end
#
#  def handle_continue({:update, []}, state) do
#    {:noreply, state}
#  end
# end
