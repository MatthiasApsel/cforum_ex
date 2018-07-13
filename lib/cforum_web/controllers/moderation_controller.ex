defmodule CforumWeb.ModerationController do
  use CforumWeb, :controller

  alias Cforum.Forums.{ModerationQueue, ModerationQueueEntry, Message, Thread}

  def index(conn, params) do
    forums =
      Cforum.Forums.list_forums_by_permission(
        conn.assigns.current_user,
        Cforum.Accounts.ForumGroupPermission.moderate()
      )

    count = ModerationQueue.count_entries(forums)
    paging = CforumWeb.Paginator.paginate(count, page: params["p"])

    entries =
      forums
      |> ModerationQueue.list_entries(limit: paging.params)
      |> Enum.map(fn entry ->
        %ModerationQueueEntry{
          entry
          | message: %Message{entry.message | thread: %Thread{entry.message.thread | message: entry.message}}
        }
      end)

    render(conn, "index.html", page: paging, moderation_queue_entries: entries)
  end

  def index_open(conn, params) do
    forums =
      Cforum.Forums.list_forums_by_permission(
        conn.assigns.current_user,
        Cforum.Accounts.ForumGroupPermission.moderate()
      )

    count = ModerationQueue.count_entries(forums, true)
    paging = CforumWeb.Paginator.paginate(count, page: params["p"])

    entries =
      forums
      |> ModerationQueue.list_entries(limit: paging.params, only_open: true)
      |> Enum.map(fn entry ->
        %ModerationQueueEntry{
          entry
          | message: %Message{entry.message | thread: %Thread{entry.message.thread | message: entry.message}}
        }
      end)

    render(conn, "index.html", page: paging, moderation_queue_entries: entries)
  end

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def edit(conn, _params) do
    changeset = ModerationQueue.change_resolve_entry(conn.assigns.current_user, conn.assigns.entry)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"moderation_queue_entry" => entry_params}) do
    case ModerationQueue.resolve_entry(conn.assigns.current_user, conn.assigns.entry, entry_params) do
      {:ok, _entry} ->
        conn
        |> put_flash(:info, gettext("Moderation case successfully solved."))
        |> redirect(to: moderation_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def load_resource(conn) do
    if present?(conn.params["id"]) do
      entry = ModerationQueue.get_entry!(conn.params["id"])

      Plug.Conn.assign(conn, :entry, %ModerationQueueEntry{
        entry
        | message: %Message{entry.message | thread: %Thread{entry.message.thread | message: entry.message}}
      })
    else
      conn
    end
  end
end