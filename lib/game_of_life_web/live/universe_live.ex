defmodule GameOfLifeWeb.UniverseLive do
  use Phoenix.LiveView

  alias GameOfLife.Universe
  alias GameOfLife.Universe.Template
  alias GameOfLife.Universe.Dimensions

  def render(assigns) do
    GameOfLifeWeb.UniverseView.render("show.html", assigns)
  end

  def mount(_session, socket) do
    socket = assign(socket, universe: rand_bytes(), speed: 10, playing: true)

    socket = assign(socket, template: :random, dimensions: %Dimensions{width: 16, height: 16})
    # socket = assign(socket, template: :beacon, dimensions: Template.dimensions(:beacon))
    # socket = assign(socket, template: :pulsar, dimensions: Template.dimensions(:pulsar))

    Universe.start_link(%{
      name: socket.assigns.universe,
      dimensions: socket.assigns.dimensions,
      template: socket.assigns.template
    })

    {:ok, put_generation(socket, &Universe.info/1)}
  end

  def handle_info(:tick, socket) do 
    {:noreply, put_generation(socket, &Universe.tick/1)}
  end

  def handle_event("update_speed", %{"universe" => %{ "speed" => speed }}, socket) do
    {:noreply, assign(socket, speed: String.to_integer(speed))}
  end

  def handle_event("toggle_playing", _params, socket) do
    {:noreply, toggle_playing(socket)}
  end

  defp put_generation(socket, f) do
    socket
    |> assign(generation: f.(socket.assigns.universe))
    |> schedule_tick()
  end

  defp rand_bytes, do: :crypto.strong_rand_bytes(16)

  defp schedule_tick(socket) do
    if connected?(socket) and socket.assigns.playing do
      Process.send_after(self(), :tick, trunc(1000 / socket.assigns.speed))
    end
    socket
  end

  defp toggle_playing(socket) do
    socket =
      socket
      |> assign(playing: !socket.assigns.playing)
      |> schedule_tick()

    socket
  end
end
