# Backtrack Documentation

This document specifies and explains the Backtrack API in detail. See the
[README file](README.md) for installation instructions and a basic description
and example.

## Top-Level Items

There are only two top-level items in the library: `current-version` and
`versions`.

### Current Version

`current-version` is a [version object](#version-objects) constant for the
current compiler version.

### Versions

`versions` is a module containing version object constants for each compiler
version up until 0.9.0, plus functions for creating version objects for newer
compiler versions.

The `versions` module contains the following items:
- Version object constants for Typst 0.1.0–0.8.0, named
  `v[major]-[minor]-[patch]`
- Version object constants for Typst 2023-01-30–2023-03-28, named
  `v[YYYY]-[MM]-[DD]`
- A `post-v0-8-0(..components)` function that takes in the `int` components for
  a compiler version above 0.8.0 and returns a corresponding version object;
  `array` arguments are flattened
- A `from-v0-9-0-version(v0-9-0-version)` function that takes in a `version`
  value and returns a corresponding version object

## Version Objects

The API is centered around _version objects_, which are dictionaries that have
exactly these keys:
- `cmpable` is used for comparing version objects.
- `displayable` is used for displaying version objects.
- `observable` is used for observing version objects.

> [!NOTE]
> In this document, "version object" refers to this type of Backtrack version
> object, while `version` (mind the inline code block) refers to the built-in
> `version` type added in Typst 0.9.0.

### Comparable

`cmpable` is a value that supports `<`, `<=`, `==`, `!=`, `>`, and `>=`
operations. Identical compiler versions have equal `cmpable` values, a compiler
version released before another should have a lesser `cmpable` value, etc. Its
specific value is unstable and shouldn't be relied on.

On compiler versions prior to 0.9.0, this is an `int` in all version objects;
otherwise, this is a `version` in all version objects.

> [!WARNING]
> Comparison operations are only valid when at least one of their operands is
> the current version. For instance, comparing `current-version` and a version
> object for 0.9.0 is valid, while comparing a version object for 0.9.0 and
> another for 1.0.0 is undefined and **will** produce counterintuitive results
> when compiled on specific Typst versions.
>
> This is a case of prioritizing simplicity over versatility.

### Displayable

`displayable` is a `str` with a human-friendly name for the version. It should
look natural in phrases like "Typst [displayable]" and "Typst v[displayable]".
Its specific value is unstable and shouldn't be relied on.

### Observable

`observable` is a collection containing the `int` components of the version.
For example:
- `v0-2-0.observable` = `(0, 2, 0)`
- `v2023-03-21.observable` = `(0, 0, 0, 2023, 3, 21)`

This value is guaranteed to be iterable and to have an `at` method that gets the
component at the given index. While its specific value is unstable and shouldn't
be relied on, the values produced by iterating over it or by its `at` method
_are_ stable. No other guarantees are made—do not assume other methods work
reliably even if they appear to.

On compiler versions prior to 0.9.0, this is an `array` in all version objects;
otherwise, this is a `version` in all version objects.
