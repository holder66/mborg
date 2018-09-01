defmodule Mborg.Mborg.Supervisor do
  use Supervisor
  alias Mborg.Mborg.{JstickBoard, Board, ControllerState}

  def start_link do
  Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(ControllerState, []),
      worker(JstickBoard, []),
      worker(Board, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
