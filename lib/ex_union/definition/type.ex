defmodule ExUnion.Definition.Type do
  @moduledoc false

  alias __MODULE__.Field

  @type t :: %__MODULE__{
          name: atom,
          module: module,
          fields: list(Field.t())
        }
  defstruct [:name, :module, :fields]

  def from(name, values, opts) do
    fields =
      values
      |> List.wrap()
      |> Enum.map(&Field.from/1)

    %__MODULE__{
      name: name,
      module: type_module(name, opts),
      fields: fields
    }
  end

  defp type_module(name, %{env: env}) do
    camelized =
      name
      |> Atom.to_string()
      |> Macro.camelize()

    Module.concat(env.module, camelized)
  end

  def to_struct(%__MODULE__{} = type) do
    quote do
      defmodule unquote(type.module) do
        # unquote(as_type_annotation(type))
        unquote(ast_for_defstruct(type))
        unquote(ast_for_new_function(type))
      end
    end
  end

  def to_shortcut_function(%__MODULE__{} = type) do
    arguments = ast_for_arguments(type)

    quote do
      defdelegate unquote(type.name)(unquote_splicing(arguments)),
        to: unquote(type.module),
        as: :new
    end
  end

  defp ast_for_defstruct(%__MODULE__{fields: fields}) do
    struct_fields = Enum.map(fields, & &1.name)

    quote do
      defstruct unquote(struct_fields)
    end
  end

  defp ast_for_new_function(%__MODULE__{} = type) do
    arguments = ast_for_arguments(type)
    arguments_mapped_to_struct_fields = Enum.map(type.fields, &{&1.name, &1.var})

    quote do
      def new(unquote_splicing(arguments)) do
        %__MODULE__{unquote_splicing(arguments_mapped_to_struct_fields)}
      end
    end
  end

  defp ast_for_arguments(%__MODULE__{fields: fields}) do
    Enum.map(fields, fn
      %Field{default: :none, var: var} -> var
      %Field{default: {:some, default}, var: var} -> {:\\, [], [var, default]}
    end)
  end
end
