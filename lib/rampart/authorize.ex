defmodule Rampart.Authorize do
  @moduledoc """
  The Authorize module defines the plug that handles
  the actual authorization of a request.

  ### Configuration

  On initialisation, the Authorize plug requires two
  options:

  - `resource` - The resource that is being authorized, either a module or a struct in most cases
  - `action` - The name of the action that is should be called on the policy.
  """
  
  @behaviour Plug
  alias Plug.Conn


  @typedoc """
  Opts for this plug is a simple keyword list
  """
  @type opts :: keyword()

  @doc """
  Initialises the authorization plug with the supplied
  options. Please see `options` for more information.
  """
  @spec init(opts) :: opts
  def init(opts) do
    user_key = Application.get_env(:rampart, :current_user, :current_user)
    Keyword.merge(opts, user_key: user_key)
  end

  @doc """
  """
  @spec call(Plug.Conn.t(), opts) :: Plug.Conn.t()
  def call(conn, opts) do
    user_key = Keyword.get(opts, :user_key)
    resource = Keyword.get(opts, :resource)
     action = Keyword.get(opts, :action)

    with { :ok, current_user } <- fetch_user(conn, user_key),
         { :ok, policy } <- fetch_policy(resource)
    
    do
      # Policy and user both found, perform authorization
      conn |> authorize_user!(current_user, policy, action, resource)

    else
      { :error, :user_not_found } ->
        raise Rampart.Exceptions.UserNotFound

      { :error, :policy_not_found } ->
        raise Rampart.Exceptions.PolicyNotFound
      
    end
  end

  defp authorize_user!(conn, current_user, policy, action, resource) do
    with true <- policy.should_proceed?(current_user, resource, action),
         true <- apply(policy, action, [current_user, resource])
    do
      conn
      |> Conn.assign(:authorized, true)

    else
      _ -> raise Rampart.Exceptions.Forbidden
    end
  end


  # Fetches the current user from the conn assigns,
  # returning a tuple
  defp fetch_user(conn, key) do
    case conn.assigns[key] do
      nil -> { :error, :user_not_found }
      user -> { :ok, user }
    end
  end

  # Retrieves the policy for the supplied resource,
  # returning a tuple
  defp fetch_policy(resource) do
    case Rampart.policy(resource) do
      nil -> { :error, :policy_not_found }
      policy -> { :ok, policy }
    end
  end
end