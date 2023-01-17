defmodule KV.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed
  test "route requests across nodes" do
    {:ok, hostname} = :inet.gethostname()
    assert KV.Router.route("hello", Kernel, :node, []) ==
             :"foo@#{hostname}"
    assert KV.Router.route("world", Kernel, :node, []) ==
             :"bar@#{hostname}"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      KV.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
