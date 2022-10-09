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

  defp massage_type(type, env) do
    case type do
      {:t, _, _} ->
        prefix_t(type, env)

      {{:., _, _}, _, _} ->
        dealias_type(type, env)

      {:__aliases__, _, _} ->
        dealias_type(type, env)

      other ->
        other
    end
  end

  defp prefix_t({:t, meta, _} = t, env) do
    {{:., meta, [env.module, t]}, meta, []}
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

  @default_type {:any, [], Elixir}
  defp do_build({name, _, _}, type \\ @default_type) do
    %__MODULE__{
      name: name,
      type: type,
      var: Macro.var(name, __MODULE__)
    }
  end
end
