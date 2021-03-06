# mborg

Mborg is an Elixir project to control a MonsterBorg robot, initially
with a joystick over bluetooth, but with the eventual goal of having an
autonomous vehicle which can follow a track using input from its front-
mounted Pi Camera. This will require development of Artificial Intelligence
based on work I've previously done on a nearest neighbour classifier using
Hamming distances and neural network designs.

## Usage

1. Plug your PS3 controller in to one of the USB ports on the raspi.
2. Power up the ThunderBorg board with the tiny switch on the board. Wait a couple of minutes.
3. The four lights on the controller should be blinking slowly. Press the PS
button on the controller. The four lights should blink rapidly and then stop, with
one light remaining on (or possibly none).
4. In a terminal on your computer, ssh in to the MonsterBorg, eg: `ssh pi@10.0.1.60`
5. Switch directories to mborg: pi@monsterborg:~ $ `cd mborg`
6. Compile the project and open IEx: pi@monsterborg:~/mborg $ `iex -S mix`.
7. iex(1)> `Mborg.run`
8. Test for correct functioning by pressing the right-hand button marked with a purple "X".
This should display a message in your terminal giving the Thunderborg board voltage.
9. Press the "start" button to get a help message in your terminal.
10. You should now be able to unplug the controller from the raspi. This may
crash the process. If so, restart with Mborg.run. The controller should now
operate the MonsterBorg over bluetooth.
11. If you get a "[warn]  Got late event...", message, try unplugging the controller
if it's still connected, and restart with Mborg.run. Waiting for a few minutes before retrying also seems to work.


## Installation

  1. Add `mborg` to your list of dependencies in `mix.exs`:

    ```elixir
		def deps do
		  [{:mborg, git: "git://github.com/holder66/mborg.git"}]
		end
    ```

  2. Ensure `mborg` is started before your application:

    ```elixir
    def application do
      [applications: [:mborg]]
    end
    ```
