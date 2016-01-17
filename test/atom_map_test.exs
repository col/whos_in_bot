defmodule AtomMapTest do
  use ExUnit.Case

  test "turns the keys of a map into atoms" do
    result = Atom.Chars.to_atom(%{"key" => "value"})
    assert result.key == "value"
  end

  test "turns the keys of nested maps into atoms" do
    result = Atom.Chars.to_atom(%{"key" => %{"nested_key" => "value"}})
    assert result.key.nested_key == "value"
  end

end
