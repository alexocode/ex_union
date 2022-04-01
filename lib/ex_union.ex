defmodule ExUnion do
  @moduledoc """
  Documentation for `ExUnion`.
  """

  alias __MODULE__.Definition

  defmacro defunion(ast) do
    definition = Definition.from(ast, env: __CALLER__)

    definition
    |> Definition.to_union()
    |> Macro.to_string()
    |> IO.puts()

    quote do
      @__union__ unquote(Macro.escape(definition))

      unquote(Definition.to_union(definition))
    end
  end
end
