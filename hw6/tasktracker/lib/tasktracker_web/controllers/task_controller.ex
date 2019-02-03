defmodule TasktrackerWeb.TaskController do
  use TasktrackerWeb, :controller

  alias Tasktracker.Plan
  alias Tasktracker.Plan.Task
  alias Tasktracker.Plan.Assignment

  def index(conn, _params) do
    tasks = Plan.list_tasks()
    render(conn, "index.html", tasks: tasks)
  end

  def new(conn, _params) do
    changeset = Plan.change_task(%Task{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"task" => task_params}) do
    case Plan.create_task(task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task created")
        |> redirect(to: task_path(conn, :show, task))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    task = Plan.get_task!(id)
    assignments = Plan.list_assg_tsks(id)
    render(conn, "show.html", task: task, assignments: assignments)
  end

  def edit(conn, %{"id" => id}) do
    task = Plan.get_task!(id)
    changeset = Plan.change_task(task)
    render(conn, "edit.html", task: task, changeset: changeset)
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
