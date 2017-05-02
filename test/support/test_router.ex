defmodule TestRouter do
  use Plug.Router
  use Rampart.Controller

  plug :match
  plug :dispatch

  get "/authorized" do
    authorize! conn, Blog, :index?
  end

  get "/unauthorized" do
    authorize! conn, Blog, :forbidden?
  end

end