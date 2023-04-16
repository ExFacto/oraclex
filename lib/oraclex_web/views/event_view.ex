defmodule OraclexWeb.EventView do
  use OraclexWeb, :view
  use Phoenix.HTML

  alias OraclexWeb.ComponentsView
  # TODO is this bad?
  import Plug.Conn

  def assign_event(conn, event) do
    conn
    |> assign(:event, event)
  end

  def array_add_button(form, field) do
    id = Phoenix.HTML.Form.input_id(form, field) <> "_container"
    data = [
      blueprint: create_li(form, field, [value: ""]) |> safe_to_string(),
      container: id
    ]

    link("Add Outcome", to: "#", data: data, title: "Add", class: "form-list-add-field")
  end

  def array_input(form, field) do
    id = Phoenix.HTML.Form.input_id(form, field) <> "_container"
    values = Phoenix.HTML.Form.input_value(form, field) || [""]
    content_tag :ol, id: id, class: "input_container" do
      for {value, index} <- Enum.with_index(values) do
        input_opts = [
          value: value,
          id: nil,
        ]
        create_li(form, field, input_opts, [index: index, value: value])
      end
    end
  end

  def create_li(form, field, input_opts \\ [], data \\ []) do
    type = Phoenix.HTML.Form.input_type(form, field)
    name = Phoenix.HTML.Form.input_name(form, field) <> "[]"
    input_opts = Keyword.put_new(input_opts, :name, name)
    input_opts = Keyword.put_new(input_opts, :class, "form-field-input form-field-input-list-text")
    content_tag :li, class: "form-field-input-list" do
      [
        apply(Phoenix.HTML.Form, type, [form, field, input_opts]),
        link("X", to: "#", data: data, title: "Remove", class: "form-list-remove-field")
      ]
    end
  end

end
