defmodule VeCollector.VE.ClearText.Store do
  use GenServer
  require Logger

  @moduledoc """
  Store cleartext data
  # TODO
  - clear store completle every 5 minutes to avoid stale data (or add timestamp to data)
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

  @doc """
  put a value into a given place in the store

  # Note
  This function overrides parsing, so handle witch care
  """
  def put(name, value) do
    GenServer.cast(:ve_collector_cleartext_store, {:put, name, value})
  end

  def handle_cast({:put, name, value}, state) do
    {:noreply, Map.put(state, name, value)}
  end

  def parse(list, name) when is_list(list) do
    GenServer.cast(:ve_collector_cleartext_store, {:parse, list, name})
  end

  # callback
  # FIXME: make it a filed in a hashmap and not override state
  def handle_cast({:parse, list, name}, state) when is_list(list) do
    list =
      check(list)
      |> do_parse()

    {:noreply, Map.put(state, name, list)}
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
      |> find_pid()
      |> add_static()

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

  def add_static(data) when is_map(data) do


    data
  end

  defp find_pid(data) when is_map(data) do
    pid =
      Map.get(data, "PID", "0x0000")
      |> find_pid()

    Map.put(data, "product", pid)
  end

  defp find_pid(pid) when is_binary(pid) do
    case pid do
      "0x203" -> {"BMV", "BMV-700"}
      "0x204" -> {"BMV", "BMV-702"}
      "0x205" -> {"BMV", "BMV-700H"}
      "0x0300" -> {"MPPT", "BlueSolar MPPT 70|15"}
      "0xA040" -> {"MPPT", "BlueSolar MPPT 75|50"}
      "0xA041" -> {"MPPT", "BlueSolar MPPT 150|35"}
      "0xA042" -> {"MPPT", "BlueSolar MPPT 75|15"}
      "0xA043" -> {"MPPT", "BlueSolar MPPT 100|15"}
      "0xA044" -> {"MPPT", "BlueSolar MPPT 100|30"}
      "0xA045" -> {"MPPT", "BlueSolar MPPT 100|50"}
      "0xA046" -> {"MPPT", "BlueSolar MPPT 150|70"}
      "0xA047" -> {"MPPT", "BlueSolar MPPT 150|100"}
      "0xA049" -> {"MPPT", "BlueSolar MPPT 100|50 rev2"}
      "0xA04A" -> {"MPPT", "BlueSolar MPPT 100|30 rev2"}
      "0xA04B" -> {"MPPT", "BlueSolar MPPT 150|35 rev2"}
      "0xA04C" -> {"MPPT", "BlueSolar MPPT 75|10"}
      "0xA04D" -> {"MPPT", "BlueSolar MPPT 150|45"}
      "0xA04E" -> {"MPPT", "BlueSolar MPPT 150|60"}
      "0xA04F" -> {"MPPT", "BlueSolar MPPT 150|85"}
      "0xA050" -> {"MPPT", "SmartSolar MPPT 250|100"}
      "0xA051" -> {"MPPT", "SmartSolar MPPT 150|100"}
      "0xA052" -> {"MPPT", "SmartSolar MPPT 150|85"}
      "0xA053" -> {"MPPT", "SmartSolar MPPT 75|15"}
      "0xA054" -> {"MPPT", "SmartSolar MPPT 75|10"}
      "0xA055" -> {"MPPT", "SmartSolar MPPT 100|15"}
      "0xA056" -> {"MPPT", "SmartSolar MPPT 100|30"}
      "0xA057" -> {"MPPT", "SmartSolar MPPT 100|50"}
      "0xA058" -> {"MPPT", "SmartSolar MPPT 150|35"}
      "0xA059" -> {"MPPT", "SmartSolar MPPT 150|100 rev2"}
      "0xA05A" -> {"MPPT", "SmartSolar MPPT 150|85 rev2"}
      "0xA05B" -> {"MPPT", "SmartSolar MPPT 250|70"}
      "0xA05C" -> {"MPPT", "SmartSolar MPPT 250|85"}
      "0xA05D" -> {"MPPT", "SmartSolar MPPT 250|60"}
      "0xA05E" -> {"MPPT", "SmartSolar MPPT 250|45"}
      "0xA05F" -> {"MPPT", "SmartSolar MPPT 100|20"}
      "0xA060" -> {"MPPT", "SmartSolar MPPT 100|20 48V"}
      "0xA061" -> {"MPPT", "SmartSolar MPPT 150|45"}
      "0xA062" -> {"MPPT", "SmartSolar MPPT 150|60"}
      "0xA063" -> {"MPPT", "SmartSolar MPPT 150|70"}
      "0xA064" -> {"MPPT", "SmartSolar MPPT 250|85 rev2"}
      "0xA065" -> {"MPPT", "SmartSolar MPPT 250|100 rev2"}
      "0xA102" -> {"MPPT", "SmartSolar MPPT VE.Can 150/70"}
      "0xA103" -> {"MPPT", "SmartSolar MPPT VE.Can 150/45"}
      "0xA104" -> {"MPPT", "SmartSolar MPPT VE.Can 150/60"}
      "0xA105" -> {"MPPT", "SmartSolar MPPT VE.Can 150/85"}
      "0xA106" -> {"MPPT", "SmartSolar MPPT VE.Can 150/100"}
      "0xA107" -> {"MPPT", "SmartSolar MPPT VE.Can 250/45"}
      "0xA108" -> {"MPPT", "SmartSolar MPPT VE.Can 250/60"}
      "0xA109" -> {"MPPT", "SmartSolar MPPT VE.Can 250/70"}
      "0xA10A" -> {"MPPT", "SmartSolar MPPT VE.Can 250/85"}
      "0xA10B" -> {"MPPT", "SmartSolar MPPT VE.Can 250/100"}
      "0xA201" -> {"Phoenix", "Phoenix Inverter 12V 250VA 230V"}
      "0xA202" -> {"Phoenix", "Phoenix Inverter 24V 250VA 230V"}
      "0xA204" -> {"Phoenix", "Phoenix Inverter 48V 250VA 230V"}
      "0xA211" -> {"Phoenix", "Phoenix Inverter 12V 375VA 230V"}
      "0xA212" -> {"Phoenix", "Phoenix Inverter 24V 375VA 230V"}
      "0xA214" -> {"Phoenix", "Phoenix Inverter 48V 375VA 230V"}
      "0xA221" -> {"Phoenix", "Phoenix Inverter 12V 500VA 230V"}
      "0xA222" -> {"Phoenix", "Phoenix Inverter 24V 500VA 230V"}
      "0xA224" -> {"Phoenix", "Phoenix Inverter 48V 500VA 230V"}
      "0xA231" -> {"Phoenix", "Phoenix Inverter 12V 250VA 230V"}
      "0xA232" -> {"Phoenix", "Phoenix Inverter 24V 250VA 230V"}
      "0xA234" -> {"Phoenix", "Phoenix Inverter 48V 250VA 230V"}
      "0xA239" -> {"Phoenix", "Phoenix Inverter 12V 250VA 120V"}
      "0xA23A" -> {"Phoenix", "Phoenix Inverter 24V 250VA 120V"}
      "0xA23C" -> {"Phoenix", "Phoenix Inverter 48V 250VA 120V"}
      "0xA241" -> {"Phoenix", "Phoenix Inverter 12V 375VA 230V"}
      "0xA242" -> {"Phoenix", "Phoenix Inverter 24V 375VA 230V"}
      "0xA244" -> {"Phoenix", "Phoenix Inverter 48V 375VA 230V"}
      "0xA249" -> {"Phoenix", "Phoenix Inverter 12V 375VA 120V"}
      "0xA24A" -> {"Phoenix", "Phoenix Inverter 24V 375VA 120V"}
      "0xA24C" -> {"Phoenix", "Phoenix Inverter 48V 375VA 120V"}
      "0xA251" -> {"Phoenix", "Phoenix Inverter 12V 500VA 230V"}
      "0xA252" -> {"Phoenix", "Phoenix Inverter 24V 500VA 230V"}
      "0xA254" -> {"Phoenix", "Phoenix Inverter 48V 500VA 230V"}
      "0xA259" -> {"Phoenix", "Phoenix Inverter 12V 500VA 120V"}
      "0xA25A" -> {"Phoenix", "Phoenix Inverter 24V 500VA 120V"}
      "0xA25C" -> {"Phoenix", "Phoenix Inverter 48V 500VA 120V"}
      "0xA261" -> {"Phoenix", "Phoenix Inverter 12V 800VA 230V"}
      "0xA262" -> {"Phoenix", "Phoenix Inverter 24V 800VA 230V"}
      "0xA264" -> {"Phoenix", "Phoenix Inverter 48V 800VA 230V"}
      "0xA269" -> {"Phoenix", "Phoenix Inverter 12V 800VA 120V"}
      "0xA26A" -> {"Phoenix", "Phoenix Inverter 24V 800VA 120V"}
      "0xA26C" -> {"Phoenix", "Phoenix Inverter 48V 800VA 120V"}
      "0xA271" -> {"Phoenix", "Phoenix Inverter 12V 1200VA 230V"}
      "0xA272" -> {"Phoenix", "Phoenix Inverter 24V 1200VA 230V"}
      "0xA274" -> {"Phoenix", "Phoenix Inverter 48V 1200VA 230V"}
      "0xA279" -> {"Phoenix", "Phoenix Inverter 12V 1200VA 120V"}
      "0xA27A" -> {"Phoenix", "Phoenix Inverter 24V 1200VA 120V"}
      "0xA27C" -> {"Phoenix", "Phoenix Inverter 48V 1200VA 120V"}
      "0xA281" -> {"Phoenix", "Phoenix Inverter 12V 1600VA 230V"}
      "0xA282" -> {"Phoenix", "Phoenix Inverter 24V 1600VA 230V"}
      "0xA284" -> {"Phoenix", "Phoenix Inverter 48V 1600VA 230V"}
      "0xA291" -> {"Phoenix", "Phoenix Inverter 12V 2000VA 230V"}
      "0xA292" -> {"Phoenix", "Phoenix Inverter 24V 2000VA 230V"}
      "0xA294" -> {"Phoenix", "Phoenix Inverter 48V 2000VA 230V"}
      "0xA2A1" -> {"Phoenix", "Phoenix Inverter 12V 3000VA 230V"}
      "0xA2A2" -> {"Phoenix", "Phoenix Inverter 24V 3000VA 230V"}
      "0xA2A4" -> {"Phoenix", "Phoenix Inverter 48V 3000VA 230V"}
      "0xA340" -> {"Phoenix", "Phoenix Smart IP43 Charger 12|50 (1+1)"}
      "0xA341" -> {"Phoenix", "Phoenix Smart IP43 Charger 12|50 (3)"}
      "0xA342" -> {"Phoenix", "Phoenix Smart IP43 Charger 24|25 (1+1)"}
      "0xA343" -> {"Phoenix", "Phoenix Smart IP43 Charger 24|25 (3)"}
      "0xA344" -> {"Phoenix", "Phoenix Smart IP43 Charger 12|30 (1+1)"}
      "0xA345" -> {"Phoenix", "Phoenix Smart IP43 Charger 12|30 (3)"}
      "0xA346" -> {"Phoenix", "Phoenix Smart IP43 Charger 24|16 (1+1)"}
      "0xA347" -> {"Phoenix", "Phoenix Smart IP43 Charger 24|16 (3)"}
      _ -> {:error, "Unknown"}
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
