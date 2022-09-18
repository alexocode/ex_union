defmodule ExUnion.Definition.Block do
  @moduledoc false

  def from(parts) do
    {
      :__block__,
      [],
      List.flatten([parts])
    }
  end
end
