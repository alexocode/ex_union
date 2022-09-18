defmodule UseCase.WithMultipleFields do
  use ExUnit.Case, async: true

  defmodule MyUnion do
    import ExUnion

    defunion one(field) | two(field1, field2) | three(field1, field2, field3)
  end

  test "generates shortcut methods which also accept the field names" do
    assert MyUnion.one(field: "whatever") == %MyUnion.One{
             field: "whatever"
           }

    assert MyUnion.two(field1: "whatever", field2: "more") == %MyUnion.Two{
             field1: "whatever",
             field2: "more"
           }

    assert MyUnion.three(field1: "whatever", field2: "more", field3: "stuff") == %MyUnion.Three{
             field1: "whatever",
             field2: "more",
             field3: "stuff"
           }
  end

  test "raises a descriptive error when passing an invalid field name" do
    assert_raise ArgumentError,
                 "expected a keyword pair for field1/field2 but received: [fild2: \"this has a typo\"]",
                 fn ->
                   MyUnion.two(field1: "whatever", fild2: "this has a typo")
                 end
  end
end
