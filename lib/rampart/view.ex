defmodule Rampart.View do
  
  defmacro __using__(_opts) do
    quote do
      import Rampart.View
    end
  end

  @doc """
  Checks to see if the specified user has permission
  to perform the specified action on the specified
  resource.
  """
  @spec has_permission?(any(), atom(), any()) :: boolean()
  def has_permission?(user, action, resource) do
    resource
    |> Rampart.PolicyFinder.find
    |> apply(action, [user, resource])
  end
end