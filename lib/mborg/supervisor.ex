defmodule Mborg.Mborg.Supervisor do
  use Supervisor
  alias Mborg.Mborg.{ControllerState, CommandTimer, PhysicsParams}

  def start_link do
  Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(ControllerState, []),
      worker(PhysicsParams, []),
      # worker(CommandTimer, []),
      worker(Picam.Camera, [])
      # worker(Board, []),
      # worker(JstickBoard, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
