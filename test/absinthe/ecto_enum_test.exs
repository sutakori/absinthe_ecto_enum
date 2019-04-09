defmodule Absinthe.EctoEnumTest do
  use ExUnit.Case
  doctest Absinthe.EctoEnum

  import EctoEnum
  defenum StatusEnum,
    new: 0, done: 1, abort: 2, error: 3

  defmodule StatusSchema do
    use Absinthe.Schema
    use Absinthe.EctoEnum
    import_ecto_enum StatusEnum

    query do
    end
  end

  test "are loaded" do
    type = StatusSchema.__absinthe_type__(:status_enum)
    assert %Absinthe.Type.Enum{} = type
    assert Enum.all?(type.values, fn v ->
      EctoEnum.valid_value?(v.value)
    end)
  end
end
