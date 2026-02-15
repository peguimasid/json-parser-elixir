defmodule JsonParserElixir do
  @moduledoc """
  A JSON parser that uses pattern matching effectively without Regex.
  """

  @whitespace [?\s, ?\t, ?\n, ?\r]
  @float_chars [?., ?e, ?E, ?+, ?-]

  def parse(json_string) do
    parse(json_string, [:value], "")
  end

  # Base cases
  defp parse("", [:value], ""), do: {:ok, nil}
  defp parse("", [], output), do: {:ok, output}

  # preserve whitespace inside strings
  defp parse(<<s::utf8, _t::binary>>, [:string | _], _output) when s in @whitespace do
    # TODO: accumulate whitespace inside strings
  end

  # skip whitespaces outside strings
  defp parse(<<s::utf8, t::binary>>, context, output) when s in @whitespace do
    parse(t, context, output)
  end

  # Keywords
  defp parse("null" <> t, [:value | rest], _output), do: parse(t, rest, nil)
  defp parse("true" <> t, [:value | rest], _output), do: parse(t, rest, true)
  defp parse("false" <> t, [:value | rest], _output), do: parse(t, rest, false)

  # Numbers: entry
  defp parse(<<c::utf8, _::binary>> = input, [:value | rest], _output)
       when c in ?0..?9 or c == ?- do
    parse(input, [:number | rest], "")
  end

  # Numbers: accumulate digits
  defp parse(<<c::utf8, t::binary>>, [:number | _] = ctx, acc)
       when c in ?0..?9 or c == ?- do
    parse(t, ctx, acc <> <<c::utf8>>)
  end

  # Numbers: digit transitions to float
  defp parse(<<c::utf8, t::binary>>, [:number | rest], acc)
       when c in @float_chars do
    parse(t, [:float | rest], acc <> <<c::utf8>>)
  end

  # Numbers: accumulate float characters
  defp parse(<<c::utf8, t::binary>>, [:float | _] = ctx, acc)
       when c in ?0..?9 or c in @float_chars do
    parse(t, ctx, acc <> <<c::utf8>>)
  end

  # Numbers: finalize
  defp parse("", [:number | rest], acc), do: parse("", rest, String.to_integer(acc))
  defp parse("", [:float | rest], acc), do: parse("", rest, to_float(acc))

  defp to_float(str) do
    if String.contains?(str, ".") do
      String.to_float(str)
    else
      str |> String.replace(~r/[eE]/, ".0\\0") |> String.to_float()
    end
  end
end
