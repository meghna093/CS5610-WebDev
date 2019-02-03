# Tasktracker

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
  
## This is a Task Tracker application:
  * A user can register themselves by entering their name, email address and a password to secure their account.
  * Once registered, users will be redirected to home page from where the users can login by entering the email address and password.
  * After the user logs in, they can see the list of existing task, who is it assigned to and what is the status of that task.
  * A user can create task by entering title and description. This task can be assigned to themselves or to any other existing user by entering the user's ID.
  * Once a task is created and assigned, the person to whom the task is assigned can edit the task by marking it complete and entering the time taken.
  * Time taken should be entered as a multiple of 15 minutes.
  

