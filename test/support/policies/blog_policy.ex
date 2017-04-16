defmodule BlogPolicy do
  use Rampart.Policy

  def index?(_user, Blog), do: true
  def show?(_user, %Blog{ id: _blog_id }), do: true

  def forbidden?(_user, _resource), do: false

end