defmodule Mborg.Ps3Joystick do
  use GenServer

  alias Joystick
  alias Joystick.Event
  alias Mborg.ThunderborgBoard.{Board, LedWave, MotorSequence}

  # start with: iex(1)> {:ok, js} = Mborg.Ps3Joystick.start_link([])

  # stop a running joystick genserver process with: iex(2)> Joystick.stop(js)

  # Joystick/controller number mappings:
  # Mappings for PS3 controller buttons:

  @bx 0
  @bcircle 1
  @btriangle 2
  @bsquare 3
  @bl1 4
  @br1 5
  @bl2 6
  @br2 7
  @bselect 8
  @bstart 9
  @bps 10
  @bljstick 11
  @brjstick 12
  @bup 13
  @bdown 14
  @bleft 15
  @bright 16

  # Mappings for PS3 controller axes:

  @axljsticklr 0
  @axljstickud 1
  @axl2 2
  @axrjsticklr 3
  @axrjstickud 4
  @axr2 5




  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end


  # Callbacks

  def init([]) do
    {:ok, js} = Joystick.start_link(0, self())
    state = %{js: js}
    {:ok, state}
  end

  def handle_info({:joystick, %Event{number: nmbr, type: type, value: val}}, state) do
    # IO.puts "got joystick event: number: #{nmbr} type: #{type} #{val}"
    event = [nmbr, type, val]
    IO.inspect event
    case event do
      # use the "select" button to run the motor sequence
      [@bselect, :button, 1] -> MotorSequence.sequence
      # use the "start" button to do the LED wave, and enable the motor control
      [@bstart, :button, 1] -> LedWave.wave
      # use the PS button to stop the joystick process
      [@bps, :button, 1] -> stop_joystick(state)
      _ -> true
    end

    {:noreply, state}
  end

  defp stop_joystick(state) do
    IO.inspect state
    Joystick.stop(state.js)
  end
end
