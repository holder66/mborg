# mborg

Mborg is an Elixir project to control a MonsterBorg robot, initially
with a joystick over bluetooth, but with the eventual goal of having an
autonomous vehicle which can follow a track using input from its front-
mounted Pi Camera. This will require development of Artificial Intelligence
based on work I've previously done on a nearest neighbour classifier using
Hamming distances and neural network designs.

## Usage

1. Plug your PS3 controller in to one of the USB ports on the raspi.
2. Power up the ThunderBorg board with the tiny switch on the board.
3. The four lights on the controller should be blinking slowly. Press the PS
button on the controller until light one comes on steady.
4. In a terminal on your computer, ssh in to the MonsterBorg, eg: `ssh pi@10.0.1.60`
5. Switch directories to mborg: pi@monsterborg:~ $ `cd mborg`
6. Compile the project and open IEx: pi@monsterborg:~/mborg $ `iex -S mix`. Note that
the ThunderBorg board has to powered up for the compilation step to run.
7. iex(1)> `Mborg.run`
8. Test for correct functioning by using the four right-hand buttons marked with
a triangle, circle, etc to flash the ThunderBorg LEDs the color corresponding to
the color on the button.
9. Use the left joystick to control the motors.
10. You should now be able to unplug the controller from the raspi. This may
crash the process. If so, restart with Mborg.run. The controller should now
operate the MonsterBorg over bluetooth.
11. If you get a "[warn]  Got late event...", message, try unplugging the controller
if it's still connected, and restart with Mborg.run. If this does not help, you 
may need make a change to a source file (eg a comment), recompile, and
restart with Mborg.run.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `mborg` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:mborg, "~> 0.1.0"}]
    end
    ```

  2. Ensure `mborg` is started before your application:

    ```elixir
    def application do
      [applications: [:mborg]]
    end
    ```
