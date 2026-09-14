# Sertyp

Type-preserving serialization for Typst values. Converts Typst objects into an
intermediate representation. This can be used for communication with WASM
plugins.

## What is this?

Unlike `repr()` or `cbor.encode()`, which produce ambiguous strings or lose type
information, `sertyp`:

- **Enables roundtrips**: Deserialize back to the original displayable value,
  not just a string representation. This means a content object will again be
  fully displayed as content.
- **Works with WASM plugins**: The intermediate representation can be further
  serialized to cbor and passed over the WASM boundary.

The
[Rust backend](https://github.com/Uhrendoktor/sertyp/blob/main/rust/README.md)
provides deserialization logic and typed data structures so plugins can work
with actual Typst types instead of manual parsing efforts.

## Usage

```typst
#import "@preview/sertyp:0.1.2"
```

## Examples

### Basic serialization

```typst
#import "@preview/sertyp:0.1.2"

// Serialize and deserialize complex content
#let value = [
    Total displaced soil by glacial flow:
    $ 7.32 beta + sum_(i=0)^nabla (Q_i (a_i - epsilon)) / 2 $
    #metadata(title: "Glacial Flow Calculation")
]

#let serialized = sertyp.serialize(value)
#let deserialized = sertyp.deserialize(serialized)
#assert(repr(deserialized) == repr(value))
```

### WASM Plugins using (rust sertyp crate)

```rust
use wasm_minimal_protocol::*;
use sertyp::{typst_func, Integer, String};

#[cfg(target_arch = "wasm32")]
initiate_protocol!();

// Result errors are automatically converted to typst panics.
#[typst_func]
pub fn fibonacci<'a>(n: Integer) -> Result<Integer, String<'a>> {
    let n: i32 = n.try_into().map_err(|_| "Invalid integer range")?;

    let (mut v0, mut v1) = (0, 1);
    for _ in 0..n {
        (v0, v1) = (v1, v0 + v1);
    }

    Ok(v1.into())
}
```

### Type preservation examples

```typst
#import "@preview/sertyp:0.1.2"

#let color = rgb(255, 128, 0)
#let restored = sertyp.deserialize(sertyp.serialize(color))
// restored value is a real color object value, not a string

#let len = 2.5em + 10pt
#let restored = sertyp.deserialize(sertyp.serialize(len))
// Same with lengths and most other types
```

## Overview

### `serialize(value) -> any`

Converts a Typst value into an intermediate representation (nested dicts/arrays
with type tags).

```typst
let serialized = sertyp.serialize(rgb(255, 0, 0))
// Returns: (type: "color", value: (components: ..., space: ...))
```

### `deserialize(serialized) -> any`

Reconstructs a Typst value from its intermediate representation.

```typst
let value = sertyp.deserialize(serialized)
// Returns the original displayable value
```

**Security note**: Deserialization uses `eval()` internally. Deserializing
untrusted values may therefore lead to arbitrary code execution. **Only
deserialize trusted data**.

### `serialize-cbor(value) -> bytes`

Serializes to CBOR binary format. Usefull when passing values to WASM plugins.

```typst
let bytes = sertyp.serialize-cbor(my_value)
// Returns CBOR-encoded bytes
```

### `deserialize-cbor(bytes) -> any`

Deserializes from CBOR bytes back to a Typst value.

```typst
let value = sertyp.deserialize-cbor(plugin_output)
```

**Security note**: Deserialization uses `eval()` internally. Deserializing
untrusted values may therefore lead to arbitrary code execution. **Only
deserialize trusted data**.

### `call(function, arg) -> any`

Shorthand for

```typst
sertyp.deserialize-cbor(function(sertyp.serialize-cbor(arg)))
```

## Supported Types

**Primitives**: `bool`, `int`, `float`, `decimal`, `string`, `bytes`, `none`,
`auto`

**Collections**: `array`, `dictionary`

**Numeric with units**: `length`, `angle`, `ratio`, `fraction`, `duration`,
`relative`

**Text & content**: `content`, `label`, `regex`, `symbol`, `version`, `datetime`

**Visual**: `color`, `stroke`, `gradient`, `alignment`, `direction`, `tiling`

**Advanced**: `function`, `module`, `selector`, `type`, `arguments`, `styles`

## Known Limitations

- **`selector`**: Requires custom parsing for proper serialization (partially
  supported)
- **Dynamic types**: `context` and other runtime-dependent elements cannot be
  fully serialized
- **Closures**: Inline functions `(..) => ..` serialize but lose their captured
  state

## Plugin Development

See the
[Rust README](https://github.com/Uhrendoktor/sertyp/blob/main/rust/README.md)
for details on building WASM plugins that work with sertyp.
