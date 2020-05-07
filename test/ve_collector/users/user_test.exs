defmodule VeCollector.Users.UserTest do
  use VeCollector.DataCase

  alias VeCollector.{Repo, Users, Users.User}

  @valid_params %{email: "test@example.com", password: "secret1234", password_confirmation: "secret1234"}

  test "changeset/2 set default role" do
    user = %User{}
    |> User.changeset(%{})
    |> Ecto.Changeset.apply_changes()

    assert user.role == "user"
  end

  test "changeset_role/2" do
    changeset = User.changeset_role(%User{}, %{role: "invalid"})
    assert changeset.errors[:role] == {"is invalid", [validation: :inclusion, enum: ["user", "admin"]]}

    changeset = User.changeset_role(%User{}, %{role: "admin"})
    refute changeset.errors[:role]
  end
end
