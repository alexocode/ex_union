defmodule ExUnion.Definition.Type.Field do
  @moduledoc false

  @type t :: %__MODULE__{
          name: atom,
          default: :none | {:some, any},
          type: Macro.t(),
          var: {name :: atom, Macro.metadata(), __MODULE__}
        }
  defstruct [:name, :default, :type, :var]

  def from({:"::", _meta, [variable, type]}) do
    new(variable, type: type)
  end

  def from({:\\, _meta, [variable, type]}) do
    new(variable, type: type)
  end

  def from(variable), do: new(variable)

  @base_default :none
  @base_type {:any, [], Elixir}
  defp new({name, _, _}, extra \\ []) do
    %__MODULE__{
      name: name,
      default: Keyword.get(extra, :default, @base_default),
      type: Keyword.get(extra, :type, @base_type),
      var: Macro.var(name, __MODULE__)
    }
  end
end
