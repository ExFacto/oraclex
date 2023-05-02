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

    link("Add outcome", to: "#", data: data, title: "Add", class: "form-list-add-field -mt-4 text-white bg-gradient-to-r from-purple-500 via-purple-600 to-purple-700 hover:bg-gradient-to-br focus:ring-4 focus:outline-none focus:ring-purple-300 dark:focus:ring-purple-800 font-medium rounded-lg text-sm px-5 py-2.5 text-center")
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
    input_opts = Keyword.put_new(input_opts, :class, "mb-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500")
    content_tag :li, class: "form-field-input-list" do
      [
        apply(Phoenix.HTML.Form, type, [form, field, input_opts]),
        link("X", to: "#", data: data, title: "Remove", class: "text-white bg-gradient-to-r from-purple-500 via-purple-600 to-purple-700 hover:bg-gradient-to-br focus:ring-4 focus:outline-none focus:ring-purple-300 dark:focus:ring-purple-800 font-medium rounded-lg text-sm px-5 py-2.5 text-center ml-2 mb-2")
      ]
    end
  end

end
