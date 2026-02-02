defmodule JsonParserElixir do
  @moduledoc """
  A JSON parser that uses pattern matching effectively without Regex.
  """

  @whitespace [?\s, ?\t, ?\n, ?\r]

  def parse(json_string) do
    debug("String which should have value, to be pushed to stack: " <> json_string)
    # Blank 1: Parse the JSON string with its value
  end

  def parse("", [:value], "") do
    # Blank 2: Debug the null string
    {:ok, nil}
  end

  def parse("", [], output) when is_binary(output) do
    debug("Output displayed after JSON parsing: #{output}")
    # Blank 3: Evaluate the code string against the output
    val = output
    {:ok, val}
  end

  def parse(<<s::utf8, _t::binary>>, _context = [:string | _], _output) when s in @whitespace do
    debug("Inside a string, passing across empty space.")
    # Blank 4: Parse the string across an empty space
  end

  # Blank 5: Define the components required to ignore the whitespace outside the string
  #   debug("Ignore the whitespace outside the string")
  #   parse(t, context, output)
  # end

  defp debug(message) do
    IO.puts("[DEBUG] #{message}")
  end
end
