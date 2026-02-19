defmodule JsonParserElixirTest do
  use ExUnit.Case

  # =============================================================================
  # NULL PARSING
  # =============================================================================

  describe "parse/1 with null" do
    test "parses empty string" do
      assert JsonParserElixir.parse("") == {:ok, nil}
    end

    test "parses null" do
      assert JsonParserElixir.parse("null") == {:ok, nil}
    end

    test "parses null with leading whitespace" do
      assert JsonParserElixir.parse("  null") == {:ok, nil}
    end

    test "parses null with trailing whitespace" do
      assert JsonParserElixir.parse("null  ") == {:ok, nil}
    end

    test "parses null with tabs and newlines" do
      assert JsonParserElixir.parse("\t\nnull\r\n") == {:ok, nil}
    end
  end

  # =============================================================================
  # BOOLEAN PARSING
  # =============================================================================

  describe "parse/1 with booleans" do
    test "parses true" do
      assert JsonParserElixir.parse("true") == {:ok, true}
    end

    test "parses false" do
      assert JsonParserElixir.parse("false") == {:ok, false}
    end

    test "parses true with whitespace" do
      assert JsonParserElixir.parse("  true  ") == {:ok, true}
    end

    test "parses false with whitespace" do
      assert JsonParserElixir.parse("  false  ") == {:ok, false}
    end
  end

  # =============================================================================
  # NUMBER PARSING
  # =============================================================================

  describe "parse/1 with integers" do
    test "parses zero" do
      assert JsonParserElixir.parse("0") == {:ok, 0}
    end

    test "parses positive integer" do
      assert JsonParserElixir.parse("42") == {:ok, 42}
    end

    test "parses negative integer" do
      assert JsonParserElixir.parse("-42") == {:ok, -42}
    end

    test "parses large integer" do
      assert JsonParserElixir.parse("1234567890") == {:ok, 1_234_567_890}
    end

    test "parses integer with whitespace" do
      assert JsonParserElixir.parse("  123  ") == {:ok, 123}
    end
  end

  describe "parse/1 with floats" do
    test "parses simple float" do
      assert JsonParserElixir.parse("3.14") == {:ok, 3.14}
    end

    test "parses negative float" do
      assert JsonParserElixir.parse("-3.14") == {:ok, -3.14}
    end

    test "parses float with leading zero" do
      assert JsonParserElixir.parse("0.5") == {:ok, 0.5}
    end

    test "parses float with exponent" do
      assert JsonParserElixir.parse("1.5e10") == {:ok, 1.5e10}
    end

    test "parses float with positive exponent" do
      assert JsonParserElixir.parse("1.5e+10") == {:ok, 1.5e10}
    end

    test "parses float with negative exponent" do
      assert JsonParserElixir.parse("1.5e-10") == {:ok, 1.5e-10}
    end

    test "parses float with uppercase E" do
      assert JsonParserElixir.parse("1.5E10") == {:ok, 1.5e10}
    end

    test "parses integer with exponent" do
      assert JsonParserElixir.parse("5e2") == {:ok, 500.0}
    end
  end

  # # =============================================================================
  # # STRING PARSING
  # # =============================================================================

  describe "parse/1 with strings" do
    test "parses empty string" do
      assert JsonParserElixir.parse(~s("")) == {:ok, ""}
    end

    test "parses simple string" do
      assert JsonParserElixir.parse(~s("hello")) == {:ok, "hello"}
    end

    test "parses string with spaces" do
      assert JsonParserElixir.parse(~s("hello world")) == {:ok, "hello world"}
    end

    test "parses string with whitespace around it" do
      assert JsonParserElixir.parse(~s(  "hello"  )) == {:ok, "hello"}
    end

    test "parses string with escaped quote" do
      assert JsonParserElixir.parse(~s("say \\"hello\\"")) == {:ok, ~s(say "hello")}
    end

    test "parses string with escaped backslash" do
      assert JsonParserElixir.parse(~s("back\\\\slash")) == {:ok, "back\\slash"}
    end

    test "parses string with escaped newline" do
      assert JsonParserElixir.parse(~s("line1\\nline2")) == {:ok, "line1\nline2"}
    end

    test "parses string with escaped tab" do
      assert JsonParserElixir.parse(~s("col1\\tcol2")) == {:ok, "col1\tcol2"}
    end

    test "parses string with escaped carriage return" do
      assert JsonParserElixir.parse(~s("line\\rreturn")) == {:ok, "line\rreturn"}
    end

    test "parses string with unicode escape" do
      assert JsonParserElixir.parse(~s("\\u0041")) == {:ok, "A"}
    end

    test "parses string with multiple unicode escapes" do
      assert JsonParserElixir.parse(~s("\\u0048\\u0065\\u006C\\u006C\\u006F")) == {:ok, "Hello"}
    end

    test "parses string with mixed content" do
      assert JsonParserElixir.parse(~s("Hello, \\u0057orld!")) == {:ok, "Hello, World!"}
    end
  end

  # # =============================================================================
  # # ARRAY PARSING
  # # =============================================================================

  describe "parse/1 with arrays" do
    test "parses empty array" do
      assert JsonParserElixir.parse("[]") == {:ok, []}
    end

    test "parses array with single null" do
      assert JsonParserElixir.parse("[null]") == {:ok, [nil]}
    end

    test "parses array with single integer" do
      assert JsonParserElixir.parse("[1]") == {:ok, [1]}
    end

    test "parses array with single string" do
      assert JsonParserElixir.parse(~s(["hello"])) == {:ok, ["hello"]}
    end

    test "parses array with multiple integers" do
      assert JsonParserElixir.parse("[1, 2, 3]") == {:ok, [1, 2, 3]}
    end

    test "parses array with mixed types" do
      assert JsonParserElixir.parse(~s([1, "two", true, null])) == {:ok, [1, "two", true, nil]}
    end

    test "parses nested arrays" do
      assert JsonParserElixir.parse("[[1, 2], [3, 4]]") == {:ok, [[1, 2], [3, 4]]}
    end

    test "parses deeply nested arrays" do
      assert JsonParserElixir.parse("[[[1]]]") == {:ok, [[[1]]]}
    end

    test "parses array with whitespace" do
      assert JsonParserElixir.parse("[ 1 , 2 , 3 ]") == {:ok, [1, 2, 3]}
    end

    test "parses array with newlines" do
      json = """
      [
        1,
        2,
        3
      ]
      """

      assert JsonParserElixir.parse(json) == {:ok, [1, 2, 3]}
    end

    test "parses empty array with whitespace" do
      assert JsonParserElixir.parse("[   ]") == {:ok, []}
    end
  end

  # # =============================================================================
  # # OBJECT PARSING
  # # =============================================================================

  describe "parse/1 with objects" do
    test "parses empty object" do
      assert JsonParserElixir.parse("{}") == {:ok, %{}}
    end

    # test "parses object with single string value" do
    #   assert JsonParserElixir.parse(~s({"name": "John"})) == {:ok, %{"name" => "John"}}
    # end

    # test "parses object with single integer value" do
    #   assert JsonParserElixir.parse(~s({"age": 30})) == {:ok, %{"age" => 30}}
    # end

    # test "parses object with single boolean value" do
    #   assert JsonParserElixir.parse(~s({"active": true})) == {:ok, %{"active" => true}}
    # end

    # test "parses object with null value" do
    #   assert JsonParserElixir.parse(~s({"data": null})) == {:ok, %{"data" => nil}}
    # end

    # test "parses object with multiple key-value pairs" do
    #   json = ~s({"name": "John", "age": 30, "active": true})
    #   expected = %{"name" => "John", "age" => 30, "active" => true}
    #   assert JsonParserElixir.parse(json) == {:ok, expected}
    # end

    # test "parses nested objects" do
    #   json = ~s({"person": {"name": "John", "age": 30}})
    #   expected = %{"person" => %{"name" => "John", "age" => 30}}
    #   assert JsonParserElixir.parse(json) == {:ok, expected}
    # end

    # test "parses object with array value" do
    #   json = ~s({"numbers": [1, 2, 3]})
    #   expected = %{"numbers" => [1, 2, 3]}
    #   assert JsonParserElixir.parse(json) == {:ok, expected}
    # end

    # test "parses object with whitespace" do
    #   json = ~s({ "name" : "John" })
    #   assert JsonParserElixir.parse(json) == {:ok, %{"name" => "John"}}
    # end

    # test "parses object with newlines" do
    #   json = """
    #   {
    #     "name": "John",
    #     "age": 30
    #   }
    #   """

    #   expected = %{"name" => "John", "age" => 30}
    #   assert JsonParserElixir.parse(json) == {:ok, expected}
    # end

    # test "parses empty object with whitespace" do
    #   assert JsonParserElixir.parse("{   }") == {:ok, %{}}
    # end
  end

  # # =============================================================================
  # # COMPLEX NESTED STRUCTURES
  # # =============================================================================

  # describe "parse/1 with complex structures" do
  #   test "parses array of objects" do
  #     json = ~s([{"id": 1}, {"id": 2}])
  #     expected = [%{"id" => 1}, %{"id" => 2}]
  #     assert JsonParserElixir.parse(json) == {:ok, expected}
  #   end

  #   test "parses complex nested structure" do
  #     json = """
  #     {
  #       "users": [
  #         {"name": "Alice", "roles": ["admin", "user"]},
  #         {"name": "Bob", "roles": ["user"]}
  #       ],
  #       "count": 2,
  #       "active": true
  #     }
  #     """

  #     expected = %{
  #       "users" => [
  #         %{"name" => "Alice", "roles" => ["admin", "user"]},
  #         %{"name" => "Bob", "roles" => ["user"]}
  #       ],
  #       "count" => 2,
  #       "active" => true
  #     }

  #     assert JsonParserElixir.parse(json) == {:ok, expected}
  #   end

  #   test "parses deeply nested mixed structure" do
  #     json = ~s({"a": {"b": {"c": [1, 2, {"d": true}]}}})
  #     expected = %{"a" => %{"b" => %{"c" => [1, 2, %{"d" => true}]}}}
  #     assert JsonParserElixir.parse(json) == {:ok, expected}
  #   end
  # end

  # # =============================================================================
  # # WHITESPACE HANDLING
  # # =============================================================================

  # describe "parse/1 whitespace handling" do
  #   test "handles space character" do
  #     assert JsonParserElixir.parse(" 42 ") == {:ok, 42}
  #   end

  #   test "handles tab character" do
  #     assert JsonParserElixir.parse("\t42\t") == {:ok, 42}
  #   end

  #   test "handles newline character" do
  #     assert JsonParserElixir.parse("\n42\n") == {:ok, 42}
  #   end

  #   test "handles carriage return" do
  #     assert JsonParserElixir.parse("\r42\r") == {:ok, 42}
  #   end

  #   test "handles mixed whitespace" do
  #     assert JsonParserElixir.parse(" \t\n\r42 \t\n\r") == {:ok, 42}
  #   end

  #   test "preserves whitespace inside strings" do
  #     assert JsonParserElixir.parse(~s("  spaces  ")) == {:ok, "  spaces  "}
  #   end

  #   test "preserves tabs inside strings" do
  #     assert JsonParserElixir.parse(~s("\ttabs\t")) == {:ok, "\ttabs\t"}
  #   end
  # end

  # # =============================================================================
  # # ERROR HANDLING
  # # =============================================================================

  # describe "parse/1 error cases" do
  #   test "returns error for empty string" do
  #     assert {:error, _} = JsonParserElixir.parse("")
  #   end

  #   test "returns error for whitespace only" do
  #     assert {:error, _} = JsonParserElixir.parse("   ")
  #   end

  #   test "returns error for invalid keyword" do
  #     assert {:error, _} = JsonParserElixir.parse("nul")
  #   end

  #   test "returns error for invalid true" do
  #     assert {:error, _} = JsonParserElixir.parse("tru")
  #   end

  #   test "returns error for invalid false" do
  #     assert {:error, _} = JsonParserElixir.parse("fals")
  #   end

  #   test "returns error for unclosed string" do
  #     assert {:error, _} = JsonParserElixir.parse(~s("hello))
  #   end

  #   test "returns error for unclosed array" do
  #     assert {:error, _} = JsonParserElixir.parse("[1, 2, 3")
  #   end

  #   test "returns error for unclosed object" do
  #     assert {:error, _} = JsonParserElixir.parse(~s({"key": "value"))
  #   end

  #   test "returns error for trailing comma in array" do
  #     assert {:error, _} = JsonParserElixir.parse("[1, 2, 3,]")
  #   end

  #   test "returns error for trailing comma in object" do
  #     assert {:error, _} = JsonParserElixir.parse(~s({"a": 1,}))
  #   end

  #   test "returns error for missing colon in object" do
  #     assert {:error, _} = JsonParserElixir.parse(~s({"key" "value"}))
  #   end

  #   test "returns error for non-string object key" do
  #     assert {:error, _} = JsonParserElixir.parse("{123: \"value\"}")
  #   end

  #   test "returns error for leading zeros in numbers" do
  #     assert {:error, _} = JsonParserElixir.parse("007")
  #   end

  #   test "returns error for invalid escape sequence" do
  #     assert {:error, _} = JsonParserElixir.parse(~s("invalid \\x escape"))
  #   end

  #   test "returns error for multiple values without structure" do
  #     assert {:error, _} = JsonParserElixir.parse("1 2 3")
  #   end
  # end
end
