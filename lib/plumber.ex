defmodule Plumber do
  @moduledoc """
  Plumber is a pipeline abstraction.
  """

  @doc """
  Execute a pipeline of phases.
  """
  defdelegate run(input, pipeline), to: Plumber.Pipeline
end
