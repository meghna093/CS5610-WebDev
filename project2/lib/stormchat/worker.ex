defmodule Stormchat.Worker do
  use GenServer

  alias Stormchat.Alerts

  # Worker design courtesy of Jose Valim
  # https://stackoverflow.com/questions/32085258/how-can-i-schedule-code-to-run-every-few-hours-in-elixir-or-phoenix-framework/32097971

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Alerts.update() # get initial NWS alerts and notify affected users
    schedule_work() # schedule update
    {:ok, state}
  end

  def handle_info(:work, state) do
    Alerts.update() # get updated NWS alerts and notify affected users
    schedule_work() # reschedule update
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 2 * 60 * 1000) # in 2 minutes
  end
end
