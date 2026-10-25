// Copyright 2026 Nikolai Neff-Sarnow

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


/// Get the range of lines of a C function definition incuding any comments attached
/// immediately above it from the given sourve code by it's name (identifier)
/// If the function is defined multiple times, only the last entry is returned.
/// Lines are counted starting at one.
/// Panics if the code or identifier are not valid and if the identifier is not found in the code
/// -> dictionary
#let function-linerange(
  /// The source code to search in.
  /// If a path is given, the file at the given path is read as the source code.
  /// -> path | str | bytes
  code,
  /// The function "name" to search for
  /// -> str | bytes
  identifier,
) = {
  if type(code) == path { code = read(code) }
  cbor(plugin("specsnip.wasm").get_function_definition_line_range(bytes(code), bytes(identifier)))
}

/// Get the range of lines of a C type definition incuding any comments attached
/// immediately above it from the given sourve code by it's name (identifier)
/// If the type is defined multiple times, only the last entry is returned.
/// Lines are counted starting at one.
/// Panics if the code or identifier are not valid and if the identifier is not found in the code
/// -> dictionary
#let typedef-linerange(
  /// The source code to search in.
  /// If a path is given, the file at the given path is read as the source code.
  /// -> path | str | bytes
  code,
  /// The type "name" to search for
  /// -> str | bytes
  identifier,
) = {
  if type(code) == path { code = read(code) }
  cbor(plugin("specsnip.wasm").get_type_definition_line_range(bytes(code), bytes(identifier)))
}

/// Runs an arbitrary Tree-Sitter-Query on the given source code
/// Panics if the query or sourcecode are invalid
/// -> array | dictionary
#let query-code(
  /// The source code to be queried.
  /// If a path is given, the file at the given path is read as the source code.
  /// -> path | str | bytes
  code,
  /// The Query to be run against the source code. Must be a valid Tree-Sitter Query according to:
  /// https://tree-sitter.github.io/tree-sitter/using-parsers/queries/index.html
  /// -> str | bytes
  query,
) = {
  if type(code) == path { code = read(code) }
  cbor(plugin("specsnip.wasm").query_tree(bytes(code), bytes(query)))
}
/// Returns the complete syntax tree of the provided code.
/// Panics if the code is invalid.
/// -> array | dictionary
#let get-tree(
  /// The source code.
  /// If a path is given, the file at the given path is read as the source code.
  /// -> path | str | bytes
  code,
) = {
  if type(code) == path { code = read(code) }
  cbor(plugin("specsnip.wasm").get_tree(bytes(code)))
}
/// Checks if the given identifier is contained in the source code (either as function or type definition)
/// Panics if the code or identifier are invalid.
/// -> bool
#let contains-identifier(
  /// The source code to search in.
  /// If a path is given, the file at the given path is read as the source code.
  /// -> path | str | bytes
  code,
  /// The identifier to serach for
  /// -> str | bytes
  identifier,
) = {
  if type(code) == path { code = read(code) }
  cbor(plugin("specsnip.wasm").check_identifier_existance(bytes(code), bytes(identifier)))
}
