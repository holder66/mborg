defmodule Mborg.Supervisor do
  use Supervisor
  alias Mborg.{Controller, Ps3Joystick, Board}

  def start_link do
    Mborg.Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Controller, []),
      worker(Ps3Joystick, []),
      worker(Board, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
