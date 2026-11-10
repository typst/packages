# uuidkit

`uuidkit` is a Typst package backed by a WebAssembly plugin for UUID validation,
normalization, inspection, and deterministic namespace-based UUID generation.

## Import

```typst
#import "@preview/uuidkit:0.1.0": describe, canonical, is-uuid, v3, v5, named, namespaces
```

## API

- `describe(text)`: Parses a UUID string and returns a dictionary with
  `hyphenated`, `simple`, `urn`, `version`, `variant`, and `bytes`.
- `canonical(text)`: Returns the canonical hyphenated UUID string.
- `is-uuid(text)`: Returns `true` when the input can be parsed as a UUID.
- `v3(namespace, name)`: Generates a deterministic version 3 UUID from a
  namespace and name.
- `v5(namespace, name)`: Generates a deterministic version 5 UUID from a
  namespace and name.
- `named(name, namespace: namespaces.dns, version: 5)`: Convenience wrapper for
  `v3` and `v5`. Only versions `3` and `5` are supported.
- `namespaces`: A dictionary of built-in namespace aliases: `dns`, `url`, `oid`,
  and `x500`.

Namespace arguments may be one of `"dns"`, `"url"`, `"oid"`, `"x500"`, or a UUID
string.

## Example

```typst
#import "@preview/uuidkit:0.1.0": describe, canonical, is-uuid, v3, named, namespaces

#let raw = "cfbff0d1-9375-5685-968c-48ce8b15ae17"
#let parsed = describe(raw)

Valid: #is-uuid(raw)                                                       \
Canonical: #canonical(raw)                                                 \
Simple: #parsed.simple                                                     \
URN: #parsed.urn                                                           \
Version: #parsed.version                                                   \
Variant: #parsed.variant                                                   \
DNS v3: #v3(namespaces.dns, "example.com")                                 \
URL v5: #named("https://typst.app", namespace: namespaces.url, version: 5)
```
