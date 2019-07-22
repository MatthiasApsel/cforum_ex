defmodule CforumWeb.ErrorView do
  use CforumWeb, :view

  def render("404.html", assigns) do
    VHelpers.l10n_render(
      CforumWeb.ErrorView,
      "error_404.html",
      Map.merge(
        assigns,
        %{layout: {CforumWeb.LayoutView, "error.html"}, title: gettext("page not found")}
      )
    )
  end

  def render("403.html", assigns) do
    VHelpers.l10n_render(
      CforumWeb.ErrorView,
      "error_403.html",
      Map.merge(
        assigns,
        %{layout: {CforumWeb.LayoutView, "error.html"}, title: gettext("access forbidden")}
      )
    )
  end

  def render("500.html", assigns) do
    VHelpers.l10n_render(
      CforumWeb.ErrorView,
      "error_500.html",
      Map.merge(
        assigns,
        %{layout: {CforumWeb.LayoutView, "error.html"}, title: gettext("internal server error")}
      )
    )
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render(
      "error_500.html",
      Map.merge(
        assigns,
        %{layout: {CforumWeb.LayoutView, "error.html"}, title: gettext("page not found")}
      )
    )
  end
end
