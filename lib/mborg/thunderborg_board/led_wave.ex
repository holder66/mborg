defmodule Mborg.ThunderborgBoard.LedWave do
  @moduledoc """
  This script shows a soothing wave pattern using the LEDs.
  It shows how the LEDs can be controlled to produce a large
  range of vivid colours.
  Run using:
  cd ~/tborg
  iex -S mix
  Tborg.TbLedWave.wave()
  """

  alias Mborg.ThunderborgBoard.Board

  @doc """
  Cycle through a range of values to set led colour to
  slightly different values each time.
  """
  def wave(pid \\ Board.start_link()) do
    if Board.get_led_monitor_state(pid) == 1 do
      Board.toggle_led_control(pid)
    end
    for i <- 1..300 do
      hue = i / 100
      Board.set_led(pid,scale(red(hue)),scale(green(hue)),scale(blue(hue)))
      # IO.inspect([hue,red(hue),green(hue),blue(hue)])
      Process.sleep(20)
    end
    Board.toggle_led_control(pid)
  end

  defp scale(x) do
    round(x * 255)
  end



  defp red(hue) do
    cond do
      hue < 1.0 -> 1.0 - hue
      hue < 2.0 -> 0.0
      true -> hue - 2.0
    end
  end

  defp green(hue) do
    cond do
      hue < 1.0 -> hue
      hue < 2.0 -> 2.0 - hue
      true -> 0.0
    end
  end

  defp blue(hue) do
    cond do
      hue < 1.0 -> 0.0
      hue < 2.0 -> hue - 1.0
      true -> 3.0 - hue
    end
  end


end
