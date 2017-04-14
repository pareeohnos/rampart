defmodule Rampart do
  @moduledoc File.read!("README.md")

  use Application

  @typedoc """
  A policy is simply a standard module. Nothing special.
  """
  @type policy :: module()




  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Rampart.PolicyFinder, [])
    ]

    opts = [strategy: :one_for_one, name: Rampart.Supervisor]
    Supervisor.start_link(children, opts)
  end



  @doc """
  Attempts to retrieve a policy based on the resource 
  provided. A policy can be found either by a module
  (for non resource level authorisation) or by a resource
  (or struct specifically).

  For example, to retrieve the policy for images, we can
  either call

      Rampart.policy(MyApp.Image)

  or we can call

      image = Repo.get(MyApp.Image, id)
      Rampart.policy(image)

  If a policy is found, the module will be returned. If 
  not `nil` will be returned.
  """
  @spec policy(module() | struct()) :: policy() | nil
  def policy(resource) do
    Rampart.PolicyFinder.find(resource)
  end

end