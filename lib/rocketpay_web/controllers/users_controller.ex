defmodule RocketpayWeb.UsersController do
  use RocketpayWeb, :controller
  alias Rocketpay.User

  action_fallback RocketpayWeb.FallbackController

  def create(conn, params) do
    # a struct declarada a baixo (leftHand) indica o resultado a ação subsequente a [<-] (rightHand)
    # ou seja, se o resulta da função (Rocketpay.create_user(params))
    # for [ {:ok, %User{} = user} ], o corpo da função será executado
    # caso contrário, será retornado um erro ao modulo que chamou essa função
    # e neste caso, há uma action de fallback, isto indica que o erro será devolvida com o devido tratamento da action de fallback
    with {:ok, %User{} = user} <- Rocketpay.create_user(params) do
      conn
      |> put_status(:created)
      |> render("create.json", user: user)
    end
  end

  # def create(conn, params) do
  #   params
  #   |> Rocketpay.create_user()
  #   |> handle_response(conn)
  # end

  # defp handle_response({:ok, %User{} = user}, conn) do
  #   conn
  #   |> put_status(:created)
  #   |> render("create.json", user: user)
  # end

  # defp handle_response({:error, reason} = error, _conn), do: error

end
