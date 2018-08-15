defmodule Supervisor do
  use Supervisor

  def start_link do
    Mborg.Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      supervisor(Mborg.Supervisor, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
