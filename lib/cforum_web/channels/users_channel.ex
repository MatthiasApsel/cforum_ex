defmodule CforumWeb.UsersChannel do
  use CforumWeb, :channel
  use Appsignal.Instrumentation.Decorators

  alias Cforum.Users.User
  alias Cforum.Forums
  alias Cforum.ConfigManager

  alias Cforum.ReadMessages
  alias Cforum.Notifications
  alias Cforum.PrivMessages

  def join("users:lobby", _payload, socket), do: {:ok, socket}

  def join("users:" <> user_id, _payload, socket) do
    if authorized?(socket.assigns[:current_user], String.to_integer(user_id)),
      do: {:ok, socket},
      else: {:error, %{reason: "unauthorized"}}
  end

  @decorate channel_action()
  def handle_in("current_user", _payload, socket),
    do: {:reply, {:ok, socket.assigns[:current_user]}, socket}

  @decorate channel_action()
  def handle_in("settings", _payload, socket) do
    settings = Cforum.ConfigManager.settings_map(nil, socket.assigns[:current_user])

    config =
      Enum.reduce(Cforum.ConfigManager.visible_config_keys(), %{}, fn key, opts ->
        Map.put(opts, key, ConfigManager.uconf(settings, key))
      end)

    {:reply, {:ok, config}, socket}
  end

  @decorate channel_action()
  def handle_in("visible_forums", _payload, socket) do
    forums = Forums.list_visible_forums(socket.assigns[:current_user])
    {:reply, {:ok, %{forums: forums}}, socket}
  end

  @decorate channel_action()
  def handle_in("title_infos", _payload, socket) do
    forums = Forums.list_visible_forums(socket.assigns[:current_user])
    {_, num_messages} = ReadMessages.count_unread_messages(socket.assigns[:current_user], forums)

    assigns = %{
      unread_notifications: Notifications.count_notifications(socket.assigns[:current_user], true),
      unread_mails: PrivMessages.count_priv_messages(socket.assigns[:current_user], true),
      unread_messages: num_messages,
      current_user: socket.assigns[:current_user]
    }

    str = CforumWeb.LayoutView.numeric_infos(socket.assigns[:current_user], assigns)

    {:reply,
     {:ok,
      %{
        infos: str,
        unread_notifications: assigns[:unread_notifications],
        unread_mails: assigns[:unread_mails],
        unread_messages: assigns[:unread_messages]
      }}, socket}
  end

  def handle_in("mark_read", %{"message_id" => mid}, socket) do
    with msg when not is_nil(msg) <- Cforum.Messages.get_message(mid),
         thread when not is_nil(thread) <- Cforum.Threads.get_thread(msg.thread_id) do
      if thread.archived == false,
        do: Cforum.ReadMessages.mark_messages_read(socket.assigns[:current_user], msg)

      {:reply, {:ok, %{"status" => "marked_read"}}, socket}
    else
      _ -> {:reply, {:error, %{"status" => "message_not_found"}}, socket}
    end
  end

  # # Channels can be used in a request/response fashion
  # # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  # # It is also common to receive messages from the client and
  # # broadcast to everyone in the current topic (users:lobby).
  # def handle_in("shout", payload, socket) do
  #   broadcast(socket, "shout", payload)
  #   {:noreply, socket}
  # end

  # Add authorization logic here as required.
  defp authorized?(%User{user_id: uid}, id) when uid == id, do: true
  defp authorized?(_, _), do: false
end
