defmodule Rampart.Policy do
  @moduledoc ~S"""
  The `Policy` module provides very little functionality,
  but is key to the way in which Rampart works. Any user
  defined policy must `use` this module, which allows
  Rampart to find it when your application starts.

  Additionally, policies will be given access to functions
  provided by the main Rampart module, which can be useful
  if one policy needs to reference rules of another.

  The Policy module also defines a behaviour that provides
  a single callback `should_proceed?`. By default this will
  return true, however if implemented, you can return `false`
  which will prevent any further authorisation processing.
  This might seem unusual, but take for example a controller
  that is restricted to only administrators. Instead of 
  having to test this in every authorisation function, you
  can simply return false from the `should_proceeed?/2`
  function, and not have to worry about checking later.
  Much easier.
  """

  @typedoc """
  The current user is any term. It is determined from the
  `current_user` key in the `conn` assigns map unless 
  specified otherwised. As such, the `current_user` argument
  will be whatever is stored in the assigns map and can
  be anything, but will most likely be a struct.
  """
  @type current_user :: any

  @typedoc """
  A resource can be anything and is application specific,
  but in most scenarios it will most likely be a module,
  or a struct.
  """
  @type resource :: any



  @callback should_proceed?(current_user, resource) :: boolean



  defmacro __using__(_opts) do
    quote do
      import Rampart
      
      @behaviour Rampart.Policy

      def should_proceed?(current_user, resource), do: true

    end
  end

end