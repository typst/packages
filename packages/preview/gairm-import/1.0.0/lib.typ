// gairm-import: validate and coerce JSON data against a schema you
// bring (a JSON Schema document, or one built in Typst) into typed
// Typst values. This file is the package's only public surface, and
// it only re-exports: every name it imports is public, so
// `#import "@preview/gairm-import:…": *` brings in nothing internal.

#import "internal/run.typ": validate, coerce, parse, format-errors
#import "internal/kinds/leaf.typ": (
  number, integer, markup, boolean, null, unknown, enum-of, const-of,
)
#import "internal/kinds/format.typ": string
#import "internal/kinds/structure.typ": (
  array-of, object, map, any-of, one-of, not-of, if-of, nullable,
)
#import "internal/json-schema/translate.typ": schema-from-json-schema
#import "internal/edit.typ": (
  schema-get, schema-put, schema-update, add-field, remove-field, set-required,
  unset-required,
)
#import "internal/introspect.typ": describe-schema, find-paths
#import "internal/core/pointer.typ": path-to-pointer, pointer-to-path
