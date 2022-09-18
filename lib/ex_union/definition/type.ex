defmodule ExUnion.Definition.Type do
  @moduledoc false

  alias __MODULE__.Field
  alias ExUnion.Definition.Block

  @type t :: %__MODULE__{
          name: atom,
          module: module,
          fields: list(Field.t())
        }
  defstruct [:name, :module, :fields]

  def build(name, values, opts) do
    fields =
      values
      |> List.wrap()
      |> Enum.map(&Field.build(&1, opts))

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
        unquote(ast_for_type(type))
        unquote(ast_for_defstruct(type))
        unquote(ast_for_new_function(type))
      end
    end
  end

  defp ast_for_type(%__MODULE__{fields: fields}) do
    field_types = Enum.map(fields, &{&1.name, &1.type})

    quote do
      @type t :: %__MODULE__{unquote_splicing(field_types)}
    end
  end

  defp ast_for_defstruct(%__MODULE__{fields: fields}) do
    struct_fields = Enum.map(fields, & &1.name)

    quote do
      defstruct unquote(struct_fields)
    end
  end

  defp ast_for_new_function(%__MODULE__{} = type) do
    quote do
      unquote(ast_for_matching_new_function(type))
      unquote(ast_for_simple_new_function(type))
    end
  end

  defp ast_for_matching_new_function(%__MODULE__{fields: []}) do
    nil
  end

  defp ast_for_matching_new_function(%__MODULE__{fields: fields}) do
    field_names = Enum.map(fields, & &1.name)

    ast_for_delegating_new =
      quote do
        def new([{field, _} | _] = fields) when field in unquote(field_names) do
          new_from_fields(fields)
        end
      end

    ast_for_new_from_fields =
      for field <- fields do
        tuple = {field.name, field.var}

        quote do
          defp new_from_fields([unquote(tuple) | rest]) do
            %__MODULE__{new_from_fields(rest) | unquote(tuple)}
          end
        end
      end

    ast_for_new_from_fields_fallback =
      quote do
        defp new_from_fields([]) do
          %__MODULE__{}
        end

        defp new_from_fields(other) do
          names = unquote(Enum.join(field_names, "/"))

          raise ArgumentError,
                "expected a keyword pair for #{names} but received: " <> inspect(other)
        end
      end

    Block.from([
      ast_for_delegating_new,
      ast_for_new_from_fields,
      ast_for_new_from_fields_fallback
    ])
  end

  defp ast_for_simple_new_function(%__MODULE__{fields: fields}) do
    arguments = Enum.map(fields, & &1.var)
    arguments_mapped_to_struct_fields = Enum.map(fields, &{&1.name, &1.var})

    quote do
      def new(unquote_splicing(arguments)) do
        %__MODULE__{unquote_splicing(arguments_mapped_to_struct_fields)}
      end
    end
  end

  def to_shortcut_function(%__MODULE__{} = type) do
    arguments = Enum.map(type.fields, & &1.var)

    arity_1_shortcut =
      quote do
        defdelegate unquote(type.name)(fields),
          to: unquote(type.module),
          as: :new
      end

    arity_n_shortcut =
      quote do
        defdelegate unquote(type.name)(unquote_splicing(arguments)),
          to: unquote(type.module),
          as: :new
      end

    if length(arguments) > 1 do
      quote do
        unquote(arity_1_shortcut)
        unquote(arity_n_shortcut)
      end
    else
      arity_n_shortcut
    end
  end
end
