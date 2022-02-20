defmodule ExBanking.Bank do
  alias ExBanking.User

  def create_user(user) do
    case User.create(user) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end

  def deposit(user, amount, currency) do
    with {:ok, _user} <- User.get(user) do
      User.deposit(user, amount, currency)
    end
  end

  def withdraw(user, amount, currency) do
    with {:ok, _user} <- User.get(user) do
      User.withdraw(user, amount, currency)
    end
  end

  def get_balance(user, currency) do
    with {:ok, _user} <- User.get(user) do
      User.get_balance(user, currency)
    end
  end

  def send(from_user, to_user, amount, currency) do
    with {:sender, {:ok, _from_user}} <- {:sender, User.get(from_user)},
         {:receiver, {:ok, _from_user}} <- {:receiver, User.get(to_user)},
         {:sender, {:ok, from_user_balance}} <-
           {:sender, User.withdraw(from_user, amount, currency)},
         {:receiver, {:ok, to_user_balance}} <-
           {:receiver, User.deposit(to_user, amount, currency)} do
      {:ok, from_user_balance, to_user_balance}
    else
      {:receiver, {:error, :too_many_requests_to_user}} ->
        User.deposit(from_user, amount, currency, :fast)
        {:error, :too_many_requests_to_receiver}

      error ->
        handle_errors(error)
    end
  end

  defp handle_errors({:sender, {:error, :user_does_not_exist}}),
    do: {:error, :sender_does_not_exist}

  defp handle_errors({:sender, {:error, :too_many_requests_to_user}}),
    do: {:error, :too_many_requests_to_sender}

  defp handle_errors({:receiver, {:error, :user_does_not_exist}}),
    do: {:error, :receiver_does_not_exist}

  defp handle_errors({:receiver, {:error, :too_many_requests_to_user}}),
    do: {:error, :too_many_requests_to_receiver}

  defp handle_errors({_, {:ok, state}}),
    do: {:ok, state}

  defp handle_errors({_, {:error, :not_enough_money}}),
    do: {:error, :not_enough_money}
end
