defmodule Stormchat.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Stormchat.Repo

  alias Stormchat.Posts.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  # returns the max number of posts per "page load"
  def post_limit do
    10
  end

  # returns a list of the latest "post_limit" posts
  def get_latest_posts(alert_id) do
    pl = post_limit()

    query =
      from p in Post,
        where: p.alert_id == ^alert_id,
        order_by: [desc: p.inserted_at],
        limit: ^pl,
        select: p

    Repo.all(query)
    |> Repo.preload(:user)
  end

  # returns a list of the the previous chunk of older posts, including the given post
  def get_older_posts(oldest_id) do
    oldest_post = get_post(oldest_id)
    alert_id = oldest_post.alert_id
    inserted_at = oldest_post.inserted_at
    pl = post_limit()

    query =
      from p in Post,
        where: p.alert_id == ^alert_id and p.inserted_at < ^inserted_at,
        order_by: [desc: p.inserted_at],
        limit: ^pl,
        select: p

    Repo.all(query)
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  def get_post(id), do: Repo.get(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    resp = %Post{}
           |> Post.changeset(attrs)
           |> Repo.insert()
    case resp do
      {:ok, struct} -> {:ok, Repo.preload(struct, :user)}
      _ -> resp
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end
end
