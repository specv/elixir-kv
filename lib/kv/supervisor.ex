defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      # With this in place, the supervisor will now start KV.Registry by calling KV.Registry.start_link(name: KV.Registry).
      # If you revisit the KV.Registry.start_link/1 implementation, you will remember it simply passes the options to GenServer
      {KV.Registry, name: KV.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
