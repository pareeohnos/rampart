defmodule Rampart.PolicyFinder do
  @moduledoc """
  """

  use GenServer
  
  require Logger
  
  
  
  @typedoc """
  A policy is simply a standard module. Nothing special.
  """
  @type policy :: module()




  @doc false
  def start_link() do
    GenServer.start_link(__MODULE__, %Rampart.PolicyState{}, name: Rampart.PolicyFinder)
  end

  @doc false
  def init(state) do
    policies = load_all_policies()
    { :ok, %{ state | policies: policies } }
  end

  @doc """
  Attempts to find the policy that matches the module
  or resource specified. If no policy can be found, this
  function will return `nil`. Otherwise, the policy will
  be returned.
  """
  @spec find(module() | struct()) :: policy() | nil
  def find(nil), do: nil
  def find(resource) do
    GenServer.call(Rampart.PolicyFinder, { :find, resource })
  end





  #
  # Retrieves all modules that implement the 
  # Rampart.Policy behaviour. These will be
  # used later for quick access to the policies
  # when needed.
  #
  defp load_all_policies() do
    # All credit of this function goes to BitWalker
    # http://stackoverflow.com/questions/36433481/find-all-modules-that-adopted-behavior
    Mix.Task.run("loadpaths", [])

    Path.wildcard(Path.join([Mix.Project.build_path, "**/ebin/**/*.beam"]))
    # Parse the BEAM for behaviour implementations
    |> Stream.map(fn path ->
      {:ok, {mod, chunks}} = :beam_lib.chunks('#{path}', [:attributes])
      {mod, get_in(chunks, [:attributes, :behaviour])}
    end)
    # Filter out behaviours we don't care about and duplicates
    |> Stream.filter(fn {_mod, behaviours} -> is_list(behaviours) && Rampart.Policy in behaviours end)
    |> Enum.uniq
    |> Enum.reduce(%{}, fn({module, _}, acc) -> 
      Map.put(acc, policy_lookup_key(module), module) 
    end)
  end

  # Given a policy module in the form [resource_name]Policy,
  # returns the [resource_name] part. This is used to form
  # a resource to policy mappings for faster lookup in the
  # future.
  defp policy_lookup_key(module) do
    Module.split(module)
    |> List.last
    |> String.replace_suffix("Policy", "")
  end


  @doc false
  def handle_call({ :find, resource }, _from, %{ policies: policies } = state) when is_atom(resource) do
    policy = find_policy(resource, resource, policies)
    { :reply, policy, state }
  end

  @doc false
  def handle_call({ :find, resource }, _from, %{ policies: policies } = state) do
    policy =
      resource.__struct__
      |> find_policy(resource, policies)

    { :reply, policy, state }
  end


  defp find_policy(module, resource, policies) do
    Code.ensure_loaded(module)
    
    cond do
      :erlang.function_exported(module, :policy, 0) ->
        # The module is overriding the `policy/0` function so invoke that
        apply(module, :policy, [])

      :erlang.function_exported(module, :policy, 1) ->
        # The module is overriding the `policy/1` function, so invoke that
        apply(module, :policy, [resource])

      true ->
        policy_key =
          module
          |> Module.split
          |> List.last

        # No overriding, so nice and simple.
        Map.get(policies, policy_key)
    end
  end

end