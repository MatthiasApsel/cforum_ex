defmodule Cforum.Forums.Message do
  use CforumWeb, :model

  @primary_key {:message_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :message_id}

  @default_preloads [:user, :tags, votes: :voters]
  def default_preloads, do: @default_preloads

  schema "messages" do
    field :upvotes, :integer
    field :downvotes, :integer
    field :deleted, :boolean, default: false
    field :mid, :integer
    field :author, :string
    field :email, :string
    field :homepage, :string
    field :subject, :string
    field :content, :string
    field :flags, :map
    field :uuid, :string
    field :ip, :string
    field :format, :string
    field :edit_author, :string
    field :problematic_site, :string

    field :messages, :any, virtual: true
    field :attribs, :map, virtual: true, default: %{classes: []}

    belongs_to :thread, Cforum.Forums.Thread, references: :thread_id
    belongs_to :forum, Cforum.Forums.Forum, references: :forum_id
    belongs_to :user, Cforum.Accounts.User, references: :user_id
    belongs_to :parent, Cforum.Forums.Message, references: :message_id
    belongs_to :editor, Cforum.Accounts.User, references: :user_id

    many_to_many :tags, Cforum.Forums.Tag, join_through: Cforum.Forums.MessageTag, join_keys: [message_id: :message_id, tag_id: :tag_id]
    has_many :votes, Cforum.Forums.CloseVote, foreign_key: :message_id

    timestamps(inserted_at: :created_at)
  end

  def accepted?(message) do
    message.flags["accepted"] == "yes"
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:upvotes, :downvotes, :deleted, :mid, :author, :email, :homepage, :subject, :content, :flags, :uuid, :ip, :format, :edit_author, :problematic_site])
    |> validate_required([:upvotes, :downvotes, :deleted, :mid, :author, :email, :homepage, :subject, :content, :flags, :uuid, :ip, :format, :edit_author, :problematic_site])
  end

  def score(msg) do
    msg.upvotes - msg.downvotes
  end

  def no_votes(msg) do
    msg.upvotes + msg.downvotes
  end

  def score_str(msg) do
    if no_votes(msg) == 0 do
      "–"
    else
      case score(msg) do
        0 ->
          "±0"
        s when s < 0 ->
          "−" <> Integer.to_string(abs(s))
        s ->
          "+" <> Integer.to_string(s)
      end
    end
  end

  def subject_changed?(_, nil), do: true
  def subject_changed?(msg, parent) do
    parent.subject != msg.subject
  end

  def tags_changed?(_, nil), do: true
  def tags_changed?(msg, parent) do
    parent.tags != msg.tags
  end
end
