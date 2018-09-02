defmodule Mborg.Mborg.ControllerState do
  use GenServer

  #####

  # External API

  # def start_link({direction, power}) do
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :controller_state)
  end

  def set_turn_values({direction, power}) do
    GenServer.cast(:controller_state, {:set_turn_values, {direction, power}})
  end

  def get_turn_values do
    GenServer.call(:controller_state, {:get_turn_values})
  end

  # Callbacks

  def init(_) do
    state = {0,0}
    
    {:ok, state}
  end

  def handle_cast({:set_turn_values, {direction, power}}, {_dir, _pwr}) do

    {:noreply, {direction, power}}
  end

  def handle_call({:get_turn_values}, _from, {direction, power}) do
    # IO.inspect state

    {:reply, {direction, power}, {direction, power}}
  end
end
