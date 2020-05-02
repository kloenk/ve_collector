defmodule VeCollector.Serial.Serial do
  use GenServer
  alias Circuits.UART

  def start_link do
    GenServer.start_link(__MODULE__, [], name: :ve_collector_serial)
  end


  def init(_) do
    {:ok, pid} = UART.start_link

    {:ok, pid}
  end

  def get_uart_pid do
    GenServer.call(:ve_collector_serial, {:get_pid})
  end

  # Callbacks
  def handle_call({:get_pid}, _from, pid) do
    {:reply, pid, pid}
  end
end
