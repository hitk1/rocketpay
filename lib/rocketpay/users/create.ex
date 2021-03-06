defmodule Rocketpay.Users.Create do
    alias Ecto.Multi
    alias Rocketpay.{Repo, User, Account}

    def call(params) do
        Multi.new()
        |> Multi.insert(:create_user, User.changeset(params))
        |> Multi.run(:create_account,
            fn repo, %{create_user: user} ->
                insert_account(repo, user.id)
            end)
        |> Multi.run(:preload_data,
            fn repo, %{create_user: user} ->
                {:ok, repo.preload(user, :account)}
            end)
        |> run_transaction()
        # params
        # |> User.changeset()
        # |> Repo.insert()
    end

    defp insert_account(repo, user_id) do
        %{user_id: user_id, balance: 0.0}
        |> Account.changeset()
        |> repo.insert()
    end

    defp run_transaction(multi) do
        case Repo.transaction(multi) do
            {:ok, %{preload_data: user}} -> {:ok, user}
            {:error, _operation_name, reason, _changes} -> {:error, reason}
        end
    end
end
