# ExUnion
[![CI](https://github.com/sascha-wolf/ex_union/workflows/CI/badge.svg)](https://github.com/sascha-wolf/ex_union/actions?query=workflow%3ACI+branch%3Amain)
[![Coverage Status](https://coveralls.io/repos/github/sascha-wolf/ex_union/badge.svg?branch=main)](https://coveralls.io/github/sascha-wolf/ex_union?branch=main)
[![Hexdocs.pm](https://img.shields.io/badge/hexdocs-online-blue)](https://hexdocs.pm/ex_union)
[![Hex.pm](https://img.shields.io/hexpm/v/ex_union.svg)](https://hex.pm/packages/ex_union)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dt/ex_union)](https://hex.pm/packages/ex_union)

**TODO: Add description**

## Overview

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Roadmap](#roadmap)

## Installation

Add [`ex_union`][hex] to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_union, "~> 0.1.0"}
  ]
end
```

Differences between the versions are explained in [the Changelog](./CHANGELOG.md).

Documentation gets generated with [ExDoc](https://github.com/elixir-lang/ex_doc) and can be viewed at [HexDocs][hexdocs].

## Usage

**TODO: Write documentation**

```elixir
defmodule Maybe do
  import ExUnion

  defunion some(value) | none
end
```

compiles to

```
defmodule Maybe do
  @type t :: Maybe.None.t() | Maybe.Some.t()

  defmodule Maybe.Some do
    @type t :: %__MODULE__{value: any}
    defstruct [:value]

    def new(fields) when is_map(fields) and :erlang.is_map_key(:value, fields) do
      fields |> Map.to_list() |> new_from_fields()
    end

    def new([{field, _} | _] = fields) when field in [:value] do
      new_from_fields(fields)
    end

    def new(value) do
      %__MODULE__{value: value}
    end

    defp new_from_fields([{:value, value} | rest]) do
      %__MODULE__{new_from_fields(rest) | value: value}
    end

    defp new_from_fields([]) do
      %__MODULE__{}
    end

    defp new_from_fields(other) do
      names = "value"

      raise ArgumentError,
            "expected a keyword pair for #{names} but received: " <> inspect(other)
    end
  end

  defmodule Maybe.None do
    @type t :: %__MODULE__{}
    defstruct []

    def new() do
      %__MODULE__{}
    end
  end

  defdelegate some(value), to: Maybe.Some, as: :new
  defdelegate none(), to: Maybe.None, as: :new

  defguard is_maybe(value)
           when is_map(value) and :erlang.is_map_key(:__struct__, value) and
                  :erlang.map_get(:__struct__, value) in [Maybe.Some, Maybe.None]
end
```

## Roadmap

- [ ] Figure out a way to derive protocol implementations for union structs (e.g. for `Jason`)

[hex]: https://hex.pm/packages/ex_union
[hexdocs]: https://hexdocs.pm/ex_union