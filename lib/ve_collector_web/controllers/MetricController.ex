defmodule VeCollectorWeb.MetricController do
  use VeCollectorWeb, :controller

  def index(conn, _params) do
    data =
      VeCollector.VE.ClearText.Store.get()
      |> Map.to_list()
      |> Stream.filter(&online?(&1))
      |> Stream.map(&format(&1))
      |> Enum.into([])

    conn
    |> assign(:metric_data_list, data)
    |> render("index.text")
  end

  def port(conn, %{"port" => port}) do
    data =
      VeCollector.VE.ClearText.Store.get()
      |> Map.get(port, %{})

    data = [if(online?({port, data}), do: format({port, data}))]

    conn
    |> assign(:metric_data_list, data)
    |> render("index.text")
  end

  defp online?({_name, state}) do
    case state do
      {:ok, _v} -> true
      _ -> false
    end
  end

  defp format({name, {:ok, data}}) do
    {name, data}
  end
end
