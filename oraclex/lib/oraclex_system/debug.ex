defmodule Debug do
  @moduledoc """
  Debugging functions for making life easier.
  """

  @width 80
  @color 255
  @line_color 238
  @time_color 247
  @syntax_colors [
    atom: :cyan,
    binary: :white,
    boolean: :magenta,
    list: :white,
    map: :white,
    nil: :magenta,
    number: :yellow,
    regex: :light_red,
    reset: :yellow,
    string: :green,
    tuple: :white
  ]

  @doc """
  Prints `input` in console within a formatted frame.

  Returs `input`.

  It can recieve a keyword list as options.

  ## Options
    * `label`: A string to print on the header for identification purposes.
    * `color`: Color of the label if its given. Values between 0-255.
    * `width`: Number of char width of the output.
    * `line_color`: Color of the header and footer lines. Values between 0-255.
    * `time_color`: Color of the execution time. Values between 0-255.
    * `syntax_colors`: Keyword list for term syntax color.
      
      Keys: `:atom`, `:binary`, `:boolean`, `:list`, `:map`, `:nil`, `:number`, `:regex`, `:reset`, `:string`, `:tuple`.
      
      Values: `:black`, `:red`, `:yellow`, `:green`, `:cyan`, `:blue`, `:magenta`, `:white`, `:light_black`, `:light_red`, `:light_yellow`, `:light_green`, `:light_cyan`, `:light_blue`, `:light_magenta`, `:light_white`.

  ### 256 color palette

  <img title="256 color palette" alt="palette image" src="assets/256_colors.png">

  ##  Example
      iex> "Lorem-Ipsum"
      ...> |> String.split("-")
      ...> |> RiggingSystem.Debug.log(label: "Split return")
      ...> |> Enum.join()
      ...> |> String.downcase()
      Split return -------------------------------------- 2022-03-10 - 00:47:07.523741
      ["Lorem", "Ipsum"]
      ------------------------------------------------------------------ Rigging v0.0.0
      "loremipsum" # This is the actual pipeline return, besides de console print.
  """
  @spec log(input :: any, opt :: keyword) :: any
  def log(input, opt \\ []) do
    if Mix.env() in [:dev, :test] do
      [
        header(opt),
        line(),
        inspect(
          input,
          syntax_colors: Keyword.get(opt, :syntax_colors, @syntax_colors),
          pretty: true,
          width: Keyword.get(opt, :width, @width)
        ),
        line(),
        footer(opt),
        line()
      ]
      |> Enum.join()
      |> IO.write()
    end

    input
  end

  # === Private ================================================================

  defp line(), do: "\n"

  defp header(opt) when is_list(opt) do
    %{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      microsecond: {microsecond, 6}
    } = NaiveDateTime.utc_now()

    label = Keyword.get(opt, :label)
    width = Keyword.get(opt, :width, @width)
    c0 = Keyword.get(opt, :color, "#{@color}")
    c1 = Keyword.get(opt, :line_color, "#{@line_color}")
    c2 = Keyword.get(opt, :time_color, "#{@time_color}")

    date =
      "#{year}"
      |> Kernel.<>("-")
      |> Kernel.<>(String.pad_leading("#{month}", 2, "0"))
      |> Kernel.<>("-")
      |> Kernel.<>(String.pad_leading("#{day}", 2, "0"))

    time =
      "#{hour}"
      |> String.pad_leading(2, "0")
      |> Kernel.<>(":")
      |> Kernel.<>(String.pad_leading("#{minute}", 2, "0"))
      |> Kernel.<>(":")
      |> Kernel.<>(String.pad_leading("#{second}", 2, "0"))
      |> Kernel.<>(".")
      |> Kernel.<>(String.pad_leading("#{microsecond}", 6, "0"))

    label = if !label, do: "", else: "#{label} "

    separation =
      width
      |> Kernel.-(String.length(label))
      |> Kernel.-(String.length(date))
      |> Kernel.-(String.length(time))
      |> Kernel.-(4)

    reset = "\e[0m"
    label = "#{reset}\e[1m\e[38;5;#{c0}m#{label}#{reset}\e[38;5;#{c1}m"
    date = "#{reset}\e[38;5;#{c2}m#{date}#{reset}\e[38;5;#{c1}m"
    time = "#{reset}\e[38;5;#{c2}m#{time}#{reset}\e[38;5;#{c1}m"

    "\e[38;5;#{c1}m"
    |> Kernel.<>("#{label}")
    |> Kernel.<>(String.duplicate("─", separation))
    |> Kernel.<>(" #{date} - #{time}")
    |> Kernel.<>(reset)
  end

  defp footer(opt) when is_list(opt) do
    width = Keyword.get(opt, :width, @width)
    c1 = Keyword.get(opt, :line_color, "#{@line_color}")
    service = Mix.Project.config()[:app]
    version = Mix.Project.config()[:version]

    product =
      service
      |> Atom.to_string()
      |> String.split("_")
      |> Enum.map(fn e -> String.capitalize(e) end)
      |> Enum.join()

    sufix = " #{product} v#{version}"
    separation = width - String.length(sufix)

    "\e[38;5;#{c1}m"
    |> Kernel.<>(String.duplicate("─", separation))
    |> Kernel.<>(sufix)
    |> Kernel.<>("\e[0m")
  end
end
