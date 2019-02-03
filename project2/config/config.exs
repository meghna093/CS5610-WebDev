# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :stormchat,
  ecto_repos: [Stormchat.Repo]

# Configures the endpoint
config :stormchat, StormchatWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/wwV8HJNP9EnAeZxTFQvdnb6qOfMPM6YzVneYfhXTjwc0xEUQKv2JSOecFWQXT3T",
  render_errors: [view: StormchatWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Stormchat.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
