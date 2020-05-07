defmodule VeCollectorWeb.PageController do
  use VeCollectorWeb, :controller

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end
