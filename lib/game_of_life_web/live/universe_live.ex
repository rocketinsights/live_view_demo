defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView
  import Calendar.Strftime
  alias GameOfLife.Universe

  def render(assigns) do
    #<h2 phx-click="boom">It's <%= strftime!(@date, "%r") %></h2>

    ~L"""
    <div>
      <h1>It's time for... the Game... of... LIFE!</h1>
      <p style="width: 300px;"><%= @cells %></p>
    </div>
    """
  end

  def mount(_session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)
    universe = Universe.Supervisor.start_child("u1", {8, 8})

    {:ok, put_cells(socket)}
  end

  def handle_info(:tick, socket) do
    # TODO get universe name from socket
    Universe.tick("u1")

    {:noreply, put_cells(socket)}
  end

  defp put_cells(socket) do
    assign(socket, cells: Universe.render("u1"))
  end
end
