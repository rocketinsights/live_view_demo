defmodule GameOfLifeWeb.CellView do
  use GameOfLifeWeb, :view

  def render_cell(%{alive: alive}) do
    case alive do
      false -> content_tag(:div, nil, class: "cell dead")
      true -> content_tag(:div, nil, class: "cell alive")
      _ -> content_tag(:div, "-", class: "cell")
    end
  end
end
