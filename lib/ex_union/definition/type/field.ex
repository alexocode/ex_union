defmodule ExUnion.Definition.Type.Field do
  @moduledoc false

  @type t :: %__MODULE__{
          name: atom,
          default: :none | {:some, any},
          type: Macro.t(),
          var: {name :: atom, Macro.metadata(), __MODULE__}
        }
  defstruct [:name, :default, :type, :var]

  def build({:"::", _meta, [variable, type]}, %{env: env}) do
    type = massage_type(type, env)

    do_build(variable, type)
  end

  def build(variable, _opts), do: do_build(variable)

  defp massage_type(ast, env) do
    Macro.postwalk(ast, fn
      {name, _, _} = type ->
        cond do
          name == :__aliases__ or match?({:., _, _}, name) ->
            dealias_type(type, env)

          name in [:t, :union] or starts_with?(name, "union_") ->
            namespace_type(type, env.module)

          # Fallback
          true ->
            type
        end

      other ->
        other
    end)
  end

  defp starts_with?(ast, string) do
    case ast do
      name when is_atom(name) ->
        name
        |> Atom.to_string()
        |> String.starts_with?(string)

      _other ->
        false
    end
  end

  defp dealias_type({{:., meta1, [module, function]}, meta2, arguments}, env) do
    full_module = dealias_type(module, env)

    {{:., meta1, [full_module, function]}, meta2, arguments}
  end

  defp dealias_type({:__aliases__, meta, [{:__MODULE__, _, _} | nested]}, env) do
    build_alias(env.module, nested, meta)
  end

  defp dealias_type({:__aliases__, meta, [maybe_alias | nested]} = module_ast, env) do
    case Keyword.fetch(env.aliases, :"Elixir.#{maybe_alias}") do
      {:ok, full_module} ->
        build_alias(full_module, nested, meta)

      :error ->
        module_ast
    end
  end

  defp build_alias(module, nested, meta) do
    module_parts =
      module
      |> Module.split()
      |> Enum.map(&String.to_atom/1)

    {:__aliases__, meta, module_parts ++ nested}
  end

  defp namespace_type({type, meta, _}, module) do
    {{:., meta, [module, type]}, meta, []}
  end

  @default_type {:any, [], Elixir}
  defp do_build({name, _, _}, type \\ @default_type) do
    %__MODULE__{
      name: name,
      type: type,
      var: Macro.var(name, __MODULE__)
    }
  end
end
