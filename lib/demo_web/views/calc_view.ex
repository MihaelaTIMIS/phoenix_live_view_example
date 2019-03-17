defmodule DemoWeb.CalcView do
  use DemoWeb, :view

  alias DemoWeb.CalcLive

  def disabled_flag(pending_operator) do
    if (pending_operator == ''), do: "disabled"
  end
end
