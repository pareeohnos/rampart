defmodule Rampart.Exceptions.AuthorizationNotPerformed do
  defexception [message: "Authorization has not been performed",
                status: 500]
end