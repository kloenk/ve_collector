defmodule VeCollectorWeb.PageController do
  use VeCollectorWeb, :controller

  def index(conn, _params) do
    conn
    |> IO.inspect()
    |> render("index.html")
  end
end
