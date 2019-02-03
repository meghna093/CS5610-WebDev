defmodule Tasktracker2Web.TimeblockController do
  use Tasktracker2Web, :controller

  alias Tasktracker2.Plan
  alias Tasktracker2.Plan.Timeblock

  def index(conn, _params) do
    timeblocks = Plan.list_timeblocks()
    render(conn, "index.json", timeblocks: timeblocks)
  end

  def create(conn, %{"timeblock" => timeblock_params}) do
    with {:ok, %Timeblock{} = timeblock} <- Plan.create_timeblock(timeblock_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", timeblock_path(conn, :show, timeblock))
      |> render("show.json", timeblock: timeblock)
    end
  end

  def show(conn, %{"id" => id}) do
    timeblock = Plan.get_timeblock!(id)
    render(conn, "show.json", timeblock: timeblock)
  end

  def update(conn, %{"id" => id, "timeblock" => timeblock_params}) do
    timeblock = Plan.get_timeblock!(id)
    with {:ok, %Timeblock{} = timeblock} <- Plan.update_timeblock(timeblock, timeblock_params) do
      render(conn, "show.json", timeblock: timeblock)
    end
  end

  def delete(conn, %{"id" => id}) do
    timeblock = Plan.get_timeblock!(id)
    with {:ok, %Timeblock{}} <- Plan.delete_timeblock(timeblock) do
      send_resp(conn, :no_content, "")
    end
  end
end
