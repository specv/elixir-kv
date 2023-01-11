defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      # Since KV.Registry invokes KV.BucketSupervisor, then the KV.BucketSupervisor must be started before KV.Registry.
      # Otherwise, it may happen that the registry attempts to reach the bucket supervisor before it has started.
      {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      # With this in place, the supervisor will now start KV.Registry by calling KV.Registry.start_link(name: KV.Registry).
      # If you revisit the KV.Registry.start_link/1 implementation, you will remember it simply passes the options to GenServer
      {KV.Registry, name: KV.Registry},
      # Task.Supervisor.async({KV.RouterTasks, :"foo@computer-name"}, Kernel, :node, [])
      {Task.Supervisor, name: KV.RouterTasks},
    ]

    # If KV.Registry dies, all information linking KV.Bucket names to bucket processes is lost. Therefore
    # the KV.BucketSupervisor and all children must terminate too - otherwise we will have orphan processes.
    Supervisor.init(children, strategy: :one_for_all)
  end
end
