defmodule UseCase.WithSimpleMaybeTest.Maybe do
  import ExUnion

  defunion some(value) | none
end

defmodule UseCase.WithSimpleMaybeTest do
  use ExUnit.Case, async: true

  alias __MODULE__.Maybe

  require Maybe

  test "generates struct definitions for Maybe.Some and Maybe.None" do
    assert %Maybe.Some{value: "my value"}
    assert %Maybe.None{}
  end

  test "generates Maybe.some/1 and Maybe.none/0 as construction shortcuts" do
    value = make_ref()

    assert Maybe.some(value) == %Maybe.Some{value: value}
    assert Maybe.none() == %Maybe.None{}
  end

  test "generates is_maybe guard which checks if value belongs to union" do
    checker = fn
      value when Maybe.is_maybe(value) -> :ok
      _ -> :error
    end

    assert checker.(:some_value) == :error
    assert checker.("another value") == :error
    assert checker.(Maybe.some("value")) == :ok
    assert checker.(Maybe.none()) == :ok
  end
end
