defmodule Rocketpay.Accounts.Deposit do
  alias Ecto.Multi
  alias Rocketpay.{Account, Repo}

  def call(%{"id" => id, "value" => value}) do
    Multi.new()
    |> Multi.run(:get_account,
      fn repo, _changes ->
        get_account(repo, id)
      end)
    |> Multi.run(:update_repo,
      fn repo, %{get_account: account} ->
        update_balance(repo, account, value)
    end)
    |> run_transaction()
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation_name, reason, _changes} -> {:error, reason}
      {:ok, %{update_repo: account}} -> {:ok, account}
    end
  end

  defp get_account(repo, id) do
    case repo.get(Account, id) do
      nil -> {:error, "Account not found!"}
      account -> {:ok, account}
    end
  end

  defp sum_values(%Account{balance: balance}, value) do
    value
    |> Decimal.cast()
    |> handle_cast(balance)
  end

  defp update_account({:error, _reason} = error, _repo, _account), do: error
  defp update_account(value, repo, account) do
    account
    |> Account.changeset(%{balance: value})
    |> repo.update()
  end

  defp update_balance(repo, account, value) do
    account
    |> sum_values(value)
    |> update_account(repo, account)
  end

  defp handle_cast({:ok, value}, balance), do: Decimal.add(value, balance)
  defp handle_cast(:error, _balance), do: {:error, "Invalid deposit value!"}
end
