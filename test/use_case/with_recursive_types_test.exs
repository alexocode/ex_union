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
               | rgba(rgb :: union_rgb, alpha :: float)
               | hsl(hue :: 0..360, saturation :: float, lightness :: float)
               | hsla(hsl :: union_hsl, alpha :: float)
    end
  end

  test "properly compiles an union with a recursive type inside of datatypes" do
    defmodule Union1 do
      import ExUnion

      defunion tuple(value :: {:ok, union})
               | map(value :: %{any => union})
               | function(value :: (union_keyword -> union_map))
               | list(value :: [union])
               | keyword(value :: [{atom, union}])
    end
  end
end
