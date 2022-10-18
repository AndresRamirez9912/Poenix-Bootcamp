# Testing Files

To run test files run the following command:

```elixir
mix test
```

# Test modules

A test module has a structure similar to this

```elixir
defmodule HelloWeb.PageControllerTest do
  use HelloWeb.ConnCase #Use the conn structure to test the request 

  test "GET /", %{conn: conn} do 
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
```

the test function receives 3 input parameters

1. The test name
2. The desired result used to make pattern matching at the end of the test
3. the test operations

Also, I can add tags to each module test, this is useful when I want to run tests individually because I can do it by the tag

```elixir
defmodule HelloWeb.ErrorViewTest do
  use HelloWeb.ConnCase

  @moduletag :error_view_case #Add the tag to this test
  ...
end
```

If I want to run the module test, use the command:

```elixir
mix test --only error_view_case
```

Also, I can name a specific test inside a module, here is how to make it

```elixir
defmodule HelloWeb.ErrorViewTest do
  use HelloWeb.ConnCase, async: true

  @moduletag :error_view_case #Name of the module 

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  @tag individual_test: "yup" #name the specific test 
  test "renders 404.html" do
    assert render_to_string(HelloWeb.ErrorView, "404.html", []) ==
           "Not Found"
  end

  @tag individual_test: "nope" #name the specific test
  test "renders 500.html" do
    assert render_to_string(HelloWeb.ErrorView, "500.html", []) ==
           "Internal Server Error"
  end
end
```

If I wan to run a specific test I can use the command

```elixir
mix test --only individual_test:yup #notice that specify the test 
```

Finally I can run test in a random order using the seed and the following command:

```elixir
mix test --seed 401472
```