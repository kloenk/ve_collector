defmodule VeCollector.Serial do
  # use the transient restart option, so the supervisor does not restart it, if it shutdowns cleanley, incase of closed port
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

  # callback
  def handle_call({:open, port, speed}, _from, {pid}) do
    v =
      Circuits.UART.open(pid, port,
        speed: speed,
        framing: {Circuits.UART.Framing.Line, separator: "\r\n"},
        rx_framing_timeout: 300
      )

    {:reply, v, {pid}}
  end

  @doc """
  get the pid from the internal state, which is used for the connection with the uart module
  """
  def get_uart_pid(pid) do
    GenServer.call(pid, {:get_pid})
  end

  def handle_call({:get_pid}, _from, {pid}) do
    {:reply, pid, {pid}}
  end

  defp online(name) do
    VeCollector.Serial.Store.online(name)
  end

  defp stop(name, {pid}) do
    Circuits.UART.close(pid)
    Circuits.UART.stop(pid)
    VeCollector.VE.ClearText.Store.put(name, {:error, :closed})
    # VeCollector.Serial.Store.stop_child(name)
  end

  # stop the connection (caller has to clean the Store part)
  def handle_cast({:stop, name}, {pid}) do
    Logger.info("stopping #{name}")
    stop(name, {pid})
    {:stop, :normal, {}}
  end

  # parse info
  def handle_info({:circuits_uart, name, v}, {pid}) when is_binary(v) do
    online(name)
    Logger.debug("got msg: #{v}")
    ret = VeCollector.VE.ClearText.parse(v, name)
    IO.inspect(ret)
    {:noreply, {pid}}
  end

  def handle_info({:circuits_uart, name, {:partial, v}}, state) when is_binary(v) do
    online(name)

    if String.starts_with?(v, "Checksum\t") do
      VeCollector.VE.ClearText.parse(v, name)
    else
      Logger.warn("this binary should not come from #{name}, #{inspect(v)}")
    end

    {:noreply, state}
  end

  def handle_info({:circuits_uart, name, {:error, :eio}}, {pid}) do
    Logger.info("got eio from #{name}")
    stop(name, {pid})
    GenServer.cast(VeCollector.Serial.Store, {:stop, name})
    {:stop, :normal, {}}
  end

  # TODO: disabled so it can fail for invalid messages
  # def handle_info(v, {pid}) do
  #  IO.inspect(v)
  #  {:noreply, {pid}}
  # end
end
