defmodule Cforum.Web.UserMailer do
  use Bamboo.Phoenix, view: Cforum.Web.UserMailerView
  import Cforum.Web.Gettext

  def confirmation_mail(user) do
    new_email()
    |> from(Application.get_env(:cforum, :mail_sender, "cforum@example.org"))
    |> to(user.email)
    |> subject(gettext("confirm your registration"))
    |> put_html_layout({Cforum.Web.LayoutView, "email.html"})
    |> render(:confirmation_mail, user: user)
  end

end
