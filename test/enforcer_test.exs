defmodule EnforcerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest Rampart.Enforcer

  alias Rampart.Enforcer

  test "adds a before_send callback" do
    conn =
      conn(:get, "/hello")
      |> Plug.Conn.assign(:authorized, true)
      |> Enforcer.call([])

    assert Enum.count(conn.before_send) == 1
  end
  
  test "raises an exception if not already authorized" do
    conn = 
      conn(:get, "/hello")
      |> Enforcer.call([])
    
    assert_raise Rampart.Exceptions.AuthorizationNotPerformed, fn ->
      List.first(conn.before_send).(conn)
    end
  end

  test "does nothing if already authorized" do
    conn =
      conn(:get, "/hello")
      |> Plug.Conn.assign(:authorized, true)
      |> Enforcer.call([])

    assert List.first(conn.before_send).(conn) == conn
  end
end