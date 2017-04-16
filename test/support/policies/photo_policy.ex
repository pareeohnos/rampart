defmodule PhotoPolicy do
  use Rampart.Policy

  def should_proceed?(_user, _resource, _action), do: false

  def index?(_user, _resource), do: true
end