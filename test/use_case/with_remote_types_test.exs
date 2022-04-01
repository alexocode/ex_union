defmodule UseCase.WithRemoteTypesTest.MyUnion do
  import ExUnion

  defmodule MyStruct do
    @type t :: %__MODULE__{}
    defstruct []
  end

  defunion thing(my_struct :: MyStruct.t())
end

defmodule UseCase.WithRemoteTypesTest do
  use ExUnit.Case, async: true

  alias __MODULE__.MyUnion

  require MyUnion

  test "generates struct definitions for MyUnion.Thing" do
    assert %MyUnion.Thing{}
  end

  test "generates MyUnion.thing/1 construction shortcuts" do
    assert MyUnion.thing(%MyUnion.MyStruct{}) == %MyUnion.Thing{my_struct: %MyUnion.MyStruct{}}
  end

  test "generates MyUnion.is_my_union/1 guard which checks if value is part of the union" do
    checker = fn
      value when MyUnion.is_my_union(value) -> :ok
      _ -> :error
    end

    assert checker.(:some_value) == :error
    assert checker.("another value") == :error
    assert checker.(MyUnion.thing(%MyUnion.MyStruct{})) == :ok
  end
end
