defmodule UseCase.WithSimpleTypesTest.Shape do
  import ExUnion

  defunion circle(radius :: float)
           | rectangle(height :: float, width :: float)
           | triangle(base :: float, height :: float)
end

defmodule UseCase.WithSimpleTypesTest do
  use ExUnit.Case, async: true

  alias __MODULE__.Shape

  require Shape

  test "generates struct definitions for Shape.Circle, Shape.Rectangle, and Shape.Triangle" do
    assert %Shape.Circle{}
    assert %Shape.Rectangle{}
    assert %Shape.Triangle{}
  end

  test "generates Shape.circle/1, Shape.rectangle/2, and Shape.triangle/2 construction shortcuts" do
    assert Shape.circle(1.5) == %Shape.Circle{radius: 1.5}
    assert Shape.rectangle(1.5, 2.5) == %Shape.Rectangle{height: 1.5, width: 2.5}
    assert Shape.triangle(1.5, 2.5) == %Shape.Triangle{base: 1.5, height: 2.5}
  end

  test "generates Shape.is_shape/1 guard which checks if value is part of the union" do
    checker = fn
      value when Shape.is_shape(value) -> :ok
      _ -> :error
    end

    assert checker.(:some_value) == :error
    assert checker.("another value") == :error
    assert checker.(Shape.circle(1.5)) == :ok
    assert checker.(Shape.rectangle(1.5, 2.5)) == :ok
    assert checker.(Shape.triangle(1.5, 2.5)) == :ok
  end
end
