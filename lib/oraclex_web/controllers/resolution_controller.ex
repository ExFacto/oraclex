defmodule OraclexWeb.ResolutionController do
  use OraclexWeb, :controller

  def new(conn, params = %{"event_id" => event_id, "outcome" => outcome}) do
    # TODO this is redundant. find out how to pull it from conn.assigns
    event = Oraclex.Announcement.get_announcement(event_id)
    render(conn, "new.html", event: event, outcome: outcome, resolution: Oraclex.Attestation.empty_changeset())
  end

  def create(conn, params = %{"attestation" => attestation = %{
    "event_id" => _event_id,
    "outcome" => _outcome,
  }}) do
    o = Oraclex.Oracle.load_oracle()
    resolution = Oraclex.Attestation.create_attestation(o, attestation)

    conn
    |> put_flash(:info, "Resolution created successfully.")
    |> redirect(to: Routes.event_path(conn, :list))
  end
end
