defmodule CforumWeb.Messages.SubscriptionControllerTest do
  use CforumWeb.ConnCase

  setup [:setup_tests]

  alias Cforum.Forums.Messages

  describe "listing" do
    test "lists all subscribed messages", %{conn: conn, user: user, message: message} do
      Messages.subscribe_message(user, message)
      conn = get(conn, subscription_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("subscribed messages")
      assert html_response(conn, 200) =~ message.subject
    end

    test "doesn't list not subscribed messages", %{conn: conn, message: message} do
      conn = get(conn, subscription_path(conn, :index))
      assert html_response(conn, 200) =~ gettext("subscribed messages")
      refute html_response(conn, 200) =~ message.subject
    end
  end

  describe "subscribing" do
    test "subscribes messages", %{conn: conn, forum: forum, thread: thread, message: message} do
      conn = post(conn, subscribe_message_path(conn, thread, message), f: forum.slug, r: "message")
      assert redirected_to(conn) == message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Message was successfully subscribed.")
    end

    test "responds with 403 on already subscribed messages", %{conn: conn, thread: thread, message: message} do
      conn = post(conn, subscribe_message_path(conn, thread, message))
      assert_error_sent(403, fn -> post(conn, subscribe_message_path(conn, thread, message)) end)
    end
  end

  describe "unsubscribing" do
    test "unsubscribes messages", %{conn: conn, user: user, forum: forum, thread: thread, message: message} do
      Messages.subscribe_message(user, message)
      conn = post(conn, unsubscribe_message_path(conn, thread, message), f: forum.slug, r: "message")
      assert redirected_to(conn) == message_path(conn, :show, thread, message)
      assert get_flash(conn, :info) == gettext("Message was successfully unsubscribed.")
    end

    test "doesn't fail on not subscribed messages", %{conn: conn, thread: thread, message: message} do
      assert_error_sent(403, fn -> post(conn, unsubscribe_message_path(conn, thread, message)) end)
    end
  end

  defp setup_tests(%{conn: conn}) do
    user = build(:user) |> insert

    forum = insert(:public_forum)
    thread = insert(:thread, forum: forum)
    message = insert(:message, forum: forum, thread: thread)
    {:ok, user: user, conn: login(conn, user), thread: thread, message: message, forum: forum}
  end
end