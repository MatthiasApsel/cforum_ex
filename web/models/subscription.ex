defmodule Cforum.Subscription do
  use Cforum.Web, :model

  @primary_key {:subscription_id, :integer, []}
  @derive {Phoenix.Param, key: :subscription_id}

  schema "subscriptions" do
    belongs_to :user, Cforum.User, references: :user_id
    belongs_to :message, Cforum.Message, references: :message_id
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :message_id])
    |> validate_required([:user_id, :message_id])
  end
end
