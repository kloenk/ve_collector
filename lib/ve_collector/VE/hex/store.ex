defmodule VeCollector.VE.Hex.Store do
  use GenServer
  require Logger

  @moduledoc """
  Store the static data aggregated via the hex protocoll
  """

  def start_link(_ \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: VeCollector.VE.Hex.Store)
  end

  def init(_) do
    {:ok, %{}}
  end

  @doc """
  get all data from the store
  """
  def get() do
    GenServer.call(VeCollector.VE.Hex.Store, {:get})
  end

  @doc """
  put data into the Store
  """
  def put(name, value) when is_map(value) do
    GenServer.cast(VeCollector.VE.Hex.Store, {:put, name, value})
  end

  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:put, name, {value_name, value}}, state) do
    map = Map.get(state, name, %{})
    |> Map.put(value_name, value)

    {:noreply, Map.put(state, name, map)}
  end

  def handle_cast({:put, name, value}, state) when is_map(value) do
    {:noreply, Map.put(state, name, value)}
  end


end
