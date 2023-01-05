defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    # The start_supervised! function was injected into our test module by use ExUnit.Case.
    # It does the job of starting the KV.Registry process, by calling its start_link/1 function.
    # The advantage of using start_supervised! is that ExUnit will guarantee that the registry
    # process will be shutdown before the next test starts. In other words, it helps guarantee
    # that the state of one test is not going to interfere with the next one in case they depend
    # on shared resources.

    # TODO:
    # Since we have changed our registry to use KV.BucketSupervisor, our tests are now relying on this
    # shared supervisor even though each test has its own registry. The question is: should we?
    # It depends. It is ok to rely on shared state as long as we depend only on a non-shared partition
    # of this state. Although multiple registries may start buckets on the shared bucket supervisor,
    # those buckets and registries are isolated from each other. We would only run into concurrency
    # issues if we used a function like DynamicSupervisor.count_children(KV.BucketSupervisor) which
    # would count all buckets from all registries, potentially giving different results when tests
    # run concurrently.

    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    # Stop the bucket with non-normal reason
    Agent.stop(bucket, :shutdown)
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
