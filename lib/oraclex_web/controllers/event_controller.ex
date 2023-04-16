defmodule OraclexWeb.EventController do
  use OraclexWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html", event: Oraclex.Announcement.empty_changeset())
  end

  def create(conn, params = %{"announcement" => announcement = %{
    "name" => _name,
    "description" => _description,
    "outcomes" => _outcomes,
    "maturity" => maturity
  }}) do
    o = Oraclex.Oracle.load_oracle()
    # validate maturity here??
    {:ok, maturity, _} = DateTime.from_iso8601(maturity <> ":00Z")
    announcement = Map.put(announcement, "maturity", maturity)
    case Oraclex.Announcement.create_announcement(o, announcement) do
      {:ok, announcement} ->
        conn
        |> assign_event(announcement)
        # |> put_flash(:info, "Announcement created successfully.")
        |> redirect(to: Routes.event_path(conn, :list))
      {:error, changeset} ->
        conn
        |> assign_event(changeset)
        |> put_flash(:error, "Failed to create announcement.")
        |> render("new.html")
    end
  end


  def list(conn, _params) do
    announcements = Oraclex.Announcement.get_all_announcements()
    render(conn, "list.html", events: announcements)
  end

  def assign_event(conn, event) do
    conn
    |> assign(:event, event)
  end
end
