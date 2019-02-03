# Tasktracker2

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
  
## Tasktracker2 App

  * A new user can register themselves and log in with just the email address.
  * There are two types of users: Managers and Underlings(those who report to the assigned manager).
  * Only managers can create and delete tasks.
  * The following are the roles of a manager:
	* Create new tasks and manage existing tasks assigned to all those users who reports to him/her(i.e. manager)
	* Keep track of the tasks assigned, i.e. check the status of the task and the time taken if the task is complete.
	* Can delete tasks assigned to the users anytime.
  * As a user who reports to a manager:
        * View all the tasks assigned by the reporting manager.
	* View all the tasks assigned to his/her underlings if this user is also a manager (in this scenario user plays the role of both manager and underling)
	* Mark a task as complete by entering timestamps.
	* Can also track the time taken to complete an assigned task using 'Start Working' and 'Stop Working' buttons.
