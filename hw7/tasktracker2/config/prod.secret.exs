use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :tasktracker2, Tasktracker2Web.Endpoint,
  secret_key_base: "ap1oz55hyIMAqMygaXHn7rJkZ2L+c3WwKBjQzLSMgPCTSDW20Y90zuHGnbjAUhlx"

# Configure your database
config :tasktracker2, Tasktracker2.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "tasktracker2_prod",
  pool_size: 15
