defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  def index(conn, _params) do
    conn
    |> put_flash(:info, "Welcome to Phoenix example :D") # Add to the conn structure the text
    render(conn, "index.html") # Render the default page

    # conn
    # |> put_root_layout("admin.html") #Select the layout to render
    # |> render("index.html") #Render using my view called index.html
  end

  def redirect_test(conn, _params) do
    redirect(conn,to: "/hello/Andres") #Redirect to the /hello/Andres endpoint
  end
end
