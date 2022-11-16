defmodule Maybe do
  import ExUnion

  defunion some(value) | none
end
