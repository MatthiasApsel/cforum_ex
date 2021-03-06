defmodule Cforum.OpenClose.State do
  use CforumWeb, :model

  @primary_key {:opened_closed_thread_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :opened_closed_thread_id}

  schema "opened_closed_threads" do
    field(:state, :string)
    field(:user_id, :id)
    field(:thread_id, :id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :thread_id, :state])
    |> validate_required([:user_id, :thread_id, :state])
    |> validate_inclusion(:state, ~w[open closed])
    |> unique_constraint(:thread_id, name: :opened_closed_threads_thread_id_user_id_idx)
  end
end
