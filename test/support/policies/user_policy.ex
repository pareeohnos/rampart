defmodule UserPolicy do
  use Rampart.Policy

  def index?(_user, _resource), do: true
end