defmodule Plumber.Phase do
  @moduledoc """
  Behaviour for Phases that used in Pipeline.
  """

  alias Plumber.Resource

  @type options() :: Keyword.t() | map()
  @type t() :: module() | {module(), options()}

  @type result(data, error) ::
          {:ok, Resource.t(data, error)}
          | {:halt, Resource.t(data, error)}
          | {:jump, Resource.t(data, error), t()}

  @type result(data) :: result(data, term())
  @type result() :: result(term(), term())

  defmacro __using__(_) do
    quote do
      alias Plumber.Phase
      alias Plumber.Resource

      @behaviour unquote(__MODULE__)
    end
  end

  @callback run(Resource.t(), options()) :: result()
end
