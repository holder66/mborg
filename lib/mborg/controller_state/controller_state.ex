defmodule Mborg.Mborg.ControllerState do
  use GenServer

  #####

  # External API

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :controller_state)
  end
  
  def set_state({forwarddir, forwardpower, turndir, turnpower}) do
    GenServer.cast(:controller_state, {:set_state, {forwarddir, forwardpower, turndir, turnpower}})
  end
  
  def get_state do
    GenServer.call(:controller_state, {:get_state})
  end

  # Callbacks

  def init(_) do
    state = {0,0,0,0}
    
    {:ok, state}
  end
  
  def handle_cast({:set_state, {forwarddir, forwardpower, turndir, turnpower}}, {_dir, _pwr, _turndir, _turnpwr}) do

    {:noreply, {forwarddir, forwardpower, turndir, turnpower}}
  end

  def handle_call({:get_state}, _from, {forwarddir, forwardpower, turndir, turnpower}) do
    # IO.inspect state

    {:reply, {forwarddir, forwardpower, turndir, turnpower}, {forwarddir, forwardpower, turndir, turnpower}}
  end
end
