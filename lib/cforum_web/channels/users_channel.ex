defmodule CforumWeb.UsersChannel do
  use CforumWeb, :channel

  alias Cforum.Accounts.User

  def join("users:lobby", _payload, socket), do: {:ok, socket}

  def join("users:" <> user_id, _payload, socket) do
    if authorized?(socket.assigns.current_user, String.to_integer(user_id)),
      do: {:ok, socket},
      else: {:error, %{reason: "unauthorized"}}
  end

  def handle_in("current_user", _payload, socket),
    do: {:reply, {:ok, socket.assigns[:current_user]}, socket}

  def handle_in("settings", _payload, socket) do
    settings = Cforum.ConfigManager.settings_map(nil, socket.assigns[:current_user])

    config =
      Enum.reduce(Cforum.ConfigManager.user_config_keys(), %{}, fn key, opts ->
        Map.put(opts, key, Cforum.ConfigManager.uconf(settings, key))
      end)

    {:reply, {:ok, config}, socket}
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