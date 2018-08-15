defmodule Mborg.Controller do
  @moduledoc """
  Control the ThunderBorg motor control board using the joystick.

  """
  alias Mborg.Ps3Joystick
  alias Mborg.ThunderborgBoard.{Board, LedWave}

  def run do
    pid = Board.start_link
    voltage = Board.get_battery_reading(pid)
    IO.puts("ThunderBorg board voltage: #{(round(voltage*100))/100}")
    # IO.inspect pid
    IO.puts "Doin' the LED wave..."
    LedWave.wave(pid)
    Board.toggle_led_control(pid)
    {:ok, js} = Ps3Joystick.start_link([])
    js
  end


end
Mborg.Controller.run
