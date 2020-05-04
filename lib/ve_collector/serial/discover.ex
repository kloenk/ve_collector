defmodule VeCollector.Serial.Discover do
  alias VeCollector.Serial.Store
  alias VeCollector.Serial

  @moduledoc """
  thread to Discover new Serial devices every 5 minutes
  ## FIXME
  use genserver, or something which works better with a supervisor
  """

  def start_link(_opts \\ []) do
    pid =
      spawn_link(fn ->
        run(true)
      end)

    {:ok, pid}
  end

  @doc """
  child specs for the supervisor to start the thread
  """
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  @doc """
  enumerate the diveces, and start if there are unknown devices
  """
  def run(forever \\ false) do
    devices =
      Circuits.UART.enumerate()
      |> Map.to_list()
      |> Stream.map(&get_name(&1))
      |> Enum.into([])

    start_device(devices)

    # 30 seconds
    :timer.sleep(30 * 1000)
    Store.clear()

    if forever do
      # 5 minutes
      :timer.sleep(5 * 60 * 1000)
      run(forever)
    end
  end

  # start a DynamicSupervisor for the devices in list
  defp start_device([name | tail]) do
    start_device(name)
    start_device(tail)
  end

  defp start_device([]) do
  end

  # start the supervisor for the given Serial interface
  # TODO: add monitoring of the pid, to enable restart with reconnect
  defp start_device(name) when is_binary(name) do
    # FIXME: move to a better place?
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
