defmodule ExBanking.User do
  @moduledoc """
  Module responsible for handling the user
  """

  use GenServer
  @max_user_requests 10
  def create(user) do
    start_link(user)
  end

  def get(user) do
    GenServer.call(server_name(user), {:get_state})
  catch
    :exit, _ ->
      {:error, :user_does_not_exist}
  end

  # Fast type should only be used for returns
  def deposit(user, amount, currency, type \\ :regular) do
    update_balance(user, amount, currency, type)
  end

  def withdraw(user, amount, currency) do
    update_balance(user, -amount, currency, :regular)
  end

  defp update_balance(user, amount, currency, :fast) do
    GenServer.cast(server_name(user), {:update_balance, amount, currency})
  end

  defp update_balance(user, amount, currency, _type) do
    with {:ok, _requests} <- increase_user_requests(user) do
      result = GenServer.call(server_name(user), {:update_balance, amount, currency})

      decrease_user_requests(user)
      result
    end
  end

  defp server_name(user) do
    {:via, Registry, {UserRegistry, user}}
  end

  defp increase_user_requests(user) do
    GenServer.call(server_name(user), {:increase_user_requests})
  end

  defp decrease_user_requests(user) do
    GenServer.cast(server_name(user), {:decrease_user_requests})
  end

  def start_link(user) do
    GenServer.start_link(__MODULE__, nil, name: server_name(user))
  end

  @impl true
  def init(_) do
    {:ok, %{user_requests: 0, currencies: %{}}}
  end

  @impl true
  def handle_call(
        {:increase_user_requests},
        _from,
        %{user_requests: user_requests} = state
      ) do
    if user_requests == @max_user_requests do
      {:reply, {:error, :too_many_requests_to_user}, state}
    else
      new_state = Map.put(state, :user_requests, user_requests + 1)
      {:reply, {:ok, new_state}, new_state}
    end
  end

  @impl true
  def handle_call(
        {:get_state},
        _from,
        state
      ) do
    {:reply, {:ok, state}, state}
  end

  @impl true
  def handle_call(
        {:update_balance, amount, currency},
        _from,
        %{currencies: currencies} = state
      ) do
    new_amount = Map.get(currencies, currency, 0) + amount

    if new_amount < 0 do
      {:reply, {:error, :not_enough_money}, state}
    else
      {:reply, {:ok, new_amount},
       %{state | currencies: Map.put(currencies, currency, new_amount)}}
    end
  end

  @impl true
  def handle_cast(
        {:decrease_user_requests},
        %{user_requests: user_requests} = state
      ) do
    if user_requests < 1 do
      {:noreply, state}
    else
      {:noreply, %{state | user_requests: user_requests - 1}}
    end
  end

  @impl true
  def handle_cast(
        {:update_balance, amount, currency},
        %{currencies: currencies} = state
      ) do
    new_amount = Map.get(currencies, currency, 0) + amount
    {:noreply, %{state | currencies: Map.put(currencies, currency, new_amount)}}
  end
end
