defmodule JsonParserElixir do
  @moduledoc """
  A JSON parser that uses pattern matching effectively without Regex.
  """

  @whitespace [?\s, ?\t, ?\n, ?\r]

  def parse(json_string) do
    parse(json_string, [:value], "")
  end

  defp parse("", [:value], "") do
    {:ok, nil}
  end

  defp parse("", [], output) do
    {:ok, output}
  end

  defp parse(<<s::utf8, _t::binary>>, _context = [:string | _], _output) when s in @whitespace do
    # Inside a string, passing across empty spaces
    # Blank 4: Parse the string across an empty space
  end

  defp parse(<<s::utf8, t::binary>>, context, output) when s in @whitespace do
    parse(t, context, output)
  end

  defp parse("null" <> t, [:value | rest], _output) do
    parse(t, rest, nil)
  end

  defp parse("true" <> t, [:value | rest], _output) do
    parse(t, rest, true)
  end

  defp parse("false" <> t, [:value | rest], _output) do
    parse(t, rest, false)
  end
end
