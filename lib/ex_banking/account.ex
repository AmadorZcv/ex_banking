defmodule ExBanking.Account do
  @moduledoc """
  Module responsible for handling the user account
  """

  use Agent

  def open(user) do
    Agent.start_link(fn -> %{} end, name: agent_name(user))
  end

  defp agent_name(user) do
    {:via, Registry, {UserRegistry, user}}
  end
end
