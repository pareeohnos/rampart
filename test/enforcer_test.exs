defmodule EnforcerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest Rampart.Enforcer

  alias Rampart.Enforcer

  test "raises an exception if not already authorized" do
    assert_raise Rampart.Exceptions.AuthorizationNotPerformed, fn ->
      conn(:get, "/hello")
      |> Enforcer.call([])
    end
  end

  test "does nothing if already authorized" do
    conn =
      conn(:get, "/hello")
      |> Plug.Conn.assign(:authorized, true)


     assert Enforcer.call(conn, []) == conn
  end
end