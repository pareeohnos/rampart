defmodule Rampart.Controller do
  @moduledoc ~S"""
  The Controller module provides functions that are
  to be used by controllers in your application. These
  may not strictly be controllers, but they are for
  the part of your application that will handle the
  request, and trigger the authorisation.
  """

  @typedoc """
  A resource can be anything and is application specific,
  but in most scenarios it will most likely be a module,
  or a struct.
  """
  @type resource :: any


  alias Rampart.Authorize, as: AuthPlug
  
  
  @doc false
  defmacro __using__(_opts) do
    quote location: :keep do
      import Rampart.Controller
    end
  end

  @doc """
  Authorizes the supplied resource. This should be called
  in the controller action, as Rampart will automatically
  determine which policy to use, and what action was invoked.

  If you want to specify a different policy action, see
  `authorize!/3`
  """
  @spec authorize!(Plug.Conn.t, resource) :: none()
  defmacro authorize!(conn, resource) do
    do_authorize(conn, resource, policy_action(__CALLER__))
  end

  @doc """
  Authorizes the supplied resource. Unlike `authorize/2`,
  this function allows you to specify which policy action
  should be used, rather than having it determined by
  Rampart. This is useful if you have a number of 
  actions that all require the same permission. 
  
  For example, if you had a photo controller, which had
  an `edit` and a `resize` action, both of these actions
  are forms of editing. So your `resize` action may call

      photo = Repo.get(MyApp.Photo, id)
      authorize!(photo, :edit?)

  And your policy would not need a `resize/2` function
  defined.
  """
  @spec authorize!(Plug.Conn.t, resource, atom()) :: none()
  defmacro authorize!(conn, resource, action) do
    do_authorize(conn, resource, action)
  end

  # Hands off the authorisation login to the
  # main authorization plug.
  defp do_authorize(conn, resource, action) do
    # plug Rampart.Authorize, resource: resource, action: action
    quote do
      opts =
        [resource: unquote(resource), action: unquote(action)]
        |> AuthPlug.init()
      
      AuthPlug.call(unquote(conn), opts)
    end
  end

  # Given the caller, returns the name of the
  # module and function that called the authorize
  # function.
  defp policy_action(caller) do
    { func, _arity } = caller.function
    :"#{func}?"
  end
end