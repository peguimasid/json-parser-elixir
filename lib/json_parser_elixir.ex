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

  # whitespace finalizes numbers
  defp parse(<<s::utf8, _::binary>> = input, [:number | rest], acc) when s in @whitespace do
    parse(input, rest, String.to_integer(acc))
  end

  defp parse(<<s::utf8, _::binary>> = input, [:float | rest], acc) when s in @whitespace do
    parse(input, rest, to_float(acc))
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
  defp parse(value, [:number | rest], acc), do: parse(value, rest, String.to_integer(acc))
  defp parse(value, [:float | rest], acc), do: parse(value, rest, to_float(acc))

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
    case c do
      ?n -> parse(t, ctx, acc <> "\n")
      ?r -> parse(t, ctx, acc <> "\r")
      ?t -> parse(t, ctx, acc <> "\t")
      ?b -> parse(t, ctx, acc <> "\b")
      ?f -> parse(t, ctx, acc <> "\f")
      ?" -> parse(t, ctx, acc <> "\"")
      ?\\ -> parse(t, ctx, acc <> "\\")
      ?/ -> parse(t, ctx, acc <> "/")
      _ -> {:error, {:invalid_escape, <<c::utf8>>}}
    end
  end

  # String: accumulate chars
  defp parse(<<c::utf8, t::binary>>, [:string | _] = ctx, acc) do
    parse(t, ctx, acc <> <<c::utf8>>)
  end

  # Arrays: entry
  defp parse(<<?[, t::binary>>, [:value | rest], _acc), do: parse(t, [:array | rest], [])

  # Arrays: finalize
  defp parse(<<?], t::binary>>, [:array | rest], acc), do: parse(t, rest, Enum.reverse(acc))

  # Arrays: prepare to parse next element
  defp parse(value, [:array | rest], acc) do
    ctx = [:value, {:array, acc}] ++ rest
    parse(value, ctx, acc)
  end

  # Skip commas between elements (arrays and objects)
  defp parse(<<?,, t::binary>>, [:value | _] = ctx, acc), do: parse(t, ctx, acc)

  # Arrays: collect parsed element into array
  defp parse(value, [{:array, elements} | rest], acc) do
    parse(value, [:array | rest], [acc | elements])
  end

  # Object: entry
  defp parse(<<?{, t::binary>>, [:value | rest], _acc), do: parse(t, [:object | rest], %{})

  # Object: finalize
  defp parse(<<?}, t::binary>>, [:object | rest], acc), do: parse(t, rest, acc)

  # Object: prepare to parse next key
  defp parse(value, [:object | rest], acc) do
    ctx = [:value, {:object, acc}] ++ rest
    parse(value, ctx, acc)
  end

  # Object: save key, expect colon before value
  defp parse(value, [{:object, map} | rest], acc) do
    parse(value, [:expect_colon, {:object, acc, map} | rest], acc)
  end

  # Object: consume colon, proceed to parse value
  defp parse(<<?:, t::binary>>, [:expect_colon | rest], acc) do
    parse(t, [:value | rest], acc)
  end

  # Object: collect value into map (key from tuple, value from acc)
  defp parse(value, [{:object, key, map} | rest], acc) when is_binary(key) do
    parse(value, [:object | rest], Map.put(map, key, acc))
  end

  # Error: unexpected character
  defp parse(<<c::utf8, _::binary>>, _ctx, _acc) do
    {:error, {:unexpected_character, <<c::utf8>>}}
  end

  # Error: unexpected end of input
  defp parse("", _ctx, _acc), do: {:error, :unexpected_end_of_input}

  ### UTILS

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
