# Directory Structure

The common structure is:

```elixir
├── _build
├── assets
├── config
├── deps
├── lib
│   ├── hello
│   ├── hello.ex
│   ├── hello_web
│   └── hello_web.ex
├── priv
└── test
```

- Build: Elixir codes that helps to compile code, create DBs, run server, etc. (must not be checked in git)
- Assets: Folder to storage everything about frontend code (JS,CSS)
- Config: Store config scripts
- deps: Storage the elixir dependencies (must not be checked in git)
- Lib:  Holds the app source code
  - lib/project_web: Expose the domain to internet (In MVC is the view and controller)
  - lib/project: Host the business logic (In MVC is the Model)
- Priv: Keeps the production resources (database scripts, translation files)
- test: Hold the app test files

### Lib/Project_web directory

Inside the lib folder I have a project_web folder which has this directory

```elixir
lib/hello_web
├── controllers
│   └── page_controller.ex
├── templates
│   ├── layout
│   │   ├── app.html.heex
│   │   ├── live.html.heex
│   │   └── root.html.heex
│   └── page
│       └── index.html.heex
├── views
│   ├── error_helpers.ex
│   ├── error_view.ex
│   ├── layout_view.ex
│   └── page_view.ex
├── endpoint.ex
├── gettext.ex
├── router.ex
└── telemetry.ex
```

# Phoenix Life -Cycling

1. Go to the router to know if the endpoint exist and what function handle it
2. Go to the controller called equal to the endpoint file and search the handle module and function
   1. Inside the handle function, render the response
3. Go to the view called equal to the endpoint file
4. Go to the template folder called equal to the endpoint and then the html file named in the render function (inside the controller)

# Add New Pages

When I want to add a new page I need to modify the router file adding a new endpoint  with verb associated and a function to handle it. Here is the default example:

```elixir
get "/hello", HelloController, :index
```

After create the endpooint I need to create the handle function in this case is the index function

Note: If I want to receive some data by the URL I can add : before the variable name, here is an example:

```elixir
get "/hello/:messenger", HelloController, :show
```

