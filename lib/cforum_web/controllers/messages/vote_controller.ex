defmodule CforumWeb.Messages.VoteController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Votes, Messages, Threads, Message}
  alias CforumWeb.Views.Helpers.ReturnUrl

  def upvote(conn, params) do
    message =
      if Votes.upvoted?(conn.assigns.message, conn.assigns.current_user) do
        Votes.take_back_vote(conn.assigns.message, conn.assigns.current_user)
        gettext("Successfully took back vote")
      else
        Votes.upvote(conn.assigns.message, conn.assigns.current_user, conf(conn, "vote_up_value", :int))
        gettext("Successfully upvoted message")
      end

    conn
    |> put_flash(:info, message)
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread, conn.assigns.message))
  end

  def downvote(conn, params) do
    message =
      if Votes.downvoted?(conn.assigns.message, conn.assigns.current_user) do
        Votes.take_back_vote(conn.assigns.message, conn.assigns.current_user)
        gettext("Successfully took back vote")
      else
        Votes.downvote(conn.assigns.message, conn.assigns.current_user, conf(conn, "vote_down_value", :int))
        gettext("Successfully downvoted message")
      end

    conn
    |> put_flash(:info, message)
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread, conn.assigns.message))
  end

  def load_resource(conn) do
    {thread, message} =
      Messages.get_message_from_slug_and_mid!(
        conn.assigns[:current_forum],
        conn.assigns[:current_user],
        Threads.slug_from_params(conn.params),
        conn.params["mid"],
        message_order: uconf(conn, "sort_messages")
      )

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
  end

  def allowed?(conn, :upvote, msg) do
    msg = msg || conn.assigns.message

    signed_in?(conn) && access_forum?(conn, :write) && (admin?(conn) || badge?(conn, "upvote")) && !Message.closed?(msg)
  end

  def allowed?(conn, :downvote, msg) do
    msg = msg || conn.assigns.message

    signed_in?(conn) && access_forum?(conn, :write) && (admin?(conn) || badge?(conn, "downvote")) &&
      !Message.closed?(msg) && conn.assigns.current_user.score > 0
  end

  def allowed?(_, _, _), do: false
end
