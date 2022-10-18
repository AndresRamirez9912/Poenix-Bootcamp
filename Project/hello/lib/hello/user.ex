defmodule Hello.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :bio, :string
    field :name, :string
    field :number_of_pets, :integer

    timestamps() #This is added to know when any field was modify
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :bio, :number_of_pets])
    |> validate_required([:name, :bio, :number_of_pets])
    |> validate_length(:bio, min: 2) #here I add a min lenght of bio
    |> validate_length(:bio, max: 140) #here I add a max lenght of bio
    |> validate_format(:email, ~r/@/) #Here I use regular expressions to especify the desired format
  end
end
