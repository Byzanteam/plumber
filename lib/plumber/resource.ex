defmodule Plumber.Resource do
  @moduledoc false

  @behaviour Access

  @enforce_keys [:data]
  defstruct [:data, assigns: %{}, errors: []]

  @type t(data, error) :: %__MODULE__{
          data: data,
          assigns: map(),
          errors: [error]
        }

  @type t(data) :: t(data, term())
  @type t() :: t(term(), term())

  @spec new(data) :: t(data) when data: var
  def new(data \\ nil) do
    %__MODULE__{data: data}
  end

  @doc """
  Puts the `key` with value equal to `value` into `assigns` map.
  """
  @spec assign(t(), key :: atom(), value :: term()) :: t()
  def assign(%__MODULE__{} = resource, key, value) when is_atom(key) do
    %__MODULE__{assigns: assigns} = resource

    %__MODULE__{resource | assigns: Map.put(assigns, key, value)}
  end

  @doc "Puts error into errors list."
  @spec add_error(t(), error) :: t(error) when error: var
  def add_error(%__MODULE__{} = resource, error) do
    %__MODULE__{errors: errors} = resource

    %__MODULE__{resource | errors: errors ++ List.wrap(error)}
  end

  @impl Access
  defdelegate fetch(term, key), to: Map

  @impl Access
  defdelegate get_and_update(data, key, function), to: Map

  @impl Access
  defdelegate pop(data, key), to: Map
end
