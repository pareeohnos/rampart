defmodule Rampart.Exceptions.UserNotFound do
  defexception [message: "No current user was found. Please ensure the correct assigns key is being used, or that a user is logged in.",
                plug_status: 500]
end