In the previous example when I receive a URL like a [localhost:4000/hello/Andres](http://localhost:4000/hello/Andres) the variable messenger stores the value “Andres”.

Now inside the HelloCotroller module . I need to create it in the controller file

```elixir
defmodule HelloWeb.HelloController do
  use HelloWeb, :controller

  def index(conn, _params) do
    render(conn,"index.html")
  end

end
```

- conn:
- params:

Then I need to create a view file with the name of the endpoint as the following example:

```elixir
defmodule HelloWeb.HelloView do
  use HelloWeb, :view
end
```

Finally the view use a HTML template that I need to create with the endpoint name.

# Plugs

## Function Plugs (in my opinion it’s like a pipe)

Plugs are function between web applications that make something. They have to satisfy that **receive a input struct and must return a struct.** To create a plug I need to write this inside my desired module.

```elixir
def introspect(conn, _opts) do #I create my plug as a function and receive a input struct
    # make something 
		IO.puts """
    Verb: #{inspect(conn.method)}
    Host: #{inspect(conn.host)}
    Headers: #{inspect(conn.req_headers)}
    """

    conn #return a struct 
  end
```

After create my plug I need to use it, to do it just to write this inside the desired module

```elixir
plug :introspect #write the plug function as a atom after the input struct  
```

## Module Plugs

I can create module plugs with different functions and according to the input return a structure or another one.  To create it just create a normal function that receive a conn and return a conn. Here is an example:

```elixir
defmodule MyModule.Plugs.MyPlug do
  import Plug.Conn #Function to create a conn 

  def init(default), do: default

  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    assign(conn, :locale, loc) #create a struct nd return it 
  end

  def call(conn, default) do
    assign(conn, :locale, default) #create a struct nd return it 
  end
end
```

After create my plug module I need to  use it, in this case I can do it in the endpoint, router and controller files. As a normal plug. Here is an example using it

```elixir
plug MyModule.Plugs.MyPlug, "en" # Notice the comma and the other value as a plug input
```

# Routing

A typical router.ex file looks like this

```elixir
defmodule HelloWeb.Router do
  use HelloWeb, :router # import the router module functions into my own module

  pipeline :browser do # Create a list of plugs associateed to my pipeline called browser
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HelloWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"] # Here I create the header accept
  end

  scope "/", HelloWeb do 
    pipe_through :browser #Assign the pipeline broser to my "/" endpoint

    get "/", PageController, :index #Here I assign a controller to this path 
  end
end
```

## Resources

When I’m creating my routes and controllers I can use the common RESTful routes and verbs to make commons actions. Here is the example that I should write in the path section

```elixir
get "/", PageController, :index #Here I assign a controller to my main path 
resources "/users", UserController #Use the resources for the user paths 
																	 #the module to handle it is the UserController 
```

If I list all the registered path with the command `[mix phx.routes](<https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Routes.html>)` I will se the following

```elixir
user_path  GET     /                HelloWeb.PageController :index
user_path  GET     /users           HelloWeb.UserController :index
user_path  GET     /users/:id/edit  HelloWeb.UserController :edit
user_path  GET     /users/new       HelloWeb.UserController :new
user_path  GET     /users/:id       HelloWeb.UserController :show
user_path  POST    /users           HelloWeb.UserController :create
user_path  PATCH   /users/:id       HelloWeb.UserController :update
           PUT     /users/:id       HelloWeb.UserController :update
user_path  DELETE  /users/:id       HelloWeb.UserController :delete
```

notice that It assign me automatically the handle functions associated to my module and a verb to an endpoint.

## Path Helper

Is a helper function that return the address of a endpoint or function

```elixir
HelloWeb.Router.Helpers.page_path(HelloWeb.Endpoint, :index) 
#Get index path of the page_path HelloWeb.Endpoint
```

Here is another way to use it because in phoenix `HelloWeb.Router.Helpers` is `Routes` . Notice that Hello is the  project name, it changes when I create the project with another name

```elixir
Routes.user_path(Endpoint, :index) #Know the index path of the user_path controller
```

## Nested Resources

To create nested resources type a code similar to this

```elixir
resources "/users", UserController do
  resources "/posts", PostController
end
```

This allow have the post resources with the user resources, each user resources have a post resource.

## PipeLines

The pipelines is a group of plugs that can be attach it to specific scopes, this means that I can associated a pipeline with a route that will be executed when the router matches

### :Browser plug

- `plug :accepts, ["html"]` : Define the accepted request format
- `:fetch_session` : This fetch the session data of the request
- `:fetch_live_flash` : This fetch the flash data of the request
- `:put_root_layout` : Store the root layout for rendering

I can create my own pipeline and use it in specifics scopes. Here is an example of the router file

```elixir
defmodule HelloWeb.Router do
  use HelloWeb, :router

# Here I created my pipeline :browser 
  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HelloWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

# Here I created my own pipeline called review_checks 
	pipeline :review_checks do
    plug :ensure_authenticated_user
    plug :ensure_user_owns_review
  end

# Here I define my scope called /
  scope "/", HelloWeb do
    pipe_through :browser

    resources "/posts", PostController
  end

# Here I defined my scope called /reviews
  scope "/reviews", HelloWeb do
    pipe_through [:browser, :review_checks] #This scope execute the :broser 
																						#and :review_checks pipeline
    resources "/", ReviewController
  end
end
```

## Forward

This is a function that send particular request (start with a specific word) to a specific module or plug. Here is an example:

```elixir
defmodule HelloWeb.Router do
  use HelloWeb, :router

  ...

  scope "/", HelloWeb do
    ...
  end

  forward "/jobs", BackgroundJob.Plug #Here I typd that request started with 
																			#/job will be send to BackgroundJob.Plug module
end
```

# Controllers

Controllers are modules that has functions which will be execute when its specific endpoint matches with the request endpoint. Here is the default controller and function inside it:

```elixir
defmodule HelloWeb.PageController do #This is the controller 
  use HelloWeb, :controller

  def index(conn, _params) do #this is the action
    render(conn, "index.html")
  end
end
```

(Notice that the functions inside a controller are called actions and must be called equal as the desired endpoint to execute this function)

It’s recommended to use the classic names of actions, like this:

- index: renders a list of all items of the given resource type
- show:  renders an individual item by ID
- new:  renders a form for creating a new item
- create:  receives parameters for one new item and saves it in a data store
- edit:  retrieves an individual item by ID and displays it in a form for editing
- update:  receives parameters for one edited item and saves the item to a data store
- delete:  receives an ID for an item to be deleted and deletes it from a data store

## Actions (Controller Functions)

In phoenix the actions receive two arguments `conn` and `params` , now I going to see what does each ones:

### conn

I a struct that contains request information such as the host name, the path elements, the port, , string query and more information received by the middleware Phoenix plug.

### params

This is a map that contains the http request parameters (I bet it could be headers). It’s recommended do use pattern matching to get the data and store in a simple package or structure for easy handler.

## Renderization

### Render HTML Response

```elixir
defmodule HelloWeb.HelloController do
  ...

  def show(conn, %{"messenger" => messenger}) do
    render(conn, "show.html", messenger: messenger)
  end
end
```

If I need to pass information to the template using the render function I can do it thought the third argument, a keyword list with the data (as the previous example)

Another option is use the Plug.Conn.assign function that receive the conn argument and return another conn with the information. Here is an example:

```elixir
def show(conn, %{"messenger" => messenger}) do
    conn
    |> Plug.Conn.assign(:messenger, messenger)
    |> render("show.html")
  end
```

### Plane Text Response

```elixir
def show(conn, %{"messenger" => messenger}) do
    text(conn, "This is the input message #{messenger}") #Render just a plane text
  end
```

### JSON Response

```elixir
def show(conn, %{"messenger" => messenger}) do
    json(conn, %{id: messenger}) #Response with a json data (must be a map)
  end
```

## Send Response

If I don’t want to send a rendering option or anything of the previous response I can send a specific code using the `send_resp` function as the following example:

```elixir
def index(conn, _params) do
  send_resp(conn, 201, "")
end
```

### Set the http status response

```elixir
def index(conn, _params) do
  conn
  |> put_status(202) #set status 202
  |> render("index.html")
end
```

### Set the content type

```elixir
def index(conn, _params) do
  conn
  |> put_resp_content_type("text/xml") #set the content type
  |> render("index.xml", content: some_xml_content)
end
```

## Redirect

If I want to redirect to another URL I can use the function `redirect` here is an example:

```elixir
def redirect_test(conn, _params) do
    redirect(conn,to: "/hello/Andres") #Redirect to the /hello/Andres endpoint
  end
```

Notice the `to:` this means that I going to redirect to an internal URL. If I want to redirect to an external URL I should use `external:` instead of to

# Views and templates

The views allow render the request response (a API response or a visual response)

## Rendering templates

Each `controller` requires a `pageView` to render the template inside the `lib/hello_web/templates/page/` folder. And the name need to be the same endpoint, also there are three types of pageview

### 1. LayoutView

this type has the following structure

```elixir
defmodule HelloWeb.LayoutView do
  use HelloWeb, :view
end
```

Addtionally, I can create functions in my View and execute it (or call them) inside my template. Here is an example:

(Vire code)

```elixir
defmodule HelloWeb.LayoutView do
  use HelloWeb, :view

  def title() do
    "Awesome New Title!"
  end
end
```

(Layout code)

```elixir
<title><%= title() %></title>
```

Notice the <%= %> expression, this is the heex syntax which means that inside I going to call elixir functions or input parameters. Here is how I should do it:

- `<title><%= title() %></title>`: Call the function title
- `<title><%= @my_tittle %></title>` Call an input parameter called my_tittle

## Sharing views and templates

I can render another template / layout inside my pages. This is something like a Angular module inside another Angular module, I can render HTML code inside another HTML code. Here is how can a I do that

```elixir
<%= Phoenix.View.render(HelloWeb.PageView, "test.html", message: "Hello from the other layout!") %>
```

Here is how I made that. I need to call the render/3 which receives

- View that render it (optional If the father render view will render the son layout)
- File name
- Input data (optional)

### Rendering JSON

I can use the render function to render json responses, here is an example of this:

```elixir
defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  def show(conn, _params) do
    page = %{title: "foo"} #This is tehdata to send to the layout 

    render(conn, "show.json", page: page) #render my sho.json file 
  end

  def index(conn, _params) do
    pages = [%{title: "foo"}, %{title: "bar"}] %this json will be  send to my page 

    render(conn, "index.json", pages: pages) #render the json and send the page map
  end
end
```

Remember that I can send data to the layout using the render/3 function and in Elixir json data could be handler by maps.