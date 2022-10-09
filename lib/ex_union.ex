defmodule ExUnion do
  readme = "README.md"

  @external_resource readme
  @moduledoc ExUnion.Docs.massage_readme(readme, for: "ExUnion")

  alias __MODULE__.Definition

  defmacro defunion(ast) do
    definition = Definition.build(ast, env: __CALLER__)

    quote do
      unquote(Definition.to_union(definition))

      @spec __union__() :: ExUnion.Definition.t()
      @__union__ unquote(Macro.escape(definition))
      def __union__, do: @__union__
    end
  end
end
