defmodule AuthorizeTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Rampart.Authorize

  test "raises an exception if no current user" do
    opts = Authorize.init(resource: nil, action: nil)
    conn = conn(:get, "/hello")

    assert_raise Rampart.Exceptions.UserNotFound, fn ->
      Authorize.call(conn, opts)
    end
  end

  test "raises an exception if a policy is not found" do
    opts = Authorize.init(resource: nil, action: nil)
    conn = conn(:get, "/hello") |> Plug.Conn.assign(:current_user, %User{})
    

    assert_raise Rampart.Exceptions.PolicyNotFound, fn ->
      Authorize.call(conn, opts)
    end
  end

  test "authorised an action" do
    opts = Authorize.init(resource: Blog, action: :index?)
    conn = 
      conn(:get, "/hello") 
      |> Plug.Conn.assign(:current_user, %User{})
      |> Authorize.call(opts)

    assert conn.assigns[:authorized]
  end

  test "raises an exception if not authorized" do
    opts = Authorize.init(resource: Blog, action: :forbidden?)
    assert_raise Rampart.Exceptions.Forbidden, fn ->
      conn(:get, "/hello")
      |> Plug.Conn.assign(:current_user, %User{})
      |> Authorize.call(opts)
    end
  end

  test "raises an exception if should not proceed" do
    opts = Authorize.init(resource: Photo, action: :index?)
    assert_raise Rampart.Exceptions.Forbidden, fn ->
      conn(:get, "/hello")
      |> Plug.Conn.assign(:current_user, %User{})
      |> Authorize.call(opts)
    end
  end
end