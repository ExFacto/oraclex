defmodule OraclexWeb.EventController do
  use OraclexWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def list(conn, _params) do
    announcements = Oraclex.Announcement.get_all_announcements()
    render(conn, "list.html", events: announcements)
  end
end
