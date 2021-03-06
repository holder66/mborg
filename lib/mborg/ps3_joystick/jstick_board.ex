defmodule Mborg.Mborg.JstickBoard do
  @moduledoc """
  The PS3 Controller buttons and joysticks do the following:
  left joystick: move forward and back to control forward or reverse power
  right joystick: move left or right to steer the MonsterBorg
  Button actions:
  select: shuts down the Monsterborg
  PS: stops both motors
  start: displays this help text on the monitor
  X: display battery voltage
  triangle: display communications failsafe status
  circle: toggle communications failsafe status
  up and down arrows: adjust turnpowerparameter value
  left and right arrows: adjust turnparameter value
  """
  use GenServer

  alias Joystick
  alias Joystick.Event
  alias Mborg.Mborg.{Board, ControllerState, CommandTimer, PhysicsParams}

  # start with: iex(1)> {:ok, js} = Mborg.JstickBoard.start_link([])

  # stop a running joystick genserver process with: iex(2)> Joystick.stop(js)

  # Motor Control mappings
  @leftmotor 2
  @rightmotor 1
  @motorpolarity -1
  #  @maxmotorpower 255

  # Joystick/controller number mappings:
  # Mappings for PS3 controller buttons:

    @bx 0
    @bcircle 1
    @btriangle 2
    # @bsquare 3
#   @bl1 4
#   @br1 5
#   @bl2 6
#   @br2 7
    @bselect 8
    @bstart 9
    @bps 10
