defmodule KV.Bucket do


  # There is a resource leakage in our application. When a bucket terminates,
  # the dynamic supervisor will start a new bucket in its place. After all,
  # that’s the role of the supervisor!

  # However, when the supervisor restarts the new bucket, the registry does
  # not know about it. So we will have an empty bucket in the supervisor that
  # nobody can access! To solve this, we want to say that buckets are actually
  # temporary. If they crash, regardless of the reason, they should not be restarted.

  # At this point, you may be wondering why use a supervisor if it never restarts its
  # children. It happens that supervisors provide more than restarts, they are also
  # responsible for guaranteeing proper startup and shutdown, especially in case of
  # crashes in a supervision tree.

  # Tools like Observer (`:observer.start`) are one of the reasons you want to always
  # start processes inside supervision trees, even if they are temporary, to ensure
  # they are always reachable and introspectable.

  # calling use generates a `child_spec` function with default configuration
  use Agent, restart: :temporary

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
