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
  defp parse("", [], acc), do: {:ok, acc}

  # preserve whitespace inside strings
  defp parse(<<c::utf8, t::binary>>, [:string | _] = ctx, acc) when c in @whitespace do
    parse(t, ctx, acc <> <<c::utf8>>)
  end

  # skip whitespaces outside strings
  defp parse(<<s::utf8, t::binary>>, context, acc) when s in @whitespace do
    parse(t, context, acc)
  end

  # Keywords
  defp parse("null" <> t, [:value | rest], _acc), do: parse(t, rest, nil)
  defp parse("true" <> t, [:value | rest], _acc), do: parse(t, rest, true)
  defp parse("false" <> t, [:value | rest], _acc), do: parse(t, rest, false)

  # Numbers: entry
  defp parse(<<c::utf8, _::binary>> = input, [:value | rest], _acc)
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

  # Strings: entry
  defp parse(<<?", t::binary>>, [:value | rest], _acc), do: parse(t, [:string | rest], "")

  # String: finalize
  defp parse(<<?", t::binary>>, [:string | rest], acc), do: parse(t, rest, acc)

  # String: handle unicode escape chars
  defp parse(<<?\\, ?u, a, b, c, d, t::binary>>, [:string | _] = ctx, acc) do
    codepoint = String.to_integer(<<a, b, c, d>>, 16)
    parse(t, ctx, acc <> <<codepoint::utf8>>)
  end

  # String: handle escape chars
  defp parse(<<?\\, c::utf8, t::binary>>, [:string | _] = ctx, acc) do
    escaped_char =
      case c do
        ?n -> "\n"
        ?r -> "\r"
        ?t -> "\t"
        ?b -> "\b"
        ?f -> "\f"
        ?" -> "\""
        ?\\ -> "\\"
        ?/ -> "/"
        _ -> <<c::utf8>>
      end

    parse(t, ctx, acc <> escaped_char)
  end

  # String: accumulate chars
  defp parse(<<c::utf8, t::binary>>, [:string | _] = ctx, acc) do
    parse(t, ctx, acc <> <<c::utf8>>)
  end

  ### UTILS

  defp to_float(str) do
    if String.contains?(str, ".") do
      String.to_float(str)
    else
      str |> String.replace(~r/[eE]/, ".0\\0") |> String.to_float()
    end
  end
end
