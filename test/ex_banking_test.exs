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

  describe "deposit/3" do
    setup do
      ExBanking.create_user("user")
    end

    test "success deposit" do
      assert {:ok, 0.10} == ExBanking.deposit("user", 10, "currency")
    end

    test "success deposit changes balance in different currencies" do
      assert {:ok, 0.10} == ExBanking.deposit("user", 10, "currency")
      assert {:ok, 3.00} == ExBanking.deposit("user", 300, "currency2")
    end

    test "fail when user does not exist" do
      assert {:error, :user_does_not_exist} == ExBanking.deposit("user2", 10, "currency")
    end

    test "fail when wrong arguments" do
      assert {:error, :wrong_arguments} == ExBanking.deposit(nil, 10, "currency")
      assert {:error, :wrong_arguments} == ExBanking.deposit("user", -10, "currency")
    end
  end

  describe "withdraw/3" do
    setup do
      ExBanking.create_user("user")
    end

    test "success withdraw" do
      ExBanking.deposit("user", 10, "currency")
      assert {:ok, 0.0} == ExBanking.withdraw("user", 10, "currency")
    end

    test "success withdraw from different currency" do
      ExBanking.deposit("user", 10, "currency")
      ExBanking.deposit("user", 20, "currency2")
      assert {:ok, 0.0} == ExBanking.withdraw("user", 20, "currency2")
    end

    test "fail when not enough money" do
      assert {:error, :not_enough_money} == ExBanking.withdraw("user", 10, "currency")
    end

    test "fail when user does not exist" do
      assert {:error, :user_does_not_exist} == ExBanking.withdraw("user2", 10, "currency")
    end

    test "fail when wrong arguments" do
      assert {:error, :wrong_arguments} == ExBanking.withdraw(nil, 10, "currency")
      assert {:error, :wrong_arguments} == ExBanking.withdraw("user", -10, "currency")
    end
  end
end
