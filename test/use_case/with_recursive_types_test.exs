defmodule UseCase.WithRecursiveTypesTest do
  use ExUnit.Case, async: true

  test "properly compiles an union with a recursive type to the union itself" do
    defmodule IntegerTree do
      import ExUnion

      defunion leaf
               | node(integer :: integer, left :: t, right :: t)
    end
  end

  test "properly compiles an union with a recursive type to a subtype of the union" do
    defmodule Color do
      import ExUnion

      defunion hex(string :: String.t())
               | rgb(red :: 0..255, green :: 0..255, blue :: 0..255)
               | rgba(rgb :: __MODULE__.Rgb.t(), alpha :: float)
               | hsl(hue :: 0..360, saturation :: float, lightness :: float)
               | hsla(hsl :: __MODULE__.Hsl.t(), alpha :: float)
    end
  end
end
