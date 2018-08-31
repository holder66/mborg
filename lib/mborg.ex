defmodule Mborg do
  @moduledoc """
  Documentation for Mborg.
  Mborg is an Elixir project to control a MonsterBorg robot, initially
  with a joystick over bluetooth, but with the eventual goal of having an
  autonomous vehicle which can follow a track using input from its front-
  mounted Pi Camera. This will require development of Artificial Intelligence
  based on work I've previously done on a nearest neighbour classifier using
  Hamming distances and neural network designs.
  """

  use Application

  def run do
    {:ok, _pid} = Mborg.JstickBoard.run
  end

  def start(_type, _args) do
    Mborg.Supervisor.start_link
  end
end


Mborg.run
