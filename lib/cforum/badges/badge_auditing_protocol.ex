defimpl Cforum.System.AuditingProtocol, for: Cforum.Badges.Badge do
  def audit_json(badge) do
    badge
    |> Map.from_struct()
    |> Map.drop([:badges_users, :users, :__meta__, :badges])
  end
end
