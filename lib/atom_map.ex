defprotocol Atom.Chars do
  def to_atom(thing)
end

defimpl Atom.Chars, for: Map do

  def to_atom(map) when is_map(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), to_atom(val)}
  end

  def to_atom(val) do
    val
  end

end
