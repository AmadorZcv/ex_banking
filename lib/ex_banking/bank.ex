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
    with {:ok, %{currencies: currencies}} <- User.get(user) do
      {:ok, Map.get(currencies, currency, 0)}
    end
  end

  def send(from_user, to_user, amount, currency) do
    with {:ok, _from_user} <- User.get(from_user) |> handle_from_user_errors,
         {:ok, _from_user} <- User.get(to_user) |> handle_to_user_errors,
         {:ok, from_user_balance} <-
           User.withdraw(from_user, amount, currency) |> handle_from_user_errors,
         {:ok, to_user_balance} <-
           User.deposit(to_user, amount, currency) |> handle_to_user_errors do
      {:ok, from_user_balance, to_user_balance}
    else
      {:error, :too_many_requests_to_receiver} ->
        User.deposit(from_user, amount, currency, :fast)
        {:error, :too_many_requests_to_receiver}

      error ->
        error
    end
  end

  defp handle_from_user_errors({:error, :user_does_not_exist}),
    do: {:error, :sender_does_not_exist}

  defp handle_from_user_errors({:error, :not_enough_money}),
    do: {:error, :not_enough_money}

  defp handle_from_user_errors({:error, :too_many_requests_to_user}),
    do: {:error, :too_many_requests_to_sender}

  defp handle_from_user_errors({:ok, state}),
    do: {:ok, state}

  defp handle_to_user_errors({:error, :user_does_not_exist}),
    do: {:error, :receiver_does_not_exist}

  defp handle_to_user_errors({:error, :not_enough_money}),
    do: {:error, :not_enough_money}

  defp handle_to_user_errors({:error, :too_many_requests_to_user}),
    do: {:error, :too_many_requests_to_receiver}

  defp handle_to_user_errors({:ok, state}),
    do: {:ok, state}
end
