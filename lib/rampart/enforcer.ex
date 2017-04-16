defmodule Rampart.Enforcer do
  @moduledoc ~S"""
  The Enforcer module defines a plug which enforces
  that a request has been authorized. This should
  be used in your applications router in whatever
  pipeline you want verified.

  The verification process simply checks for the
  existence of the `authorized` key. If no authorization
  has been performed, this plug will raise a
  `Rampart.Exceptions.AuthorizationNotPerformed`
  exception.
  """

  @behaviour Plug
  alias Plug.Conn

  @type opts :: any

  @spec init(opts) :: opts
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), opts) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn
    |> Conn.register_before_send(fn(c) ->
      case conn.assigns[:authorized] do
        true -> conn
        nil -> raise Rampart.Exceptions.AuthorizationNotPerformed
      end
    end)
  end

end