defmodule VeCollectorWeb.Plugs.ContentVersion do
  import Plug.Conn

  def init(default), do: default

  def call(conn, default) do
    conn
    |> put_resp_content_type(default)
  end

end
