defmodule BlabberWeb.PageController do
  use BlabberWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
