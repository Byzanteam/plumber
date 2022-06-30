defmodule Plumber.ResourceTest do
  use ExUnit.Case, async: true

  alias Plumber.Resource

  describe "constructs" do
    test "new/1", %{test: test} do
      assert match?(%Resource{data: ^test, assigns: %{}, errors: []}, Resource.new(test))
    end
  end

  describe "operations" do
    setup do
      data = %{
        name: "plumber",
        description: "A pipeline abstraction",
        author: %{
          name: "Byzanteam",
          email: "dev@byzan.team"
        }
      }

      [data: data, resource: Resource.new(data)]
    end

    test "assign/3", %{resource: resource, test: test} do
      assert match?(%Resource{assigns: %{test: ^test}}, Resource.assign(resource, :test, test))
    end

    test "add_error/2", %{resource: resource, test: test} do
      assert match?(%Resource{errors: [^test]}, Resource.add_error(resource, test))
    end
  end
end