#   @bljstick 11
#   @brjstick 12
    @bup 13
    @bdown 14
    @bleft 15
    @bright 16

  # Mappings for PS3 controller axes:

  # @axljsticklr 0
    @axljstickud 1
  # @axl2 2
    @axrjsticklr 3
  # @axrjstickud 4
  # @axr2 5

  # Attributes for joystick direction
  @upispositive 1
  @rightispositive -1

  # Attributes for MonsterBorg physics: adjust these values to control turning radius at different speeds
  # @turnthreshold (0.03 * @maxmotorpower)
  @turnparameter 0.15
  @turnpowerparameter 0.35
  @adjustparam 0.05

  def run do
    {:ok, _pid} = start_link([])
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  # Callbacks

  def init([]) do
    # start the thunderborg board
    pid = Board.start_link
    {:ok, js} = Joystick.start_link(0, self())
    IO.puts "Connecting to the PS3 controller"
    state = %{js: js, board: pid}
    IO.puts "Firing up the Thunderborg Board"
    Board.get_battery_monitor_limits(pid)
    # Board.set_battery_monitor_limits(pid, 77, 85)
    # Restore physics parameter values to their defaults
    PhysicsParams.set_state({@turnparameter, @turnpowerparameter})
    Process.sleep(1000)
    # {turnparameter, turnpowerparameter} = PhysicsParams.get_state()
    # IO.puts("Default turnparameter: #{turnparameter}, turnpowerparameter: #{turnpowerparameter}")
    {:ok, state}
  end

  def handle_info({:joystick, %Event{number: nmbr, type: type, value: val}}, state) do
    # IO.puts "got joystick event: number: #{nmbr} type: #{type} #{val}"
    event = [nmbr, type, val]
    # IO.inspect [event]
    board_pid = state.board
    case event do
      # if an axis event, do motors
      [_, :axis, _] -> control_motors(board_pid, event)
      # use the arrow buttons to adjust the physics parameters up and down; left and right
      # arrows control the turnparameter state; up and down buttons for the turnpowerparameter.
      [@bleft, :button, 1] -> adjust_parameter(:turnparameter, :down)
      [@bright, :button, 1] -> adjust_parameter(:turnparameter, :up)
      [@bup, :button, 1] -> adjust_parameter(:turnpowerparameter, :up)
      [@bdown, :button, 1] -> adjust_parameter(:turnpowerparameter, :down)
      # use the "X" button to report battery voltage
      [@bx, :button, 0] -> show_board_voltage(board_pid)
      # use the "start" button to display help information on stdout
      [@bstart, :button, 1] -> display_controller_help()
      # use the "triangle" button to report on the communications failsafe status
      [@btriangle, :button, 0] -> report_comm_failsafe_status(board_pid)
      # use the "circle" button to toggle communications failsafe status
      [@bcircle, :button, 0] -> toggle_comm_failsafe_status(board_pid)
      # use the "select" button to shut down the raspi
      [@bselect, :button, 0] -> halt_raspi(board_pid)
      # use the PS button to stop the motors
      [@bps, :button, 1] -> stop_motors(board_pid)
      # on button release, go back to monitoring battery voltage
      [_, :button, 0] -> leds_monitor_battery(board_pid)
      _ -> true
    end

    {:noreply, state}
  end

  def handle_info({:event,_}, state) do
    IO.inspect System.monotonic_time(10)

    {:noreply, state}
  end

  defp adjust_parameter(parameter, change) do
    {turnparameter, turnpowerparameter} = PhysicsParams.get_state()
    # IO.inspect [turnparameter, turnpowerparameter]
    case {parameter, change} do
      {:turnparameter, :up} ->
        PhysicsParams.set_state({turnparameter + @adjustparam, turnpowerparameter})
      {:turnparameter, :down} ->
        PhysicsParams.set_state({turnparameter - @adjustparam, turnpowerparameter})
      {:turnpowerparameter, :up} ->
        PhysicsParams.set_state({turnparameter, turnpowerparameter + @adjustparam})
      {:turnpowerparameter, :down} ->
        PhysicsParams.set_state({turnparameter, turnpowerparameter - @adjustparam})
      {_,_} -> true
    end
    {turnparameter, turnpowerparameter} = PhysicsParams.get_state()
    IO.puts("Updated turnparameter: #{turnparameter}, turnpowerparameter: #{turnpowerparameter}")
  end

  defp control_motors(board_pid, [number, _, value]) do
    # IO.inspect [number, direction(value), round(abs(value)/(999/255))]
    # @axljstickud controls forward and backward, @axljsticklr controls turning
    # also correct the direction signs to give up as positive, right as positive
    # IO.inspect System.monotonic_time(10)
    dir = direction(value)
    power = motor_power(value)
    case number do
      #if a turn joystick event
      @axrjsticklr -> do_turn_event(board_pid, dir * @rightispositive, power)
      # if a forward/backward joystick event
      @axljstickud -> do_forward_event(board_pid, dir * @upispositive * @motorpolarity, power)
      _ -> true
      # _ -> IO.inspect "unused axis event"
    end
  end

  # for a turn joystick event, get the previous state, operate the motors
  # using the previous forward direction and power with the new turn
  # direction and power, and save the new state
  defp do_turn_event(board_pid, turndirection, turnpower) do
    # IO.inspect ["turn: ", turndirection, turnpower]
    {forwarddirection, forwardpower, _oldturndirection, _oldturnpower} = ControllerState.get_state()
    # if forward power is close to 0, stop the motors
    if forwardpower < 2 do
      stop_motors(board_pid)
      # Board.off(board_pid)
    else
      operate_motors(board_pid, forwarddirection, forwardpower, turndirection, turnpower)
      ControllerState.set_state({forwarddirection, forwardpower, turndirection, turnpower})
    end
  end

  # for a forward or backward joystick event, get the previous state, operate
  # the motors using the previous turn direction and power and the new forward/backward
  # direction and power, and save the new state
  defp do_forward_event(board_pid, forwarddirection, forwardpower) do
    # IO.inspect ["fwd  ", forwarddirection, forwardpower]
    # if forwardpower is close to 0, stop the motors
    if forwardpower < 0 do
      stop_motors(board_pid)
      # Board.off(board_pid)
    else
      {_oldforwarddirection, _oldforwardpower, turndirection, turnpower} = ControllerState.get_state()
      operate_motors(board_pid, forwarddirection, forwardpower, turndirection, turnpower)
      ControllerState.set_state({forwarddirection, forwardpower, turndirection, turnpower})
    end
  end


  defp operate_motors(board_pid, forwarddirection, forwardpower, turndirection, turnpower) do
    # if if turn power is less than @turnthreshold, run both motors with one command
    # IO.inspect System.monotonic_time(10)
    if turnpower == 0 do
      Board.command_motor(board_pid, 0, forwarddirection, motor_power_value(constrain(forwardpower)))
    else
      {leftdir, leftpwr, rightdir, rightpwr} = monsterborg_physics(forwarddirection, forwardpower, turndirection, turnpower)
      Board.command_motor(board_pid, @leftmotor, leftdir, motor_power_value(leftpwr))
      Board.command_motor(board_pid, @rightmotor, rightdir, motor_power_value(rightpwr))
    end
  end

  defp motor_power_value(value), do: round(value * 2.55)

  defp monsterborg_physics(forwarddirection, forwardpower, turndirection, turnpower) do
    # when turnpower is greater than threshold, decrease power on the turning side, and
    # increase power on the opposide side, up to the maximum for the motors.
    # the amount of increase/decrease is typically balanced, but we may need a "trim".
    # coefficient for increase/decrease can be varied.
    # consider using a button to make "tank" type turns, where the direction of the
    # motors on the opposide side of the turn reverses.
    # to facilitate playing around with the physics, we will use integers from 0 to 100
    # for power values
    # IO.inspect ["physics: ", forwarddirection, forwardpower, turndirection, turnpower]
    # get values for turnparameter and turnpowerparameter
    {turnparameter, turnpowerparameter} = PhysicsParams.get_state()
    # IO.inspect [turnparameter, turnpowerparameter]
    poweradjust = round(turnpower * turnpowerparameter + forwardpower * turnparameter)
    leftpwr = constrain(forwardpower - turndirection * poweradjust)
    rightpwr = constrain(forwardpower + turndirection * poweradjust)
    # IO.inspect [leftpwr, rightpwr]
    {forwarddirection, leftpwr, forwarddirection, rightpwr}
  end

  defp display_controller_help do
    IO.puts @moduledoc
  end

  # constrain the upper limit for power to 95%, so as to limit the voltage drop to the processor
  defp constrain(value, lowerlimit \\ 0, upperlimit \\ 95) do
    cond do
      value < lowerlimit -> lowerlimit
      value > upperlimit -> upperlimit
      true -> value
    end
  end

  defp motor_power(joystickvalue), do: round(abs(joystickvalue)/10)

  defp direction(val) do
    cond do
      val != 0 -> round(val / abs(val))
      true -> 1
    end
  end

  defp set_LEDs(pid, color) do
    color_values = %{green: [0,255,0], blue: [0,0,255], red: [255,0,0], pink: [255,51,51], off: [0,0,0]}
    {:ok, [r,g,b]} = Map.fetch(color_values, color)
    # if the LEDs are being controlled by battery voltage, toggle their state
    if Board.get_led_monitor_state(pid) do
      Board.toggle_led_control(pid)
    end
    Board.set_led(pid,r,g,b)
  end

  defp leds_monitor_battery(pid) do
    # if the LEDs are not being controlled by battery voltage, toggle their state
    if Board.get_led_monitor_state(pid) == 0
     do
      Board.toggle_led_control(pid)
    end
  end

  defp show_board_voltage(pid) do
    voltage = Board.get_battery_reading(pid)
    IO.puts("ThunderBorg board voltage: #{(round(voltage*100))/100}")
  end

  defp report_comm_failsafe_status(pid) do
    <<_, status>> = Board.get_comm_failsafe(pid)
    IO.puts("Communications Failsafe Status: #{status}")
  end

  defp toggle_comm_failsafe_status(pid) do
    <<_, status>> = Board.get_comm_failsafe(pid)
    Board.set_comm_failsafe(pid, abs(status - 1))
    report_comm_failsafe_status(pid)
  end

  defp halt_raspi(pid) do
    # set LEDs off
    set_LEDs(pid, :off)
    IO.puts("Shutting the Raspberry Pi down now!")
    System.cmd("sudo", ["halt"])
  end

  defp stop_motors(board_pid) do
    # IO.puts("Stopping all motors!")
    Board.off(board_pid)
    # reset the controller state
    ControllerState.set_state({0, 0, 0, 0})
    # stop_joystick(state)
  end

end
