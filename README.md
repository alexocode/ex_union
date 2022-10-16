# ExUnion
[![CI](https://github.com/sascha-wolf/ex_union/workflows/CI/badge.svg)](https://github.com/sascha-wolf/ex_union/actions?query=workflow%3ACI+branch%3Amain)
[![Coverage Status](https://coveralls.io/repos/github/sascha-wolf/ex_union/badge.svg?branch=main)](https://coveralls.io/github/sascha-wolf/ex_union?branch=main)
[![Hexdocs.pm](https://img.shields.io/badge/hexdocs-online-blue)](https://hexdocs.pm/ex_union)
[![Hex.pm](https://img.shields.io/hexpm/v/ex_union.svg)](https://hex.pm/packages/ex_union)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dt/ex_union)](https://hex.pm/packages/ex_union)

Tagged Unions for Elixir.
Just that.

## Overview

- [Overview](#overview)
- [Installation](#installation)
- [Motivation](#motivation)
- [Usage](#usage)
  - [Example: Multiple Fields](#example-multiple-fields)
  - [Example: Adding Type Specifications](#example-adding-type-specifications)
  - [Example: Adding Recursive Type Specifications](#example-adding-recursive-type-specifications)
  - [Example: If you'd write all this by hand](#example-if-youd-write-all-this-by-hand)
- [Comparison](#comparison)
  - [`Algae`](#algae)
  - [`Ok`](#ok-or-wormholeelixirwormhole)
- [Roadmap](#roadmap)
- [Contributing](#contributing)

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

## Motivation

`ExUnion` is meant to be a lightweight, elixir-y implementation of [tagged unions](https://en.wikipedia.org/wiki/Tagged_union) (also called variant, discriminated union, sum type, etc.).

While conventionally Elixir tends to promote using tuples to model tagged unions - the `{:ok, ...} | {:error, ...}` pattern being a good example of that - this approach arguably lacks expressiveness, especially when modeling non-trivial unions.
An alternative is to employ structs to model the individual cases of a tagged union, which works nicely but has the disadvantage of requiring significant boilerplate code.

`ExUnion` attempts to bridge this gap by generating the necessary boilerplate (and a bit more) through a concise albeit opinionated DSL.

## Usage

To get an idea on how you can use `ExUnion` let's look at an example:

```elixir
defmodule Maybe do
  import ExUnion

  defunion some(value) | none
end
```

The `defunion` macro takes a type-spec similar definition and generates a bunch of code from it.
Let's see how we can use `Maybe` now, shall we?

```elixir
iex> Maybe.none()
%Maybe.None{}

iex> Maybe.some("string!")
%Maybe.Some{value: "string!"}

# Requiring is necessary since `is_maybe` is a guard (defguard)
iex> require Maybe
iex> Maybe.is_maybe("What's the meaning of life, the universe, and everything?")
false
iex> Maybe.is_maybe(42)
false
iex> Maybe.is_maybe(Maybe.none())
true
```

As you can see `ExUnion` generates a number of things from the definition:

- a struct for each case of the union (including type specs)
- a shortcut function for each case to create said struct (including `@spec`s)
- a shortcut type spec for each case and the general union (`t`, `union`, `union_<case>`)
- a guard that returns `true` if the given value is part of the union

Check out the additional examples below to get a better impression of what `ExUnion` offers.

### Example: Multiple Fields

```elixir
defmodule Shape do
  import ExUnion

  defunion circle(radius)
           | square(side)
           | rectangle(width, height)
end

iex> Shape.circle(3)
%Shape.Circle{radius: 3}

iex> Shape.square(side: 4)
%Shape.Square{side: 4}

iex> Shape.rectangle(4, 2)
%Shape.Rectangle{width: 4, height: 2}

iex> Shape.rectangle(height: 2, width: 4)
%Shape.Rectangle{width: 4, height: 2}
```

### Example: Adding Type Specifications

```elixir
defmodule Color do
  import ExUnion

  defunion hex(string :: String.t)
           | rgb(red :: 0..255, green :: 0..255, blue :: 0..255)
           | rgba(red :: 0..255, green :: 0..255, blue :: 0..255, alpha :: float)
           | hsl(hue :: 0..360, saturation :: float, lightness :: float)
           | hsla(hue :: 0..360, saturation :: float, lightness :: float, alpha :: float)
end
```

### Example: Adding Recursive Type Specifications

```elixir
defmodule IntegerTree do
  import ExUnion

  # You can also use `t` instead of `union` if you prefer
  defunion leaf | node(integer :: integer, left :: union, right :: union)
end
```

If necessary you can ever refer to individual cases of the union.
Let's revisit the `Color` example for above and how we can use recursive types to reuse the `rbg` and `hsl` definitions:

```elixir
defmodule Color do
  import ExUnion

  defunion hex(string :: String.t)
           | rgb(red :: 0..255, green :: 0..255, blue :: 0..255)
           | rgba(rgb :: union_rgb, alpha :: float)
           | hsl(hue :: 0..360, saturation :: float, lightness :: float)
           | hsla(hsl :: union_hsl, alpha :: float)
end
```

### Example: If you'd write all this by hand

To give you more of an idea on the kind of code `ExUnion` generates for you, let's look at what you'd have to write out to get something equivalent.
For this we'll use the `Maybe` example from earlier again.

```elixir
defmodule Maybe do
  @type t :: union
  @type union :: Maybe.None.t() | Maybe.Some.t()
  @type union_some :: Maybe.Some.t()
  @type union_none :: Maybe.None.t()

  defmodule Some do
    @type t :: %__MODULE__{value: any}
    defstruct [:value]

    @spec new(fields :: %{value: any}) :: t
    def new(fields) when is_map(fields) and :erlang.is_map_key(:value, fields) do
      struct!(__MODULE__, fields)
    end

    @spec new(fields :: [value: any]) :: t
    def new([{field, _} | _] = fields) when field in [:value] do
      struct!(__MODULE__, fields)
    end

    @spec new(value :: any) :: t
    def new(value) do
      %__MODULE__{value: value}
    end
  end

  defmodule None do
    @type t :: %__MODULE__{}
    defstruct []

    @spec new() :: t
    def new() do
      %__MODULE__{}
    end
  end

  defdelegate some(value), to: Maybe.Some, as: :new
  defdelegate none(), to: Maybe.None, as: :new

  defguard is_maybe(value)
           when is_map(value) and :erlang.is_map_key(:__struct__, value) and
                  :erlang.map_get(:__struct__, value) in [Some, None]
end
```

Out of a single line of `defunion some(value) | none` `ExUnion` generated over 30 lines of code.
And while the specifics of the generated code are opinionated in places, they do have a lot lower information density than the `defunion` line.

## Comparison

`ExUnion` can be compared to a number of other libraries.

### [`Algae`][elixir:algae]

[`Algae`][elixir:algae] offers for "algebraic data types for Elixir".

Some people might prefer that, and that's perfectly fine!
I think [`Algae`][elixir:algae] (and it's big brother [`Witchcraft`][elixir:witchcraft]) are amazing projects and should be used more - but I also think that they come with a lot of inborn complexity.

Not everybody is familiar with "algebraic data types" and arguably not everybody needs to be!
But on the other hand there's a lot of goodness in the tools they bring to the table.

[`Algea`][elixir:algae] also offers its own flavor of tagged unions (or rather sum types) but also with more than that.
`ExUnion` by design __only__ implements tagged unions and nothing more - as they are a tool most developers probably are familiar with - in an attempt to be as approachable and self-explanatory as possible.

At some point you and/or your team might decide to take the next step and use [`Algae`][elixir:algae] or even [`Witchcraft`][elixir:witchcraft] and `ExUnion` will be happy to have been part of your journey.
Or maybe `ExUnion` is all you need and that would be fine too.

### [`Ok`][elixir:ok] or [`Wormhole`][elixir:wormhole]

[`Ok`][elixir:ok] and [`Wormhole`][elixir:wormhole] both aim to provide additional tools to work with Elixir's most well-known tagged union: `{:ok, value}` and `{:error, reason}`.
But they do only that.

If you want more tools to deal with `{:ok, value}` and `{:error, reason}` tuples, then they are great libraries.
But if you want additional tools to model similar tagged unions, then these libraries don't help you.

`ExUnion` doesn't pretend to help you with `{:ok, value}` / `{:error, reason}`.
This isn't the motivation behind the project.
It does however give you more power to escape the limits of using tagged tuples to model unions.

## Roadmap

- [ ] Figure out a way to derive protocol implementations for union structs (e.g. for `Jason`)

## Contributing

Contributions are always welcome but please read [our contribution guidelines](./CONTRIBUTING.md) before doing so.

[elixir:algae]: https://github.com/witchcrafters/algae
[elixir:ok]: https://github.com/CrowdHailer/OK
[elixir:witchcraft]: https://github.com/witchcrafters/witchcraft
[elixir:wormhole]: https://github.com/renderedtext/wormhole
[hex]: https://hex.pm/packages/ex_union
[hexdocs]: https://hexdocs.pm/ex_union
