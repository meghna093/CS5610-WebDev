defmodule StormchatWeb.TokenView do
  use StormchatWeb, :view

  # inclused the id and name of the token user
  def render("token.json", %{user: user, token: token}) do
    %{
      user_id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      urgency: user.urgency,
      severity: user.severity,
      certainty: user.certainty,
      token: token
    }
  end

  def render("error.json", %{}) do
    %{error: "Login failed"}
  end
end
