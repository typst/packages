# packrat

Decoding and extraction functions for [Typst](https://typst.app/).

Supports `bzip2`, `gzip`, `xz`, `zstd`, `tar`, and `zip`.

## Installation

Add the package to your Typst document:

```typ
#import "@preview/packrat:0.1.0": *
```

## Quick Start

```typ
#import "@preview/packrat:0.1.0": gzip, tar

#let decoded = gzip(path("file.tar.gz"))
#let archive = tar(decoded)

#for entry in archive [
    #entry.path
]
```

## API Reference

### `bzip2`

```typ
/// Decodes data using bzip2 compression.
/// -> bytes
#let bzip2(
  /// The source to decode.
  /// -> bytes | path
  source,
) = { /* ... */ }
```

Example:

```typ
#let data = bzip2(path("file.bz2"))
```

### `gzip`

```typ
/// Decodes data using gzip compression.
/// -> bytes
#let gzip(
  /// The source to decode.
  /// -> bytes | path
  source,
) = { /* ... */ }
```

Example:

```typ
#let data = gzip(path("file.gz"))
```

### `tar`

```typ
/// Extracts entries from a tar archive.
/// -> array
#let tar(
  /// The source to extract from.
  /// -> bytes | path
  source,
  /// Whether to filter out resource forks.
  /// -> bool
  filter-resource-forks: true,
) = { /* ... */ }
```

Returned entries have the following shape:

```typ
(
  "type": "file" | "directory" | "link",
  "path": string,
  "data": bytes | none, // Only for type "file".
  "target": string | none, // Only for type "link".
)
```

Example:

```typ
#let entries = tar(path("archive.tar"))
#for entry in entries [
  #entry.path
]
```

### `xz`

```typ
/// Decodes data using xz compression.
/// -> bytes
#let xz(
  /// The source to decode.
  /// -> bytes | path
  source,
) = { /* ... */ }
```

Example:

```typ
#let data = xz(path("file.xz"))
```

### `zip`

```typ
/// Extracts entries from a zip archive.
/// -> array
#let zip(
  /// The source to extract from.
  /// -> bytes | path
  source,
  /// Whether to filter out resource forks.
  /// -> bool
  filter-resource-forks: true,
) = { /* ... */ }
```

Returned entries have the following shape:

```typ
(
  "type": "file" | "directory" | "link",
  "path": string,
  "data": bytes | none, // Only for type "file".
  "target": string | none, // Only for type "link".
)
```

Example:

```typ
#let entries = zip(path("archive.zip"))
#for entry in entries [
  #entry.path
]
```

### `zstd`

```typ
/// Decodes data using zstd compression.
/// -> bytes
#let zstd(
  /// The source to decode.
  /// -> bytes | path
  source,
) = { /* ... */ }
```

Example:

```typ
#let data = zstd(path("file.zst"))
```

## License

`packrat` is available under the MIT OR Apache-2.0 license. See `LICENSE-MIT` and `LICENSE-APACHE` for details.
