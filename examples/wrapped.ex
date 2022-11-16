    defmodule Wrapped do
      import ExUnion

      defunion tuple(value :: {:ok, union})
               | map(value :: %{any => union})
               | function(value :: (union_keyword -> union_map))
               | list(value :: [union])
               | keyword(value :: [{atom, union}])
    end
