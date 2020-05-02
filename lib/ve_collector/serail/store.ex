defmodule VeCollector.Serial.Store do
  use GenServer

  @name VeCollector.Serial.Store

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def init(state) do
    {:ok, state}
  end

  def reset(pid \\ @name) do
    GenServer.cast(pid, {:reset})
  end

  def online(name, pid \\ @name) do
    GenServer.cast(pid, {:online, name})
  end

  def put(name, pid, g_pid \\ @name) do
    GenServer.cast(g_pid, {:put, {name, pid}})
  end

  def get() do
    GenServer.call(@name, {:get})
  end

  def get(name) do
    GenServer.call(@name, {:get, name})
  end

  defp do_reset({name, {pid, _}}) do
    {name, {pid, false}}
  end

  defp online?({_name, {_pid, online}}) do
    online
  end

  defp format({name, {pid, _}}) do
    {name, pid}
  end

  # callbacks
  def handle_cast({:reset}, state) do
    state =
      state
      |> Map.to_list()
      |> Stream.map(&do_reset(&1))
      |> Enum.into(%{})

    {:noreply, state}
  end

  def handle_cast({:online, name}, state) do
    device =
      state
      |> Map.get(name)

    IO.inspect(device)

    state =
      case device do
        {pid, _} -> Map.put(state, name, {pid, true})
        _ -> state
      end

    IO.inspect(state)

    {:noreply, state}
  end

  def handle_cast({:put, {name, pid}}, state) do
    state =
      state
      |> Map.put(name, {pid, false})

    {:noreply, state}
  end

  def handle_call({:get}, _from, state) do
    online =
      state
      |> Map.to_list()
      |> Stream.filter(&online?(&1))
      |> Stream.map(&format(&1))
      |> Enum.into(%{})

    {:reply, online, state}
  end

  def handle_call({:get, name}, _from, state) do
    device = Map.get(state, name)
    {:reply, device, state}
  end
end
