defmodule UseCase.WithRawValuesTest do
  use ExUnit.Case, async: true

  test "properly compiles a union which contains raw values as typespecs" do
    defmodule Union1 do
      import ExUnion

      defunion with_atom(value :: :an_atom)
               | with_integer(value :: 42)
               | with_boolean(value :: true)
               | with_list(value :: [])
               | with_map(value :: %{})
               | with_tuple(value :: {:ok, :value})
    end
  end
end
