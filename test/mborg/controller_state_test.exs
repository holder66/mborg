defmodule Mborg.ControllerStateTest do
  use ExUnit.Case
  alias Mborg.ControllerState
  doctest Mborg

  # test "get and set turning direction and power" do
  #   direction = -1
  #   power = 128
  #
  #   ControllerState.set_direction(direction, power)
  #
  #   retrieved_power = ControllerState.get_direction()
  #
  #   assert power == retrieved_power
  # end


  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(Mborg.ControllerState)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert Mborg.ControllerState.lookup(registry, "shopping") == :error

    Mborg.ControllerState.create(registry, "shopping")
    assert {:ok, bucket} = Mborg.ControllerState.lookup(registry, "shopping")

    # Mborg.ControllerState.put(bucket, "milk", 1)
    # assert Mborg.ControllerState.get(bucket, "milk") == 1
  end
end
