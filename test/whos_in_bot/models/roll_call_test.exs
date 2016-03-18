defmodule WhosInBot.Models.RollCallTest do
  use ExUnit.Case
  alias WhosInBot.Models.RollCall

  @valid_attrs %{chat_id: 42, date: 1451868542, status: "some content", quiet: false}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RollCall.changeset(%RollCall{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RollCall.changeset(%RollCall{}, @invalid_attrs)
    refute changeset.valid?
  end

end
