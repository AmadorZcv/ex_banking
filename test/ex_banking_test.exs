defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  describe "create_user/1" do
    test "success user creation" do
      assert :ok == ExBanking.create_user("user")
    end

    test "success user creation case sensitive" do
      assert :ok == ExBanking.create_user("user")
      assert :ok == ExBanking.create_user("User")
    end

    test "error when creating same user" do
      assert :ok == ExBanking.create_user("user")
      assert {:error, :user_already_exists} == ExBanking.create_user("user")
    end

    test "error when wrong arguments" do
      assert {:error, :wrong_arguments} == ExBanking.create_user(nil)
      assert {:error, :wrong_arguments} == ExBanking.create_user(:user_atom)
      assert {:error, :wrong_arguments} == ExBanking.create_user(123)
    end
  end
end
