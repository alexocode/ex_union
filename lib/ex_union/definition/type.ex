defmodule ExUnion.Definition.Type do
  @moduledoc false

  alias __MODULE__.Field

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
    field_types = Enum.map(fields, &{&1.name, &1.type})
    field_names = Enum.map(fields, & &1.name)

    ast_for_has_fields_guard =
      fields
      |> Enum.map(fn %Field{name: name} ->
        quote do: :erlang.is_map_key(unquote(name), fields)
      end)
      |> Enum.reduce(&{:or, [], [&1, &2]})

    quote do
      @spec new(fields :: %{unquote_splicing(field_types)}) :: t()
      def new(fields) when is_map(fields) and unquote(ast_for_has_fields_guard) do
        struct!(__MODULE__, fields)
      end

      @spec new(fields :: unquote(field_types)) :: t()
      def new([{field, _} | _] = fields) when field in unquote(field_names) do
        struct!(__MODULE__, fields)
      end
    end
  end

  defp ast_for_simple_new_function(%__MODULE__{fields: fields}) do
    arguments = Enum.map(fields, & &1.var)
    arguments_with_types = Enum.map(fields, &{:"::", [], [&1.var, &1.type]})
    arguments_mapped_to_struct_fields = Enum.map(fields, &{&1.name, &1.var})

    # When we only have a single field we can easily generate an "overloaded contract"
    # where the "simple new/1" spec is a superset of the "matching new/1".
    # While this isn't an issue it does produce an "Overloaded contract" warning from
    # dialyzer, since dialyzer doesn't support this, but since nothing breaks we still
    # generate the @spec and silence this specific dialyzer warning to retain the type
    # information
    maybe_ignore_dialyzer_warning =
      if length(fields) == 1 do
        quote do
          @dialyzer {:no_contracts, new: 1}
        end
      end

    quote do
      unquote(maybe_ignore_dialyzer_warning)
      @spec new(unquote_splicing(arguments_with_types)) :: t()
      def new(unquote_splicing(arguments)) do
        %__MODULE__{unquote_splicing(arguments_mapped_to_struct_fields)}
      end
    end
  end

  def to_shortcut_function(%__MODULE__{fields: fields} = type) do
    arguments = Enum.map(fields, & &1.var)
    arguments_with_types = Enum.map(fields, &{:"::", [], [&1.var, &1.type]})
    field_types = Enum.map(fields, &{&1.name, &1.type})

    arity_1_shortcut =
      quote do
        @spec unquote(type.name)(fields :: %{unquote_splicing(field_types)}) ::
                unquote(type.module).t()
        @spec unquote(type.name)(fields :: unquote(field_types)) :: unquote(type.module).t()
        defdelegate unquote(type.name)(fields),
          to: unquote(type.module),
          as: :new
      end

    arity_n_shortcut =
      quote do
        @spec unquote(type.name)(unquote_splicing(arguments_with_types)) ::
                unquote(type.module).t()
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
