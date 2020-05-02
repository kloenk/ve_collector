defmodule VeCollector.Serial do
  alias Circuits.UART

  def start_link(_arg) do
    # FIXME: do something with arg?
    Kernel.spawn_link(serial)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def serial do
    # IO.puts("Hello World")
    :timer.sleep(1000)
    serial()
  end
end
