defmodule JsonParserElixir do
  @moduledoc """
  A JSON parser that uses pattern matching effectively without Regex.
  """

  @whitespace [?\s, ?\t, ?\n, ?\r]
  @digit_chars ?0..?9
  @float_chars [?., ?e, ?E, ?+, ?-]

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

  defp parse(<<c::utf8, t::binary>>, [:value | rest], output) when c in @digit_chars or c == ?- do
    parse(<<c::utf8>> <> t, [:number | rest], output)
  end

  defp parse(<<c::utf8, t::binary>>, [:number | rest], output)
       when c in @digit_chars or c == ?- do
    parse(t, [:number | rest], output <> <<c::utf8>>)
  end

  defp parse(<<c::utf8, t::binary>>, [:number | rest], output)
       when c in @digit_chars or c in @float_chars do
    parse(t, [:float | rest], output <> <<c::utf8>>)
  end

  defp parse(<<c::utf8, t::binary>>, [:float | rest], output)
       when c in @digit_chars or c in @float_chars do
    parse(t, [:float | rest], output <> <<c::utf8>>)
  end

  defp parse("", [:number | rest], output) do
    parse("", rest, String.to_integer(output))
  end

  defp parse("", [:float | rest], output) do
    parse("", rest, to_float(output))
  end

  defp to_float(str) do
    if String.contains?(str, ".") do
      String.to_float(str)
    else
      str
      |> String.replace("e", ".0e")
      |> String.replace("E", ".0E")
      |> String.to_float()
    end
  end
end
