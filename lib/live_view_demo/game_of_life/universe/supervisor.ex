# lib/dynamic_supervisor_example/worker_supervisor.ex
defmodule LiveViewDemo.GameOfLife.Universe.Supervisor do
  use DynamicSupervisor
  alias LiveViewDemo.GameOfLife.Universe

  def start_link(_arg), do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(universe_name) do
    DynamicSupervisor.start_child(__MODULE__, {Universe, universe_name})
  end
end
