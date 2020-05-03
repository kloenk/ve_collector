defmodule VeCollector.Serial do
  use GenServer, restart: :transient
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, {})
  end

  def start_link(_opts) do
    start_link()
  end

  def init(_) do
    {:ok, pid} = Circuits.UART.start_link()
    {:ok, {pid}}
  end

  def open(pid, port, speed \\ 19200) do
    Logger.info("open device #{port}")
    GenServer.call(pid, {:open, port, speed}, 5000)
  end

  def get_uart_pid(pid) do
    GenServer.call(pid, {:get_pid})
  end

  defp online(name) do
    VeCollector.Serial.Store.online(name)
  end

  defp stop(name, {pid}) do
    Circuits.UART.close(pid)
    Circuits.UART.stop(pid)
    GenServer.cast(VeCollector.Serial.Store, {:stop, name})
    # VeCollector.Serial.Store.stop_child(name)
  end

  # callbacks
  def handle_call({:open, port, speed}, _from, {pid}) do
    v =
      Circuits.UART.open(pid, port,
        speed: speed,
        framing: {Circuits.UART.Framing.Line, separator: "\r\n"},
        rx_framing_timeout: 300
      )

    {:reply, v, {pid}}
  end

  def handle_call({:get_pid}, _from, {pid}) do
    {:reply, pid, {pid}}
  end

  # parse info
  def handle_info({:circuits_uart, name, v}, {pid}) when is_binary(v) do
    online(name)
    Logger.debug("got msg: #{v}")
    ret = VeCollector.VE.ClearText.parse(v)
    IO.inspect(ret)
    {:noreply, {pid}}
  end

  def handle_info({:circuits_uart, name, {:partial, v}}, state) when is_binary(v) do
    online(name)

    if String.starts_with?(v, "Checksum\t") do
      VeCollector.VE.ClearText.parse(v)
    else
      Logger.warn("this binary should not come from #{name}, #{inspect(v)}")
    end

    {:noreply, state}
  end

  def handle_info({:circuits_uart, name, {:error, :eio}}, {pid}) do
    stop(name, {pid})
    {:stop, :normal, {}}
  end

  # def handle_info(v, {pid}) do
  #  IO.inspect(v)
  #  {:noreply, {pid}}
  # end
end
