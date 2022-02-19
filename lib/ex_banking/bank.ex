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
    else
      error -> error
    end
  end

  def withdraw(user, amount, currency) do
    with {:ok, _user} <- User.get(user) do
      User.withdraw(user, amount, currency)
    else
      error -> error
    end
  end
end
