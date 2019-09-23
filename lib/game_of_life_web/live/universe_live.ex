defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView

  alias GameOfLife.Universe
  alias GameOfLife.Universe.Template
  alias GameOfLife.Universe.Dimensions

  def render(assigns), do: GameOfLifeWeb.UniverseView.render("show.html", assigns)

  def mount(_session, socket) do
    # {:ok, load_universe(socket, %{template: :beacon, dimensions: Template.dimensions(:beacon)})}
    # {:ok, load_universe(socket, %{template: :pulsar, dimensions: Template.dimensions(:pulsar)})}

    {:ok, load_universe(socket)}
  end

  def handle_info(:tick, socket) do
    if socket.assigns.playing do
      {:noreply, put_generation(socket, &Universe.tick/1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("update_speed", %{"universe" => %{"speed" => speed}}, socket) do
    {:noreply, assign(socket, speed: String.to_integer(speed))}
  end

  def handle_event("toggle_playing", _params, socket) do
    {:noreply, toggle_playing(socket)}
  end

  def handle_event("reset", _params, socket) do
    {:noreply, reset_universe(socket)}
  end

  defp put_generation(socket, f) do
    socket
    |> assign(generation: f.(socket.assigns.universe_name))
    |> schedule_tick()
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, trunc(1000 / socket.assigns.speed))

    socket
  end

  defp toggle_playing(socket) do
    socket
    |> assign(playing: !socket.assigns.playing)
    |> schedule_tick()
  end

  defp reset_universe(socket) do
    Universe.stop(socket.assigns.universe_name)

    load_universe(socket, %{
      universe_name: socket.assigns.universe_name,
      speed: socket.assigns.speed,
      playing: false,
      template: socket.assigns.template,
      dimensions: socket.assigns.dimensions
    })
  end

  defp load_universe(socket, opts \\ %{}) do
    socket
    |> setup_universe(opts)
    |> start_universe()
    |> put_generation(&Universe.info/1)
  end

  defp setup_universe(socket, opts) do
    assign(
      socket,
      universe_name: Map.get(opts, :name, rand_bytes()),
      speed: Map.get(opts, :speed, 5),
      playing: Map.get(opts, :playing, false),
      template: Map.get(opts, :template, :random),
      dimensions: Map.get(opts, :dimensions, %Dimensions{width: 16, height: 16})
    )
  end

  defp start_universe(socket) do
    Universe.start_link(%{
      name: socket.assigns.universe_name,
      dimensions: socket.assigns.dimensions,
      template: socket.assigns.template
    })

    socket
  end

  defp rand_bytes, do: :crypto.strong_rand_bytes(16)
end
