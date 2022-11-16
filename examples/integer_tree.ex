defmodule IntegerTree do
  import ExUnion

  # You can also use `t` instead of `union` if you prefer
  defunion leaf | node(integer :: integer, left :: union, right :: union)
end
