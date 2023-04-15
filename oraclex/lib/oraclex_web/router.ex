defmodule OraclexWeb.Router do
  use OraclexWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {OraclexWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", OraclexWeb do
    pipe_through(:browser)

    # redirec to /events
    get("/", EventController, :list)

    get("/events/new", EventController, :new)
    post("/events/new", EventController, :create)

    get("/events/resolve", ResolutionController, :new)
    post("/events/resolve", ResolutionController, :create)

    get("/settings", SettingsController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", OraclexWeb do
  #   pipe_through :api
  # end

end
