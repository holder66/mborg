defmodule Mborg.ThunderborgBoard.Board do
  @moduledoc """
  Library for controlling the ThunderBorg motor control board. Makes use of
  the I2C functions in elixir_ale.
  """

  require ElixirALE.I2C
  require Logger

  alias ElixirALE.I2C

  # Constant values
  @i2c_slave                   0x0703
  @pwm_max                     255
  @i2c_max_len                 6
  @voltage_pin_max             36.3  # Maximum voltage from the analog voltage monitoring pin
  @voltage_pin_correction      0.0   # Correction value for the analog voltage monitoring pin
  @battery_min_default         7.0   # Default minimum battery monitoring voltage
  @battery_max_default         35.0  # Default maximum battery monitoring voltage
  @i2c_id_thunderborg          0x15

  @command_set_led1            1     # Set the colour of the ThunderBorg LED
  @command_get_led1            2     # Get the colour of the ThunderBorg LED
  @command_set_led2            3     # Set the colour of the ThunderBorg Lid LED
  @command_get_led2            4     # Get the colour of the ThunderBorg Lid LED
  @command_set_leds            5     # Set the colour of both the LEDs
  @command_set_led_batt_mon    6     # Set the colour of both LEDs to show the current battery level
  @command_get_led_batt_mon    7     # Get the state of showing the current battery level via the LEDs
  @command_set_a_fwd           8     # Set motor A PWM rate in a forwards direction
  @command_set_a_rev           9     # Set motor A PWM rate in a reverse direction
  @command_get_a               10    # Get motor A direction and PWM rate
  @command_set_b_fwd           11    # Set motor B PWM rate in a forwards direction
  @command_set_b_rev           12    # Set motor B PWM rate in a reverse direction
  @command_get_b               13    # Get motor B direction and PWM rate
  @command_all_off             14    # Switch everything off
  @command_get_drive_a_fault   15    # Get the drive fault flag for motor A, indicates faults such as short-circuits and under voltage
  @command_get_drive_b_fault   16    # Get the drive fault flag for motor B, indicates faults such as short-circuits and under voltage
  @command_set_all_fwd         17    # Set all motors PWM rate in a forwards direction
  @command_set_all_rev         18    # Set all motors PWM rate in a reverse direction
  @command_set_failsafe        19    # Set the failsafe flag, turns the motors off if communication is interrupted
  @command_get_failsafe        20    # Get the failsafe flag
  @command_get_batt_volt       21    # Get the battery voltage reading
  @command_set_batt_limits     22    # Set the battery monitoring limits
  @command_get_batt_limits     23    # Get the battery monitoring limits
  @command_write_external_led  24    # Write a 32bit pattern out to SK9822 / APA102C
  @command_get_id              0x99  # Get the board identifier
  @command_set_i2c_add         0xAA  # Set a new I2C address

  @command_value_fwd           1     # I2C value representing forward
  @command_value_rev           2     # I2C value representing reverse

  @command_value_on            1     # I2C value representing on
  @command_value_off           0     # I2C value representing off

  @command_analog_max          0x3FF # Maximum value for analog readings

  @doc """
  Start a link to the ThunderBorg board.
  """
  def start_link(devname \\ "i2c-1", address \\ @i2c_id_thunderborg) do
    {:ok, pid}=I2C.start_link(devname, address)
    pid
  end

  @doc """
  Query the ThunderBorg board for the current battery voltage.
  """
  def get_battery_reading(pid, addr \\ @command_get_batt_volt) do
    I2C.write(pid, <<addr>>)
    <<21, x, y>> = I2C.read(pid, 3)
    (x * 256 + y) / @command_analog_max * @voltage_pin_max + @voltage_pin_correction
  end

  @doc """
  Toggle the state of the ThunderBorg board setting for controlling LED colour by battery voltage.
  """
  def toggle_led_control(pid, testAddr \\ @command_get_led_batt_mon, setAddr \\ @command_set_led_batt_mon) do
    # read current state
    I2C.write(pid, <<testAddr>>)
    <<_, flag>> = I2C.read(pid,2)
    I2C.write(pid, <<setAddr, rem(flag+1,2)>>)
  end

  @doc """
  Test the state of the LED display: returns 1 if LEDs are monitoring
  the battery voltage, returns 0 otherwise.
  """
  def get_led_monitor_state(pid, addr \\ @command_get_led_batt_mon) do
    I2C.write(pid, <<addr>>)
    <<_, flag>> = I2C.read(pid, 2)
    flag
  end

  @doc """
  Set the current colour of the ThunderBorg LED. r, g, b may each be between 0 and 255.
  set_led(n, 0, 0, 0)     -> LED n off
  set_led(n, 255, 255, 255)     -> LED n full white
  """
  def set_led(pid,r,g,b,addr \\ @command_set_leds) do
    I2C.write(pid, <<addr,r,g,b>>)
  end


  @doc """
  Get the current colour of the ThunderBorg board LED 1.
  """
  def get_led1(pid, addr \\ @command_get_led1) do
    I2C.write(pid, <<addr>>)
    I2C.read(pid,4)
  end

  @doc """
  Get the current colour of the ThunderBorg board LED 2.
  """
  def get_led2(pid, addr \\ @command_get_led2) do
    I2C.write(pid, <<addr>>)
    I2C.read(pid,4)
  end

  @doc """
  Set the system to communications failsafe if flag = 1
  (ie, turn off the motors unless a command is received at least every 1/4 second).
  Turn off communication failsafe if flag = 0.
  Note that the LEDs will flash if failsafe is on and no commands are being
  received.
  """
  def set_comm_failsafe(pid, flag, addr \\ @command_set_failsafe) do
    I2C.write(pid, <<addr, flag>>)
  end

  @doc """
  Set the drive level and direction for motor n.
  motorNumber = 1 for motor 1, 2 for motor 2, 0 for both motors.
  dir = 1 for forward, -1 for reverse.
  power is a number between 0 and 255.
  """
  def command_motor(pid, motorNumber \\ 0, dir \\ 1, power \\ 64) do
    command =
      case {motorNumber, dir} do
        {0, 1} ->  @command_set_all_fwd
        {0, -1} -> @command_set_all_rev
        {1, 1} -> @command_set_a_fwd
        {1, -1} -> @command_set_a_rev
        {2, 1} -> @command_set_b_fwd
        {2, -1} -> @command_set_b_rev
        {_, _} -> @command_all_off
      end
    I2C.write(pid, <<command, power>>)
  end

  @doc """
  Stop everything!
  """
  def off(pid) do
    I2C.write(pid, <<@command_all_off, 0>>)
  end


end
