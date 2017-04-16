defmodule PolicyFinderTest do
  use ExUnit.Case
  doctest Rampart.PolicyFinder

  alias Rampart.PolicyFinder

  test "Returns nil if no policy is found" do
    assert is_nil(PolicyFinder.find(InvalidResource))
  end

  test "Finds the policy when given the resource module" do
    assert PolicyFinder.find(Blog) == BlogPolicy
  end

  test "Finds the policy when given a resource struct" do
    assert PolicyFinder.find(%Blog{}) == BlogPolicy
  end

  test "Finds policies that are namespaced" do
    assert PolicyFinder.find(Namespace) == RampartTest.Policies.NamespacePolicy
  end

  test "Allows a resource to specify which policy it always uses" do
    assert PolicyFinder.find(Admin) == UserPolicy
  end

  test "Allows a resource to conditionally specify its policy" do
    assert PolicyFinder.find(User) == UserPolicy
    assert PolicyFinder.find(%User{}) == BlogPolicy
  end
  
end