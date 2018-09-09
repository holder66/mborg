defmodule Mborg.Mborg.ControllerState do
  use GenServer

  #####

  # External API

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: :controller_state)
  end
  
  def set_state({forwarddirection, forwardpower, turndirection, turnpower}) do
    GenServer.cast(:controller_state, {:set_state, {forwarddirection, forwardpower, turndirection, turnpower}})
  end
  
  def get_state do
    GenServer.call(:controller_state, {:get_state})
  end

  # Callbacks

  def init(_) do
    state = {0,0,0,0}
    
    {:ok, state}
  end
  
  def handle_cast({:set_state, {forwarddirection, forwardpower, turndirection, turnpower}}, {_dir, _pwr, _turndir, _turnpwr}) do

    {:noreply, {forwarddirection, forwardpower, turndirection, turnpower}}
  end

  def handle_call({:get_state}, _from, {forwarddirection, forwardpower, turndirection, turnpower}) do
    # IO.inspect state

    {:reply, {forwarddirection, forwardpower, turndirection, turnpower}, {forwarddirection, forwardpower, turndirection, turnpower}}
  end
end
