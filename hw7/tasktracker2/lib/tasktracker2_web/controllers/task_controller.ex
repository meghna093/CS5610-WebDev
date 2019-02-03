defmodule Tasktracker2Web.TaskController do
  use Tasktracker2Web, :controller

  alias Tasktracker2.Plan
  alias Tasktracker2.Plan.Task
  alias Tasktracker2.Accounts

def done(conn, %{"task_id"=>id}) do
  task=Plan.get_task!(id)
  time=List.foldr(task.timeblocks,0,fn(z,acc)->dtime(z)+acc end)
  changeset=Plan.change_task(task)
  render(conn, "final.html", task: task, changeset: changeset, time: time)
end

def dtime(timeblock) do
  startTime=Integer.floor_div(timeblock.startTime,1000)
  endTime=Integer.floor_div(timeblock.endTime,1000)
  Integer.floor_div((endTime-startTime),60)
end

  def index(conn, _params) do
    tasks = Plan.list_tasks()
    render(conn, "index.html", tasks: tasks)
  end

  def new(conn, params) do
    usr_list = Accounts.get_id(conn.assigns.current_user.id)
    if (length(usr_list)) == 0 do
      conn
      |> put_flash(:error, "Not a manager")
      |> redirect(to: task_path(conn, :index))
    else
      changeset = Plan.change_task(%Task{})
      render(conn, "new.html", changeset: changeset, task: %Task{}, usr_list: usr_list)
    end
  end

  def create(conn, %{"task" => task_params}) do
    case Plan.create_task(task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task created")
        |> redirect(to: task_path(conn, :show, task))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, task: %Task{})
    end
  end

  def show(conn, %{"id" => id}) do
    task = Plan.get_task!(id)
    render(conn, "show.html", task: task)
  end

  def edit(conn, %{"id" => id}) do
    usr_list = Accounts.get_id(conn.assigns.current_user.id)
    task = Plan.get_task!(id)
    changeset = Plan.change_task(task)
    render(conn, "edit.html", task: task, changeset: changeset, usr_list: usr_list)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Plan.get_task!(id)
    
    case Plan.update_task(task, task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task updated")
        |> redirect(to: task_path(conn, :show, task))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", task: task, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Plan.get_task!(id)
    {:ok, _task} = Plan.delete_task(task)
    
  conn
    |> put_flash(:info, "Task deleted")
    |> redirect(to: task_path(conn, :index))
  end
end
