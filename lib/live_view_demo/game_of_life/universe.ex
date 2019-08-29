defmodule LiveViewDemo.GameOfLife.Universe do
  use GenServer
  require Logger

  @moduledoc """
  LiveViewDemo.GameOfLife.Universe.Supervisor.start_child("u1")
  LiveViewDemo.GameOfLife.Universe.Supervisor.start_child("u2")
  LiveViewDemo.GameOfLife.Universe.generate("u1", {10, 10})
  LiveViewDemo.GameOfLife.Universe.tick("u1")
  """

  alias LiveViewDemo.GameOfLife.Cell

  ## Client

  def start_link(name), do: GenServer.start_link(__MODULE__, name, name: via_tuple(name))

  def stop(name), do: GenServer.stop(via_tuple(name))

  def generate(name, dimensions), do: GenServer.cast(via_tuple(name), {:generate, dimensions})

  def tick(name), do: GenServer.call(via_tuple(name), :tick)

  ## Server

  def init(name) do
    LiveViewDemo.GameOfLife.Cell.Supervisor.start_link(name)

    {:ok, %{name: name, dimensions: {30, 30}}}
  end

  def handle_cast({:generate, dimensions}, state) do
    state = Map.put(state, :dimensions, dimensions)

    new_generation(state)
    print_universe(state)

    {:noreply, state}
  end

  def handle_call(:tick, _from, state) do
    Logger.info("Tick Universe")

    each_cell(state, &Cell.tick/2)

    print_universe(state)

    {:reply, state, state}
  end

  ## Utils

  defp new_generation(state), do: each_cell(state, &LiveViewDemo.GameOfLife.Cell.Supervisor.start_child/2)

  defp print_universe(%{name: name, dimensions: {height, width}}) do
    Enum.each(0..height, fn y ->
      Enum.each(0..width, fn x ->
        case Cell.alive?(name, {x, y}) do
          nil -> "-"
          false -> "X"
          true -> "0"
        end
        |> IO.write()
      end)

      IO.puts("")
    end)
  end

  defp each_cell(%{name: name, dimensions: {height, width}}, f) do
    Enum.each(0..height, fn y ->
      Enum.each(0..width, fn x ->
        f.(name, {x, y})
      end)
    end)
  end

  defp via_tuple(name), do: {:via, Registry, {:gol_registry, tuple(name)}}

  defp tuple(name), do: {:universe, name}
end
