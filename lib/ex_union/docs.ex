defmodule ExUnion.Docs do
  @moduledoc false

  def massage_readme(path, for: module) do
    path
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(fn
      # Drop the headline if it's equal to the module name
      "# " <> ^module ->
        true

      # Drop Overview h4 links, as they can't be linked on hexdocs.pm
      "    - [" <> _ ->
        true

      _ ->
        false
    end)
    |> Enum.map_join("\n", fn line ->
      line
      # Adjust the Overview links to work on hexdocs.pm
      |> String.replace(~r/\(#([^\)]+)\)/, "(#module-\\1)")
      # Adjust the code links to work on hexdocs.pm
      |> String.replace(~r/\[(.+?)\]\[code:.+?\]/, "\\1")
      # Replace TODO-style boxes from list items
      |> String.replace("- [ ]", "- ◻")
      |> String.replace("- [x]", "- ✔")
    end)
  end
end
