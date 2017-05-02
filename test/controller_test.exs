defmodule ControllerTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "authorises the request" do
    conn = conn(:get, "/authorized") |> Plug.Conn.assign(:current_user, %User{})
    conn = TestRouter.call(conn, [])

    assert conn.assigns.authorized
  end

end