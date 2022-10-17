# Ecto

Ecto is a Phoenix tool to have data validation and persistence using common DBs

## Repo Configuration

This file has three tasks

- Bring all queries
- Set the Otp_app name equal to my app name
- Configure the database adapter (user, password, etc)

## Create Schema

To Create a schema use the following command

```elixir
mix phx.gen.schema Schema_name users field_name:string field_name:string  
```

Where:

- `Schema_name` Means the name of the schema
- `field_name` Means the name of a column or field that I want to create

Here is an example of  schema called User with filed: name, bio and number_of_pets

```elixir
mix phx.gen.schema User users name:string bio:string number_of_pets:integer
```

**Note:** Automatically Ecto add a ID column as a primary key of each table.

```elixir
Table "public.users"
Column         |            Type             | Modifiers
---------------+-----------------------------+----------------------------------------------------
id             | bigint                      | not null default nextval('users_id_seq'::regclass)
name           | character varying(255)      |
email          | character varying(255)      |
bio            | character varying(255)      |
number_of_pets | integer                     |
inserted_at    | timestamp without time zone | not null
updated_at     | timestamp without time zone | not null
Indexes:
"users_pkey" PRIMARY KEY, btree (id)
```

# Changeset

The changeset is a function inside the data base .ex file (in the example, user.ex) Which receive the input data (data to be stored in my database) and make a filter, first select the useful data (the input data is a map structure, so it verify that the key are my column data base) if there is invalid data (invalid keys or another different to my column) the changeset delete it. Then check if any error occur before insert in my DB (error means data type error or something like that). In summary this function has:

- Check the input data if the map key match with my database’s columns (cast function)
- Check if the values can return any error before insert in my table (validate_required function)
- Add any other customizable validation

The changeset code looks like this:

```elixir
def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :bio, :number_of_pets])#Check the keys match with the array
    |> validate_required([:name, :bio, :number_of_pets]) #Check errors 
		# My Own validations 
		|> validate_length(:bio, min: 2) #Check the min lenght of bio column
	  |> validate_length(:bio, max: 140) #check the max lenght of bio column
	  |> validate_format(:email, ~r/@/) #check the format of email column
  end
```