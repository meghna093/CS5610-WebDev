defmodule StormchatWeb.AlertsChannel do
  use StormchatWeb, :channel

  alias Stormchat.Locations
  alias Stormchat.Posts
  alias Stormchat.Users

  # authenticates socket tocken, then returns the following payload
  # - alert: the alert for this channel
  # - polygons: a list of the polygons affected by this channel's alert
  # - post: a list of the latest posts for this channel's alert
  # - users: a list of users with saved locations affected by this channel's alert
  def join("alerts:" <> alert_id, _payload, socket) do
    alert = Stormchat.Alerts.get_alert(alert_id)
    cond do
      alert == nil -> {:error, %{reason: "no such alert"}, socket}
      true ->
        socket = assign(socket, :alert_id, alert_id)
        polygons = Locations.get_affected_polygons(alert.id)
        posts = Posts.get_latest_posts(alert.id)
        user_count = Users.get_affected_user_count(alert.id)
        {:ok, %{
          "alert" => StormchatWeb.AlertView.render("alert.json", %{alert: alert}),
          "polygons" => polygons,
          "posts" => StormchatWeb.PostView.render("index.json", %{posts: posts}).data,
          "user_count" => user_count
        }, socket}
    end
  end

  # sent when a new post is to be created, returns a list of this channel's latest posts
  def handle_in("post", %{"body" => body}, socket) do
    current_user = socket.assigns[:user_id]
    alert = socket.assigns[:alert_id]
    post_attrs = %{
      "user_id" => current_user,
      "alert_id" => alert,
      "body" => body
    }

    {msg, resp} = Posts.create_post(post_attrs)

    case msg do
      :ok ->
        payload = %{
          "post" => StormchatWeb.PostView.render("post.json", %{post: resp})
        }
        broadcast_from socket, "new_post", payload
        {:reply, {:ok, payload}, socket}
      _error ->
        {:reply, {:error, %{reason: "error creating post"}}, socket}
    end
  end

  # returns the given post plus the posts_limit - 1 previous posts
  def handle_in("older",  %{"oldest_id" => oldest_id}, socket) do
    {:reply, {:ok, %{
      "posts" => StormchatWeb.PostView.render(
        "index.json",
        %{posts: Posts.get_older_posts(oldest_id)}
      ).data
    }}, socket}
  end

  # # Channels can be used in a request/response fashion
  # # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end
  #
  # # It is also common to receive messages from the client and
  # # broadcast to everyone in the current topic (alerts:alert_id).
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end

  # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end
end
