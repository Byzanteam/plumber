defmodule Plumber.Pipeline do
  @moduledoc false

  alias Plumber.Phase
  alias Plumber.Resource

  @type t :: [Phase.t()]

  @type result(data) ::
          {:ok, Resource.t(data), [Phase.t()]}
          | {:halt, Resource.t(data), [Phase.t()]}

  @type result() :: result(term())

  @spec run(Resource.t() | term(), t) :: result()
  def run(%Resource{} = input, pipeline) do
    pipeline
    |> List.flatten()
    |> run_phase(input)
  end

  def run(input, pipeline) do
    run(Resource.new(input), pipeline)
  end

  @spec run_phase(t, Resource.t(), [Phase.t()]) :: result()
  defp run_phase(pipeline, input, done \\ [])

  defp run_phase([], input, done) do
    {:ok, input, done}
  end

  defp run_phase([phase_config | todo], input, done) do
    {phase, options} = phase_invocation(phase_config)

    case phase.run(input, options) do
      {:ok, result} ->
        run_phase(todo, result, [phase | done])

      {:jump, result, destination_phase} when is_atom(destination_phase) ->
        run_phase(from(todo, destination_phase), result, [phase | done])

      {:halt, result} ->
        {:halt, result, [phase | done]}
    end
  end

  @spec phase_invocation(Phase.t()) :: {Phase.t(), Keyword.t()}
  defp phase_invocation({phase, options}) when is_list(options) or is_map(options) do
    {phase, options}
  end

  defp phase_invocation(phase) do
    {phase, []}
  end

  # Return the part of a pipeline after (and including) a specific phase.
  @spec from(t, atom) :: t
  defp from(pipeline, phase) do
    result =
      List.flatten(pipeline)
      |> Enum.drop_while(&(!match_phase?(phase, &1)))

    case result do
      [] ->
        raise RuntimeError, "Could not find phase #{phase}"

      _ ->
        result
    end
  end

  # Whether a phase configuration is for a given phase
  @spec match_phase?(Phase.t(), Phase.t()) :: boolean
  defp match_phase?(phase, phase), do: true
  defp match_phase?(phase, {phase, _}) when is_atom(phase), do: true
  defp match_phase?(_, _), do: false
end
