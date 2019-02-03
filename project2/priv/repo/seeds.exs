# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Stormchat.Repo.insert!(%Stormchat.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule Seeds do
  alias Stormchat.Repo
  alias Stormchat.Users.User
  alias Stormchat.Posts.Post

  def run do
    ph1 = Comeonin.Argon2.hashpwsalt("password1");
    ph2 = Comeonin.Argon2.hashpwsalt("password2");
    ph3 = Comeonin.Argon2.hashpwsalt("password3");
    ph4 = Comeonin.Argon2.hashpwsalt("password4");

    Repo.delete_all(User)
    Repo.insert!(%User{ name: "alice", email: "alice@example.com", phone: "8572721850", password_hash: ph1 })
    Repo.insert!(%User{ name: "bob", email: "bob@example.com", phone: "5555550002", password_hash: ph2 })
    Repo.insert!(%User{ name: "carol", email: "carol@example.com", phone: "5555550003", password_hash: ph3 })
    Repo.insert!(%User{ name: "dave", email: "dave@example.com", phone: "5555550004", password_hash: ph4 })

    Repo.delete_all(Post)
    Repo.insert!(%Post{ body: "test post 1", alert_id: 37, user_id: 1 })
    Repo.insert!(%Post{ body: "test post 2", alert_id: 37, user_id: 2 })
    Repo.insert!(%Post{ body: "test post 3", alert_id: 37, user_id: 3 })
    Repo.insert!(%Post{ body: "test post 4", alert_id: 37, user_id: 4 })
    Repo.insert!(%Post{ body: "test post 5", alert_id: 37, user_id: 3 })
    Repo.insert!(%Post{ body: "test post 6", alert_id: 37, user_id: 2 })
    Repo.insert!(%Post{ body: "test post 7", alert_id: 37, user_id: 1 })
    Repo.insert!(%Post{ body: "test post 8", alert_id: 37, user_id: 2 })
    Repo.insert!(%Post{ body: "test post 9", alert_id: 37, user_id: 3 })
    Repo.insert!(%Post{ body: "test post 10", alert_id: 37, user_id: 3 })
    Repo.insert!(%Post{ body: "test post 11", alert_id: 37, user_id: 1 })
    Repo.insert!(%Post{ body: "test post 12", alert_id: 37, user_id: 4 })
    Repo.insert!(%Post{ body: "test post 13", alert_id: 37, user_id: 2 })
    Repo.insert!(%Post{ body: "test post 14", alert_id: 37, user_id: 3 })
    Repo.insert!(%Post{ body: "test post 15", alert_id: 37, user_id: 1 })
    Repo.insert!(%Post{ body: "test post 16", alert_id: 37, user_id: 4 })
    Repo.insert!(%Post{ body: "test post 17", alert_id: 37, user_id: 4 })
    Repo.insert!(%Post{ body: "test post 18", alert_id: 37, user_id: 3 })
    Repo.insert!(%Post{ body: "test post 19", alert_id: 37, user_id: 2 })
    Repo.insert!(%Post{ body: "test post 20", alert_id: 37, user_id: 1 })
    Repo.insert!(%Post{ body: "test post 21", alert_id: 37, user_id: 1 })
    Repo.insert!(%Post{ body: "test post 22", alert_id: 37, user_id: 4 })
    Repo.insert!(%Post{ body: "test post 23", alert_id: 37, user_id: 2 })
    Repo.insert!(%Post{ body: "test post 24", alert_id: 37, user_id: 3 })
    Repo.insert!(%Post{ body: "test post 25", alert_id: 37, user_id: 1 })
    Repo.insert!(%Post{ body: "test post 26", alert_id: 37, user_id: 4 })
    Repo.insert!(%Post{ body: "test post 27", alert_id: 37, user_id: 4 })
    Repo.insert!(%Post{ body: "test post 28", alert_id: 37, user_id: 3 })
    Repo.insert!(%Post{ body: "test post 29", alert_id: 37, user_id: 2 })
    Repo.insert!(%Post{ body: "test post 30", alert_id: 37, user_id: 1 })
  end
end

Seeds.run
