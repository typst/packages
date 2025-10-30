# jsonschema

A Typst package for validating JSON data against JSON schemas, powered by Rust
and WebAssembly.

## Overview

This package provides JSON Schema validation capabilities in Typst documents. It
uses a WASM-compiled Rust implementation based on the `jsonschema` crate to
validate JSON data against JSON Schema specifications (draft 7 and later).

## Installation

```typst
#import "@preview/jsonschema:0.0.1": validate
```

## Usage

The package exports a single function `validate` that takes a JSON schema and
JSON data as strings:

```typst
#import "@preview/jsonschema:0.0.1": validate

#let schema = "{
  \"type\": \"object\",
  \"properties\": {
    \"name\": { \"type\": \"string\" },
    \"age\": { \"type\": \"number\" }
  },
  \"required\": [\"name\"]
}"

#let data = "{ \"name\": \"Alice\", \"age\": 30 }"

#let result = validate(schema, data)
```

### Function Signature

```typst
validate(schema: str, data: str) -> auto
```

**Parameters:**

- `schema`: A string containing a valid JSON Schema
- `data`: A string containing the JSON data to validate

**Returns:**

- On success: Returns the JSON data as a Typst data structure
- On failure: Panics with validation error details

## Features

- ✅ Full JSON Schema validation support
- ✅ Supports draft-07 and later specifications
- ✅ Type validation (string, number, object, array, boolean, null)
- ✅ Property constraints (required, properties, additionalProperties)
- ✅ Number constraints (minimum, maximum, multipleOf)
- ✅ String constraints (minLength, maxLength, pattern, format)
- ✅ Array constraints (minItems, maxItems, uniqueItems, items)
- ✅ Conditional schemas (if/then/else, anyOf, allOf, oneOf, not)
- ✅ Enum validation
- ✅ Nested object validation

## Examples

See the [examples](https://github.com/raulescobar-g/jsonschema-typst/tree/main/examples) directory for comprehensive usage examples:

- [`basic.typ`](https://github.com/raulescobar-g/jsonschema-typst/blob/main/examples/basic.typ) - Simple type validation
- [`object.typ`](https://github.com/raulescobar-g/jsonschema-typst/blob/main/examples/object.typ) - Object property validation
- [`array.typ`](https://github.com/raulescobar-g/jsonschema-typst/blob/main/examples/array.typ) - Array validation with constraints
- [`enum.typ`](https://github.com/raulescobar-g/jsonschema-typst/blob/main/examples/enum.typ) - Enum value validation
- [`numbers.typ`](https://github.com/raulescobar-g/jsonschema-typst/blob/main/examples/numbers.typ) - Number constraint validation
- [`strings.typ`](https://github.com/raulescobar-g/jsonschema-typst/blob/main/examples/strings.typ) - String format and pattern validation
- [`nested.typ`](https://github.com/raulescobar-g/jsonschema-typst/blob/main/examples/nested.typ) - Nested object structures
- [`conditional.typ`](https://github.com/raulescobar-g/jsonschema-typst/blob/main/examples/conditional.typ) - Conditional schema logic
- [`error-handling.typ`](https://github.com/raulescobar-g/jsonschema-typst/blob/main/examples/error-handling.typ) - Handling validation
  errors

## Error Handling

When validation fails, the function panics with detailed error information:

```
Accepts:   <expected type/constraint>
Got:       <actual value>
Location:  <JSON path to error>
```

## Building from Source

Prerequisites:

- Rust toolchain
- wasm32-unknown-unknown target

```bash
./build.sh
```
