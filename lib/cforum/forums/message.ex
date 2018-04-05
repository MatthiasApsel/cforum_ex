defmodule Cforum.Forums.Message do
  use CforumWeb, :model

  import CforumWeb.Gettext
  import Cforum.Helpers

  alias Cforum.Accounts.User

  @primary_key {:message_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :message_id}

  @default_preloads [:user, :tags, votes: :voters]
  def default_preloads, do: @default_preloads

  schema "messages" do
    field(:upvotes, :integer)
    field(:downvotes, :integer)
    field(:deleted, :boolean, default: false)
    field(:mid, :integer)
    field(:author, :string)
    field(:email, :string)
    field(:homepage, :string)
    field(:subject, :string)
    field(:content, :string)
    field(:flags, :map, default: %{})
    field(:uuid, :string)
    field(:ip, :string)
    field(:format, :string, default: "markdown")
    field(:edit_author, :string)
    field(:problematic_site, :string)

    field(:messages, :any, virtual: true)
    field(:attribs, :map, virtual: true, default: %{classes: []})

    belongs_to(:thread, Cforum.Forums.Thread, references: :thread_id)
    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
    belongs_to(:user, Cforum.Accounts.User, references: :user_id)
    belongs_to(:parent, Cforum.Forums.Message, references: :message_id)
    belongs_to(:editor, Cforum.Accounts.User, references: :user_id)

    has_many(:cites, Cforum.Cites.Cite, foreign_key: :message_id, on_delete: :nilify_all)

    field(:tags_str, :string, virtual: true)

    many_to_many(
      :tags,
      Cforum.Forums.Tag,
      join_through: Cforum.Forums.MessageTag,
      join_keys: [message_id: :message_id, tag_id: :tag_id]
    )

    has_many(:votes, Cforum.Forums.CloseVote, foreign_key: :message_id)

    timestamps(inserted_at: :created_at)
  end

  def accepted?(message), do: message.flags["accepted"] == "yes"
  def no_answer?(message), do: message.flags["no-answer"] == "yes" || message.flags["no-answer-admin"] == "yes"
  def closed?(message), do: message.deleted || no_answer?(message)
  def score(msg), do: msg.upvotes - msg.downvotes
  def no_votes(msg), do: msg.upvotes + msg.downvotes
  def score_str(msg), do: Cforum.Helpers.score_str(no_votes(msg), score(msg))

  defp base_changeset(struct, params, user, forum_id, visible_forums) do
    struct
    |> cast(params, [:author, :email, :homepage, :subject, :content, :problematic_site, :tags_str, :forum_id])
    |> maybe_put_change(:forum_id, forum_id)
    |> validate_forum_id(visible_forums)
    |> maybe_set_author(user)
    |> parse_tags(params)
  end

  defp maybe_put_change(changeset, _, nil), do: changeset
  defp maybe_put_change(changeset, field, value), do: put_change(changeset, field, value)

  defp validate_forum_id(changeset, visible_forums) do
    case get_field(changeset, :forum_id) do
      nil ->
        changeset

      forum_id ->
        if Enum.find(visible_forums, &(&1.forum_id == forum_id)) == nil,
          do: add_error(changeset, :forum_id, "is invalid"),
          else: changeset
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params, user, visible_forums, thread, message \\ nil)

  def changeset(struct, params, user, visible_forums, thread, nil) do
    struct
    |> base_changeset(params, user, thread.forum_id, visible_forums)
    |> put_change(:thread_id, thread.thread_id)
    |> validate_required([:author, :subject, :content, :forum_id, :thread_id])
  end

  def changeset(struct, params, user, visible_forums, thread, message) do
    struct
    |> base_changeset(params, user, thread.forum_id, visible_forums)
    |> put_change(:thread_id, thread.thread_id)
    |> put_change(:parent_id, message.message_id)
    |> validate_required([:author, :subject, :content, :forum_id, :thread_id])
  end

  def changeset(struct, params, user, visible_forums) do
    struct
    |> base_changeset(params, user, nil, visible_forums)
    |> validate_required([:author, :subject, :content])
  end

  defp parse_tags(changeset, %{"tags_str" => tags_str}) when is_bitstring(tags_str) do
    tags =
      tags_str
      |> String.split(~r/,/, trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.downcase/1)

    known_tags = Cforum.Forums.Tags.get_tags(tags, get_field(changeset, :forum_id))

    unknown_tags =
      Enum.filter(tags, fn tag ->
        Enum.find(known_tags, &(&1.tag_name == tag)) == nil
      end)

    # TODO for now we just error out on unknown tags
    if blank?(unknown_tags) do
      put_assoc(changeset, :tags, known_tags)
    else
      changeset
      |> put_assoc(:tags, known_tags)
      |> add_error(:tags, gettext("unknown tags given: %{tags}", tags: Enum.join(unknown_tags, ", ")))
    end
  end

  defp parse_tags(changeset, _), do: changeset

  defp maybe_set_author(changeset, %User{} = author) do
    changeset
    |> put_change(:author, author.username)
    |> put_change(:user_id, author.user_id)
  end

  defp maybe_set_author(changeset, nil), do: changeset
end
