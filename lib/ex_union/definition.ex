defmodule ExUnion.Definition do
  @moduledoc false

  alias __MODULE__.{Block, Type}

  @type t :: %__MODULE__{
          name: atom,
          module: module,
          types: list(Type.t())
        }
  defstruct [:name, :module, :types]

  def build(ast, opts) when not is_map(opts) do
    build(ast, Map.new(opts))
  end

  def build(ast, %{env: env} = opts) do
    %__MODULE__{
      name: determine_name(env.module),
      module: env.module,
      types: extract_types(ast, opts)
    }
  end

  defp determine_name(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
  end

  defp extract_types({:|, _meta, types}, opts) do
    Enum.flat_map(types, &extract_types(&1, opts))
  end

  defp extract_types({name, _meta, values}, opts) do
    [Type.build(name, values, opts)]
  end

  def to_union(%__MODULE__{} = union) do
    Block.from([
      ast_for_structs(union),
      ast_for_type(union),
      ast_for_shortcut_functions(union),
      ast_for_guard(union)
    ])
  end

  defp ast_for_structs(%__MODULE__{types: types}) do
    Enum.map(types, &Type.to_struct/1)
  end

  defp ast_for_shortcut_functions(%__MODULE__{types: types}) do
    Enum.map(types, &Type.to_shortcut_function/1)
  end

  defp ast_for_type(%__MODULE__{types: types}) do
    union =
      types
      |> Enum.map(fn %Type{module: module} ->
        quote do
          unquote(module).t()
        end
      end)
      |> Enum.reduce(&{:|, [], [&1, &2]})

    quote do
      @type t :: unquote(union)
    end
  end

  defp ast_for_guard(%__MODULE__{name: name, types: types}) do
    guard_name = :"is_#{name}"
    value = Macro.var(:value, __MODULE__)
    modules = Enum.map(types, & &1.module)

    quote do
      defguard unquote(guard_name)(unquote(value))
               when is_map(unquote(value)) and
                      :erlang.is_map_key(:__struct__, unquote(value)) and
                      :erlang.map_get(:__struct__, unquote(value)) in unquote(modules)
    end
  end
end
