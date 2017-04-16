defmodule User do
  defstruct id: nil

  def policy(User), do: UserPolicy
  def policy(%User{}), do: BlogPolicy
end