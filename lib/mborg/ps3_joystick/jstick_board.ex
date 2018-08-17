defmodule Mborg.JstickBoard do
  use GenServer

  alias Joystick
  alias Joystick.Event
  alias Mborg.ThunderborgBoard.{Board}

  # start with: iex(1)> {:ok, js} = Mborg.JstickBoard.start_link([])

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
    # start the thunderborg board
    pid = Board.start_link()
  end


  # Callbacks

  def init([]) do
    # start the thunderborg board
    pid = Board.start_link()
    {:ok, js} = Joystick.start_link(0, self())
    state = %{js: js, board: pid}
    {:ok, state}
  end

  def handle_info({:joystick, %Event{number: nmbr, type: type, value: val}}, state) do
    # IO.puts "got joystick event: number: #{nmbr} type: #{type} #{val}"
    event = [nmbr, type, val]
    # IO.inspect [event]
    board_pid = state.board
    # IO.inspect board_pid
    case event do
      # if a shape button is pressed, flash the LEDs the corresponding color
      [@btriangle, :button, _] -> set_LEDs(board_pid, :green)
      [@bx, :button, _] -> set_LEDs(board_pid, :blue)
      [@bsquare, :button, _] -> set_LEDs(board_pid, :pink)
      [@bcircle, :button, _] -> set_LEDs(board_pid, :red)
      # use the "select" button to shut down the raspi
      [@bselect, :button, 0] -> System.cmd("sudo halt", [])
      # use the PS button to stop the motors
      [@bps, :button, 1] -> Board.off(board_pid)
      # if an axis event, do motors
      [_, :axis, _] -> control_motors(board_pid, event)
      _ -> true
    end


    {:noreply, state}
  end

  defp control_motors(board_pid, [number, _, value]) do
    # IO.inspect [number, direction(value), round(abs(value)/(999/255))]
    # @axljstickud controls forward and backward, @axljsticklr controls turning
    dir = direction(value)
    power = round(abs(value)/(999/255))
    case number do
      @axljstickud -> both_motors(board_pid, dir, power)
      _ -> true
    end
  end

  defp both_motors(board_pid, direction, power) do
    Board.command_motor(board_pid, 1, direction, power)
    Board.command_motor(board_pid, 2, direction, power)
  end

  defp direction(val) do
    cond do
      val != 0 -> -1 * round(val / abs(val))
      true -> -1
    end
    # val * -1 # since the joystick axis is inverted
  end

  defp set_LEDs(pid, color) do
    color_values = %{green: [0,255,0], blue: [0,0,255], red: [255,0,0], pink: [255,51,51]}
    {:ok, [r,g,b]} = Map.fetch(color_values, color)
    # IO.inspect [pid, color, r, g, b]
    Board.toggle_led_control(pid)
    Board.set_led(pid,r,g,b)
  end

  defp stop_everything(board_pid, state) do
    Board.off(board_pid)
    # stop_joystick(state)
  end

  defp stop_joystick(state) do
    IO.inspect state
    Joystick.stop(state.js)
  end
end
