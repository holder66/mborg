defmodule Mborg.Mborg.ThunderborgBoard.MotorSequence do
  @moduledoc """
  Simple example of a motor sequence script.
  Run using:
  cd ~/tborg
  iex -S mix
  Tborg.TbMotorSequence.sequence()
  Note: the motor sequence used here was copied from the script
  "tbSequence.py" on the piborg.org website.
  """

  alias Mborg.Mborg.ThunderborgBoard.Board


  @doc """

  """
  def sequence() do
    # Set our sequence, pairs of motor 1 and motor 2 drive levels
    motorSequence = [
                  [+0.2, +0.2],
                  [+0.4, +0.4],
                  [+0.6, +0.6],
                  [+0.8, +0.8],
                  [+1.0, +1.0],
                  [+0.6, +1.0],
                  [+0.2, +1.0],
                  [-0.2, +1.0],
                  [-0.6, +1.0],
                  [-1.0, +1.0],
                  [-0.6, +0.6],
                  [-0.2, +0.2],
                  [+0.2, -0.2],
                  [+0.6, -0.6],
                  [+1.0, -1.0],
                  [+0.6, -0.6],
                  [+0.3, -0.3],
                  [+0.1, -0.1],
                  [+0.0, +0.0],
                 ]
    stepDelay = 1000  # number of milliseconds between each step
    pid = Board.start_link()
    # IO.inspect(motorSequence)
    sequence_p(pid,motorSequence,stepDelay)
  end

  defp sequence_p(pid, motorSequence, stepDelay) do
    for [val1, val2] <- motorSequence do
      if val1 == val2 do
        Board.command_motor(pid, 0, direction(val1), power(val1))
      else
        Board.command_motor(pid, 1, direction(val1), power(val1))
        Board.command_motor(pid, 2, direction(val2), power(val2))
      end
      Process.sleep(stepDelay)
    end
  end

  defp direction(val) do
    cond do
      val != 0 -> round(val / abs(val))
      true -> 1
    end
  end

  defp power(val) do
    round(abs(val * 255))
  end
end
