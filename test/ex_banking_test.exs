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

  describe "get_balance/2" do
    setup do
      ExBanking.create_user("user")
      ExBanking.deposit("user", 10, "currency")
      :ok
    end

    test "success get_balance" do
      assert {:ok, 0.10} == ExBanking.get_balance("user", "currency")
    end

    test "success get_balance in different currency" do
      assert {:ok, 0.0} == ExBanking.get_balance("user", "currency2")
    end

    test "fail when user does not exist" do
      assert {:error, :user_does_not_exist} == ExBanking.get_balance("user2", "currency2")
    end

    test "fail when wrong arguments" do
      assert {:error, :wrong_arguments} == ExBanking.get_balance(nil, "currency2")
      assert {:error, :wrong_arguments} == ExBanking.get_balance("user", nil)
    end
  end

  describe "send/4" do
    setup do
      ExBanking.create_user("from_user")
      ExBanking.deposit("from_user", 10, "currency")
      ExBanking.create_user("to_user")
    end

    test "success send" do
      assert {:ok, 0.0, 0.10} == ExBanking.send("from_user", "to_user", 10, "currency")
    end

    test "fail sender or receiver does not exist" do
      assert {:error, :sender_does_not_exist} ==
               ExBanking.send("from_user1", "to_user", 10, "currency")

      assert {:error, :receiver_does_not_exist} ==
               ExBanking.send("from_user", "to_user1", 10, "currency")
    end

    test "fail sender not enough money" do
      assert {:error, :not_enough_money} ==
               ExBanking.send("from_user", "to_user", 100, "currency")
    end

    test "fail when wrong arguments" do
      assert {:error, :wrong_arguments} == ExBanking.send(nil, "to_user", 100, "currency")
      assert {:error, :wrong_arguments} == ExBanking.send("from_user", nil, 10, "currency")
      assert {:error, :wrong_arguments} == ExBanking.send("from_user", "to_user", -10, "currency")
      assert {:error, :wrong_arguments} == ExBanking.send("from_user", "to_user1", 10, nil)
    end
  end
end
