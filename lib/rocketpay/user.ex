defmodule Rocketpay.User do
	use Ecto.Schema
	import Ecto.Changeset

	alias Ecto.Changeset

	@primary_key {:id, :binary_id, autogenerate: true}	#BINARY ID indica que o id vai ser do tipo UUID, autogenerate indica que o Ecto vai ser encarregar de gerar
	@required_params [:name, :age, :email, :password, :nickname]

	schema "users" do
		field :name, :string
		field :age, :integer
		field :email, :string
		field :password, :string, virtual: true
		field :password_hash, :string
		field :nickname, :string

		timestamps()
	end

	#a função changeset é responsável por receber os dados do usuario que serão persistidos no banco,
	# mapea todos os attrs para o attrs do schema
	# e valida os dados recebidos
	def changeset(params) do
		%__MODULE__{}
		|> cast(params, @required_params) # -> Mapea fazendo cast dos attrs
		|> validate_required(@required_params) # -> Valida todos os dados recebidos com os modelos do schema
		|> validate_length(:password, min: 6)
		|> validate_number(:age, greater_than_or_equal_to: 18)	# -> Valida se a idade recebida é >= 18
		|> validate_format(:email, ~r/@/) # -> Valida se o email recebido contem @ na string, através de Regex
		|> unique_constraint([:email])
		|> unique_constraint([:nickname])
		|> put_password_hash()
	end

	defp put_password_hash(%Changeset{valid?: true, changes: %{password: password}} = changeset) do
		password
		|> String.split("", trim: true)
		|> Stream.map(fn item -> String.to_integer(item) end)
		|> Stream.map(fn item -> item * 2 end)
		|> Stream.map(fn item -> Integer.to_string(item) end)
		|> Enum.join("")
		|> insert_passwordhash_into_changeset(changeset)
	end

	defp insert_passwordhash_into_changeset(password, changeset) do
		change(changeset, %{:password_hash => password})
	end

	defp put_password_hash(changeset), do: changeset


	# #Via patter match, se o Changeset recebido for valido [valid?: true], de [changes] a função tera acesso ao [password]
	# defp put_password_hash(%Changeset{valid?: true, changes: %{password: password}} = changeset) do	
	# 	# change(changeset, Bcrypt.add_hash(password))
		
	# end

	# #Em outro caso onde não houver match na função a cima, simplesmente sera retornado o mesmo changeset
	# defp put_password_hash(changeset), do: changeset
end
