defmodule HelloWeb.LayoutView do
  use HelloWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def title() do # Here I can add function to execute in my layout
    "Hello I'm a title :D" #Return this text
  end
end
