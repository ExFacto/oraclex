defmodule OraclexWeb.EventView do
  use OraclexWeb, :view
  use Phoenix.HTML
  alias OraclexWeb.ComponentsView
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

  def remove_x() do
    svg = """
        <svg width="18" height="18" viewBox="0 0 22 22" xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M18.7071 6.70711C19.0976 6.31658 19.0976 5.68342 18.7071 5.29289C18.3166 4.90237 17.6834 4.90237 17.2929 5.29289L12 10.5858L6.70711 5.29289C6.31658 4.90237 5.68342 4.90237 5.29289 5.29289C4.90237 5.68342 4.90237 6.31658 5.29289 6.70711L10.5858 12L5.29289 17.2929C4.90237 17.6834 4.90237 18.3166 5.29289 18.7071C5.68342 19.0976 6.31658 19.0976 6.70711 18.7071L12 13.4142L17.2929 18.7071C17.6834 19.0976 18.3166 19.0976 18.7071 18.7071C19.0976 18.3166 19.0976 17.6834 18.7071 17.2929L13.4142 12L18.7071 6.70711Z" fill="#cccccc"/>
        </svg>
    """
    Phoenix.HTML.raw(svg)
  end

  def create_li(form, field, input_opts \\ [], data \\ []) do
    type = Phoenix.HTML.Form.input_type(form, field)
    name = Phoenix.HTML.Form.input_name(form, field) <> "[]"
    input_opts = Keyword.put_new(input_opts, :name, name)
    input_opts = Keyword.put_new(input_opts, :class, "mb-2 bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-purple-500 focus:border-purple-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-purple-500 dark:focus:border-purple-500")
    content_tag :li, class: "form-field-input-list" do
      [
        apply(Phoenix.HTML.Form, type, [form, field, input_opts]),
        link(to: "#", data: data, title: "Remove", class: "py-2.5 px-3 ml-2 mb-2 text-sm font-medium text-gray-900 focus:outline-none bg-white rounded-lg border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:z-10 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700") do
          remove_x()
        end
      ]
    end
  end

  @spec count_events_by_state(list()) :: {non_neg_integer(), non_neg_integer()}
  def count_events_by_state(events) do
    Enum.reduce(events, {0, 0}, fn event, {open, settled} ->
      attestation = Map.get(event, :attestation)
      if attestation != nil do
        {open, settled + 1}
      else
        {open + 1, settled}
      end
    end)
  end

end
