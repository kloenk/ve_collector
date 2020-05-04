defmodule VeCollector.VE.ClearText.Store do
  use GenServer
  require Logger

  @moduledoc """
  Store cleartext data
  # TODO
  make a hashmap to support multiple devices
  """

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: :ve_collector_cleartext_store)
  end

  def start_link(_) do
    start_link()
  end

  def init(_) do
    {:ok, %{}}
  end

  @doc """
  get all data from the store
  """
  def get() do
    GenServer.call(:ve_collector_cleartext_store, {:get})
  end

  # callback
  def handle_call({:get}, _from, state) do
    {:reply, state, state}
  end

  def parse(list) when is_list(list) do
    GenServer.cast(:ve_collector_cleartext_store, {:parse, list})
  end

  # callback
  # FIXME: make it a filed in a hashmap and not override state
  def handle_cast({:parse, list}, _state) when is_list(list) do
    list =
      check(list)
      |> do_parse()

    {:noreply, list}
  end

  defp do_parse({:error, v}) do
    {:error, v}
  end

  defp do_parse({:ok, list}) when is_list(list) do
    list =
      list
      |> Stream.map(fn row ->
        String.trim(row) |> String.split("\t")
      end)
      |> Stream.filter(&data_row?(&1))
      |> Stream.map(&parse_row(&1))
      |> Enum.into(%{})

    {:ok, list}
  end

  defp parse_row([field, value]) do
    {field, value}
  end

  defp data_row?(row) do
    case row do
      [_, _] -> true
      _ -> :ok == Logger.warn("invalid row: #{inspect(row)}") and false
    end
  end

  defp check(list) when is_list(list) do
    {checksum, list} = List.pop_at(list, -1)
    IO.puts(:stderr, "FIXME: implement checking of #{inspect(list)} which #{inspect(checksum)}")
    # FIXME: return with {:error, :invalid_checksum}
    {:ok, list}
  end

  # callbacks
end
