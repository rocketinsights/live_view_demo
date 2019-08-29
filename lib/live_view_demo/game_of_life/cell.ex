defmodule LiveViewDemo.GameOfLife.Cell do
  use GenServer
  require Logger

  ## Client

  def start_link(%{universe_name: universe_name, position: position}) do
    GenServer.start_link(
      __MODULE__,
      %{universe_name: universe_name, position: position},
      name: via_tuple(universe_name, position)
    )
  end

  def tick(universe_name, position) do
    GenServer.call(via_tuple(universe_name, position), :tick)
  end

  def crash(universe_name, position), do: GenServer.cast(via_tuple(universe_name, position), :crash)

  def alive?(universe_name, position) do
    if exists?(universe_name, position) do
      GenServer.call(via_tuple(universe_name, position), :alive)
    else
      nil
    end
  end

  ## Server

  @impl true
  def init(state) do
    alive = Enum.random([true, false])
    state = Map.put(state, :alive, alive)

    {:ok, state}
  end

  @impl true
  def handle_call(:tick, _from, state) do
    state = update_cell(state)

    {:reply, Map.get(state, :alive, false), state}
  end

  @impl true
  def handle_call(:alive, _from, state) do
    {:reply, Map.get(state, :alive), state}
  end

  @impl true
  def handle_cast(:crash, _state) do
    raise "crashed"
  end

  ## Utils

  defp update_cell(%{universe_name: universe_name, position: {x, y}} = state) do
    neighbors = [
      alive?(universe_name, {x - 1, y}),
      alive?(universe_name, {x - 1, y - 1}),
      alive?(universe_name, {x, y - 1}),
      alive?(universe_name, {x + 1, y - 1}),
      alive?(universe_name, {x + 1, y}),
      alive?(universe_name, {x + 1, y + 1}),
      alive?(universe_name, {x, y + 1}),
      alive?(universe_name, {x + 1, y})
    ]

    live_neighbor_count = Enum.count(neighbors, & &1)

    alive =
      cond do
        live_neighbor_count < 2 -> false
        live_neighbor_count > 3 -> false
        true -> true
      end

    Map.put(state, :alive, alive)
  end

  defp exists?(name, position) do
    :gol_registry
    |> Registry.lookup(tuple(name, position))
    |> Enum.empty?()
    |> Kernel.!()
  end

  defp via_tuple(universe_name, position), do: {:via, Registry, {:gol_registry, tuple(universe_name, position)}}

  defp tuple(universe_name, position), do: {:cell, universe_name, position}
end
