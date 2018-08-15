# mborg

Mborg is an Elixir project to control a MonsterBorg robot, initially
with a joystick over bluetooth, but with the eventual goal of having an
autonomous vehicle which can follow a track using input from its front-
mounted Pi Camera. This will require development of Artificial Intelligence
based on work I've previously done on a nearest neighbour classifier using
Hamming distances and neural network designs.

For the time being, run a demo with:
iex(1)> Mborg.Controller.run

stop a running joystick genserver process with:
iex(2)> Joystick.stop(v)

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
