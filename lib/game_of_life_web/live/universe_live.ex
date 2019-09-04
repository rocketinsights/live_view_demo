defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView
  use Phoenix.HTML, only: raw/1
  alias GameOfLife.Universe

  def render(assigns) do
    ~L"""
    <div id="universe-page">
      <h1>It's time for... the Game... of... LIFE!</h1>

      <div class="universe">
        <%= for row <- @cells do %>
          <div class="cell-row">
            <%= for cell <- row do %>
              <%= raw cell %>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(500, self(), :tick)

    socket = assign(socket,
      universe: rand_bytes(),
      dimensions: {8, 8},
    )

    Universe.Supervisor.start_child(
      socket.assigns.universe,
      socket.assigns.dimensions
    )

    {:ok, put_cells(socket, &Universe.info/1)}
  end

  def handle_info(:tick, socket) do
    {:noreply, put_cells(socket, &Universe.tick/1)}
  end

  defp put_cells(socket, f) do
    cells = f.(socket.assigns.universe)
    assign(socket, cells: render_cells(cells))
  end

  def render_cells(cells) do
    Enum.map(cells, fn row ->
      Enum.map(row, fn %{alive: alive} ->
        case alive do
          nil -> "<div class='cell'>-</div>"
          false -> "<div class='cell dead'></div>"
          true -> "<div class='cell alive'></div>"
        end
      end)
    end)
  end

  defp rand_bytes, do: :crypto.strong_rand_bytes(16)
end
