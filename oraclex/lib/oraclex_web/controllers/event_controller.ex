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
    announcement = Oraclex.Announcement.create_announcement(o, announcement)

    conn
    |> put_flash(:info, "Announcement created successfully.")
    |> redirect(to: Routes.event_path(conn, :list))
  end


  def list(conn, _params) do
    announcements = Oraclex.Announcement.get_all_announcements()
    render(conn, "list.html", events: announcements)
  end
end
