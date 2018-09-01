defmodule Mborg.Mborg.ControllerState do
  use GenServer

  #####

  # External API

  def start_link({direction, power}) do
    GenServer.start_link(__MODULE__, {direction, power}, name: :controller_state)
    # GenServer.start_link(__MODULE__, :ok, opts)
  end

  def set_turn_values({direction, power}) do
    GenServer.cast(:controller_state, {:set_turn_values, {direction, power}})
  end

  def get_turn_values do
    GenServer.call(:controller_state, {:get_turn_values})
  end

  # Callbacks

  def init({direction, power}) do
    {:ok, {direction, power}}
  end

  def handle_cast({:set_turn_values, {direction, power}}, {direction, power}) do

    {:noreply, {direction, power}}
  end

  def handle_call({:get_turn_values}, _from, {direction, power}) do
    # IO.inspect state

    {:reply, {direction, power}, {direction, power}}
  end
end
