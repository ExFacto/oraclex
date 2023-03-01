defmodule Oraclex.NumericOutcome do
  defstruct base: integer(),
            signed: boolean(),
            unit: String.t(),
            precision: integer(),
            digit_count: integer()
end
