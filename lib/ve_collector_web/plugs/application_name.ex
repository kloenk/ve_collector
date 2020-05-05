defmodule VeCollectorWeb.Plugs.ApplicationName do
  import Plug.Conn

  def init(default), do: default

  def call(conn, default) do
    conn
    |> assign(:application_name, default)
  end
end
