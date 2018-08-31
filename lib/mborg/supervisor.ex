defmodule Mborg.Mborg.Supervisor do
  use Supervisor
  alias Mborg.Mborg.{Controller, Ps3Joystick, Board, ControllerState}

  def start_link do
  Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Controller, []),
      worker(Ps3Joystick, []),
      worker(Board, []),
      worker(ControllerState, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
