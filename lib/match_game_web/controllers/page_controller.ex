defmodule MatchGameWeb.PageController do
  use MatchGameWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
