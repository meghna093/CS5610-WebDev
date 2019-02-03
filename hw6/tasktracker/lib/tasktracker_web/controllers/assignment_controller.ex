defmodule TasktrackerWeb.AssignmentController do
  use TasktrackerWeb, :controller

  alias Tasktracker.Plan
  alias Tasktracker.Plan.Assignment
  alias Tasktracker.Accounts
  

def edit(conn, %{"id" => id, "task_id" => task_id}) do
assignment = Plan.get_assignment!(id)
changeset = Plan.change_assignment(assignment)
render(conn, "edit.html",task_id: task_id,assignment: assignment,changeset: changeset)
end

def new(conn, %{"task_id" => task_id}) do
changeset = Plan.change_assignment(%Assignment{})
users = Accounts.list_users
render(conn, "new.html", task_id: task_id,changeset: changeset,users: users)
end

def create(conn, %{"assignment" => assignment}) do
if duration(assignment["time"]) do
case Plan.create_assignment(assignment) do
{:ok, assignment} -> conn
|> put_flash(:info, "Task Assigned")
|> redirect(to: task_path(conn, :show, assignment.task_id))
{:error, %Ecto.Changeset{} = changeset} -> render(conn, "new.html", changeset: changeset)
end
else
conn 
|> put_flash(:info, "Assignment time should be a multiple of 15")
|> redirect(to: assignment_path(conn, :new, assignment["task_id"]))
end 
end

def update(conn, %{"assignment" => assignment_params}) do
if duration(assignment_params["time"]) do
assignment = Plan.get_assignment!(assignment_params["id"])
case Plan.update_assignment(assignment, assignment_params) do
{:ok, assignment} -> conn
|> put_flash(:info, "Assignment updated")
|> redirect(to: task_path(conn, :show, assignment.task_id))
{:error, %Ecto.Changeset{} = changeset} -> render(conn, "edit.html", assignment, changeset: changeset)
end
else
conn
|> put_flash(:info, "Assignment time should be a multiple of 15")
|> redirect(to: assignment_path(conn, :edit, assignment_params["id"], task_id: assignment_params["task_id"]))
end
end

def delete(conn, %{"id" => id}) do
assignment = Plan.get_assignment!(id)
{:ok, _assignment} = Plan.delete_assignment(assignment)
conn
|> put_flash(:info, "Assignment Completed")
|> redirect(to: task_path(conn, :show, assignment.task_id))
end

defp duration(str) do
try do
nmber = String.to_integer(str)
nmber > 0 && rem(nmber, 15) == 0
rescue a in ArgumentError -> false
end
end
end
