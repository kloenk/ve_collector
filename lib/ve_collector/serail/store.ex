defmodule VeCollector.Serial.Store do
  @moduledoc """
  Store the open serial devices for acces of the pid
  """

  use GenServer

  @doc """
  name of the GenServer
  """
  @name VeCollector.Serial.Store

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def init(state) do
    {:ok, state}
  end

  @doc """
  reset all devices to offline, to rebuild the online database
  # TODO
  maybe can be replaced, because devices which are online, are monitored it the go offline
  """
  def reset(pid \\ @name) do
    GenServer.cast(pid, {:reset})
  end

  @doc """
  remove every devicse which is not marked as online
  """
  def clear(pid \\ @name) do
    GenServer.cast(pid, {:clear})
  end

  @doc """
  set the serial device to state online

  `name`: name of the serial device
  """
  def online(name, pid \\ @name) do
    GenServer.cast(pid, {:online, name})
  end

  @doc """
  add pid to the store with the given name
  """
  def put(name, pid, g_pid \\ @name) do
    GenServer.cast(g_pid, {:put, {name, pid}})
  end

  @doc """
  list devices, which are online
  """
  def get() do
    GenServer.call(@name, {:get})
  end

  @doc """
  get the pid of the witch `name` refereced serial device
  """
  def get(name) do
    GenServer.call(@name, {:get, name})
  end

  @doc """
  get all devices (also not online devices)
  """
  @doc deprecated: "only for debuging purpose"
  @deprecated "only for debuging purpose"
  def get_all() do
    GenServer.call(@name, {:get_all})
  end

  # def stop_child(name) do
  #  GenServer.cast(@name, {:stop, name})
  # end

  defp do_reset({name, {pid, _}}) do
    {name, {pid, false}}
  end

  defp online?({_name, {_pid, online}}) do
    online
  end

  defp format({name, {pid, _}}) do
    {name, pid}
  end

  defp get_online(state) do
    state
    |> Map.to_list()
    |> Stream.filter(&online?(&1))
    |> Stream.map(&format(&1))
    |> Enum.into(%{})
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

  def handle_cast({:stop, name}, state) do
    state =
      state
      |> Map.delete(name)

    {:noreply, state}
  end

  def handle_cast({:clear}, state) do
    offline =
      state
      |> Map.to_list()
      |> Stream.filter(fn v ->
        online?(v) == false
      end)
      |> Stream.map(&format(&1))
      |> Enum.into(%{})

    IO.puts("TODO: implement clear #{inspect(offline)}")

    {:noreply, state}
  end

  def handle_call({:get}, _from, state) do
    online =
      state
      |> get_online()

    {:reply, online, state}
  end

  def handle_call({:get, name}, _from, state) do
    device = Map.get(state, name)
    {:reply, device, state}
  end

  def handle_call({:get_all}, _from, state) do
    {:reply, state, state}
  end
end
