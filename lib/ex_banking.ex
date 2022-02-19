defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """
  alias ExBanking.Bank

  @doc """
  Creates user

  """
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    Bank.create_user(user)
  end

  def create_user(_user), do: {:error, :wrong_arguments}

  @doc """
  Deposit money to a user in a currency

  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_binary(currency) and is_binary(user) and is_number(amount) and amount >= 0 do
    Bank.deposit(user, amount, currency) |> format_balance_return()
  end

  def deposit(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @doc """
  Withdraw money from a user in a currency

  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}

  def withdraw(user, amount, currency)
      when is_binary(currency) and is_binary(user) and is_number(amount) and amount >= 0 do
    Bank.withdraw(user, amount, currency) |> format_balance_return()
  end

  def withdraw(_user, _amount, _currency), do: {:error, :wrong_arguments}

  @doc """
  Get user balance in a currency

  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(_user, _currency) do
    {:error, :wrong_arguments}
  end

  @doc """
  Send money from a user to another in a currency

  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(_from_user, _to_user, _amount, _currency) do
    {:error, :wrong_arguments}
  end

  defp format_balance_return({:ok, balance}) do
    {:ok, balance / 100}
  end

  defp format_balance_return(error), do: error
end
