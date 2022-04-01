defmodule UseCase.WithRemoteTypesTest do
  use ExUnit.Case, async: true

  test "properly compiles an union with a remote typed union" do
    defmodule RemoteTypeUnion1 do
      import ExUnion

      defunion option(value :: String.t())
    end
  end

  test "properly compiles an union with a remote typed union using an alias" do
    defmodule RemoteTypeUnion2 do
      import ExUnion

      defmodule Typed do
        @type t :: :whatever
      end

      defunion option(value :: Typed.t())
    end
  end

  test "properly compiles an union with a remote typed union using a nested alias" do
    defmodule RemoteTypeUnion3 do
      import ExUnion

      defmodule Typed do
        defmodule Nested do
          @type t :: :whatever
        end
      end

      defunion option(value :: Typed.Nested.t())
    end
  end

  test "properly compiles an union with a remote typed union using the __MODULE__ prefix" do
    defmodule RemoteTypeUnion4 do
      import ExUnion

      defmodule Typed do
        @type t :: :whatever
      end

      defunion option(value :: __MODULE__.Typed.t())
    end
  end
end
