defmodule Cforum.Score do
  use Cforum.Web, :model

  @primary_key {:score_id, :integer, []}
  @derive {Phoenix.Param, key: :score_id}

  schema "scores" do
    field :value, :integer
    belongs_to :user, Cforum.User, references: :user_id
    belongs_to :vote, Cforum.Vote, references: :vote_id
    belongs_to :message, Cforum.Message, references: :message_id

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value])
    |> validate_required([:value])
  end
end
