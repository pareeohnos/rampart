defmodule ViewTest do
  use ExUnit.Case
  doctest Rampart.View
  
  test "Checks if the user has permission" do
    assert Rampart.View.has_permission?(%User{}, :index?, Blog)
    refute Rampart.View.has_permission?(%User{}, :forbidden?, Blog)
  end
end