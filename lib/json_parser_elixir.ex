defmodule JsonParserElixir do
  @moduledoc """
  A JSON parser that uses pattern matching effectively without Regex.
  """

  @whitespace [?\s, ?\t, ?\n, ?\r]

  def parse(json_string) do
    debug("String which should have value, to be pushed to stack: #{json_string}")
    parse(json_string, [:value], "")
  end

  def parse("", [:value], "") do
    debug("Parsing null/empty value")
    {:ok, nil}
  end

  def parse("", [], output) do
    debug("Output displayed after JSON parsing: #{output}")
    {:ok, output}
  end

  def parse(<<s::utf8, _t::binary>>, _context = [:string | _], _output) when s in @whitespace do
    debug("Inside a string, passing across empty space.")
    # Blank 4: Parse the string across an empty space
  end

  def parse(<<s::utf8, t::binary>>, context, output) when s in @whitespace do
    debug("Ignore the whitespace outside the string")
    parse(t, context, output)
  end

  def parse("null" <> t, [:value | rest], _output) do
    debug("Parse null value")
    parse(t, rest, nil)
  end

  defp debug(message) do
    IO.puts("[DEBUG] #{message}")
  end
end
