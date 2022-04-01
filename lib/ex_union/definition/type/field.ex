defmodule ExUnion.Definition.Type.Field do
  @moduledoc false

  @type t :: %__MODULE__{
          name: atom,
          default: :none | {:some, any},
          type: Macro.t(),
          var: {name :: atom, Macro.metadata(), __MODULE__}
        }
  defstruct [:name, :default, :type, :var]

  def build({:"::", _meta, [variable, type]}) do
    do_build(variable, type: type)
  end

  def build({:\\, _meta, [variable, type]}) do
    do_build(variable, type: type)
  end

  def build(variable), do: do_build(variable)

  @base_default :none
  @base_type {:any, [], Elixir}
  defp do_build({name, _, _}, extra \\ []) do
    %__MODULE__{
      name: name,
      default: Keyword.get(extra, :default, @base_default),
      type: Keyword.get(extra, :type, @base_type),
      var: Macro.var(name, __MODULE__)
    }
  end
end
