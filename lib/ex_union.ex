defmodule ExUnion do
  readme = "README.md"

  @external_resource readme
  @moduledoc ExUnion.Docs.massage_readme(readme, for: "ExUnion")

  alias __MODULE__.Definition

  defmacro defunion(ast) do
    definition = Definition.build(ast, env: __CALLER__)

    quote do
      @__union__ unquote(Macro.escape(definition))

      unquote(Definition.to_union(definition))
    end
  end
end
