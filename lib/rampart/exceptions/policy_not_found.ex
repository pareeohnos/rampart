defmodule Rampart.Exceptions.PolicyNotFound do
  defexception [message: "Could not find a policy.",
                plug_status: 500]
end