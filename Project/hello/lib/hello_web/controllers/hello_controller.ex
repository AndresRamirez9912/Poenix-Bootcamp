defmodule HelloWeb.HelloController do
  use HelloWeb, :controller

  def show(conn, %{"messenger" => messenger}) do
    # text(conn, "This is the input message #{messenger}") #Render just a plane text
    # json(conn, %{id: messenger}) #Response with a json data (must be a map)
    conn
    |> put_root_layout(false) #Desactive the view
    |> Plug.Conn.assign(:messenger, messenger) # Assign the messenger to the conn struct
    |> render("index.html") #render my template
  end

  def index(conn, _params) do
    render(conn,"index.html")
  end
end
