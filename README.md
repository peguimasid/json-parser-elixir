## ⚗️ JSON Parser Elixir

A from-scratch JSON parser in Elixir leveraging pattern matching to parse data structures.

This project is a solution to a coding challenge that requires implementing a JSON parser in Elixir **without using Regex**. The parser relies purely on pattern matching to process JSON strings character by character.

### The Challenge

<img width="1920" height="785" alt="Screenshot 2026-02-02 at 7 24 15 PM" src="https://github.com/user-attachments/assets/2fdcbd7a-c3b9-45b3-9a18-8a6eaa5b2971" />

### Key Concepts

1. **Pattern Matching**: Each function clause matches a specific parsing state
2. **Recursive Descent**: The parser consumes one character at a time, recursively
3. **Whitespace Handling**: Spaces are preserved inside strings but ignored outside

## Installation

```bash
git clone https://github.com/peguimasid/json-parser-elixir.git
cd json-parser-elixir
mix deps.get
```

### Usage

```elixir
# Parse a simple string
JsonParserElixir.parse("\"hello\"")
# => {:ok, "hello"}

# Parse with whitespace (ignored outside strings)
JsonParserElixir.parse("  \"hello world\"  ")
# => {:ok, "hello world"}

# Parse empty/null
JsonParserElixir.parse("")
# => {:ok, nil}
```

### Running Tests

```bash
mix test
```

### Project Structure

```
json_parser_elixir/
├── lib/
│   └── json_parser_elixir.ex    # Main parser implementation
├── test/
│   └── json_parser_elixir_test.exs
├── mix.exs
└── README.md
```

Made with 💜 and Elixir
