defmodule VeCollectorWeb.PageController do
  use VeCollectorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
