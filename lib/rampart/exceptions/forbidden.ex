defmodule Rampart.Exceptions.Forbidden do
  defexception [message: "You do not have permission to access this resource",
                plug_status: 403]
end