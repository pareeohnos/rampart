defmodule Admin do
  defstruct id: nil

  def policy, do: UserPolicy
end