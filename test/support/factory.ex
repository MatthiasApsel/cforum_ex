defmodule Cforum.Factory do
  use ExMachina.Ecto, repo: Cforum.Repo
  use Cforum.UserFactory
  use Cforum.NotificationFactory
  use Cforum.PrivMessageFactory
  use Cforum.ScoreFactory
  use Cforum.BadgeFactory
  use Cforum.ForumFactory
end
