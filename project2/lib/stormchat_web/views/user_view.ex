defmodule StormchatWeb.UserView do
  use StormchatWeb, :view
  alias StormchatWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user_restricted.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("show_restricted.json", %{user: user}) do
    %{data: render_one(user, UserView, "user_restricted.json")}
  end

  # modified to not include the password hash
  def render("user.json", %{user: user}) do
    %{
      user_id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      urgency: user.urgency,
      severity: user.severity,
      certainty: user.certainty
    }
      # password_hash: user.password_hash}
  end

  # modified to include only the user's name and id
  def render("user_restricted.json", %{user: user}) do
    %{user_id: user.id,
      name: user.name}
      # email: user.email,
      # phone: user.phone,
      # password_hash: user.password_hash}
  end
end
