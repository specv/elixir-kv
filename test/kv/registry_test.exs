defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    # The start_supervised! function was injected into our test module by use ExUnit.Case.
    # It does the job of starting the KV.Registry process, by calling its start_link/1 function.
    # The advantage of using start_supervised! is that ExUnit will guarantee that the registry
    # process will be shutdown before the next test starts. In other words, it helps guarantee
    # that the state of one test is not going to interfere with the next one in case they depend
    # on shared resources.
    registry = start_supervised!(KV.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end
end
