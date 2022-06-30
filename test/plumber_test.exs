defmodule PlumberTest do
  use ExUnit.Case, async: true

  alias Plumber.Phase
  alias Plumber.Resource

  defmodule AccumulatorPhase do
    use Phase

    @impl true
    def run(%{data: data} = resource, _options) do
      {:ok, %{resource | data: data + 1}}
    end
  end

  defmodule HaltErrorPhase do
    use Phase

    @impl true
    def run(%{errors: errors} = resource, _options) do
      {
        :halt,
        %{resource | errors: ["this is an error" | errors]}
      }
    end
  end

  defmodule AppendErrorPhase do
    use Phase

    @impl true
    def run(%{errors: errors} = resource, _options) do
      {
        :ok,
        %{resource | errors: ["this is an error" | errors]}
      }
    end
  end

  defmodule JupmPhase do
    use Phase

    @impl true
    def run(%{} = resource, options) do
      destination_phase = Keyword.fetch!(options, :destination_phase)

      {:jump, resource, destination_phase}
    end
  end

  describe "{:ok, result}" do
    test "works" do
      {:ok, result, _done} =
        Plumber.run(%Resource{data: 1}, [
          AccumulatorPhase,
          AccumulatorPhase
        ])

      assert result.data === 3
    end

    test "appends error but not halt" do
      {:ok, result, _done} =
        Plumber.run(%Resource{data: 1}, [
          AppendErrorPhase,
          AccumulatorPhase
        ])

      assert result.data === 2
      assert Kernel.length(result.errors) === 1
    end
  end

  describe "{:jump, result, destination_phase}" do
    test "jump" do
      {:ok, result, _done} =
        Plumber.run(%Resource{data: 1}, [
          {JupmPhase, destination_phase: AccumulatorPhase},
          HaltErrorPhase,
          AccumulatorPhase
        ])

      assert result.data === 2
      assert Kernel.length(result.errors) === 0
    end

    test "jump to a destination_phase with options" do
      {:ok, result, _done} =
        Plumber.run(%Resource{data: 1}, [
          {JupmPhase, destination_phase: AccumulatorPhase},
          HaltErrorPhase,
          {AccumulatorPhase, []}
        ])

      assert result.data === 2
      assert Kernel.length(result.errors) === 0
    end
  end

  describe "{:halt, result}" do
    test "halt" do
      {:halt, result, _done} =
        Plumber.run(%Resource{data: 1}, [
          HaltErrorPhase,
          AppendErrorPhase,
          AccumulatorPhase
        ])

      assert result.data === 1
      assert Kernel.length(result.errors) === 1
    end
  end

  describe "with options" do
    defmodule OptionsPhase do
      use Phase

      @impl true
      def run(%{data: data} = resource, factor: factor) do
        {:ok, %{resource | data: data * factor}}
      end
    end

    test "respects options" do
      {:ok, result, _done} =
        Plumber.run(
          %Resource{data: 1},
          [
            AccumulatorPhase,
            {OptionsPhase, [factor: 2]}
          ]
        )

      assert result.data === 4
    end
  end
end
