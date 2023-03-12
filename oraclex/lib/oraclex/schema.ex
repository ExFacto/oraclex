defmodule Oraclex.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset

      alias Rigging.Repo

      @timestamps_opts [type: :naive_datetime_usec]
      @type t :: %__MODULE__{}
    end
  end
end
