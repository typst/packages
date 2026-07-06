# typwire

An extended CBOR encoder for the [Typst](https://typst.app/) plugin system.

This library provides a CBOR encoder with extended [support](#supported-types) for Typst types, along with corresponding Rust types and deserialization, enabling seamless data exchange between Typst and Rust WASM plugins.

## Usage

**Note:** The versions used in Typst and Rust **MUST** match exactly.

**Rust:**

Add `typwire` to your Rust project like this:

```sh
cargo add typwire
```

```rs
use serde::Deserialize;
use typwire::{Angle, Color, DateTime, FromBytes as _};
use wasm_minimal_protocol::*;

initiate_protocol!();

#[derive(Deserialize)]
struct Custom {
    angle: Angle,
    color: Color,
    datetime: DateTime,
}

#[wasm_func]
fn custom_fn(arg: &[u8]) -> Result<Vec<u8>, String> {
    let custom = Custom::from_bytes(arg)?;

    // ...

    Ok(vec![])
}
```

**Typst:**

```typ
#import "@preview/typwire:0.1.0"

#let custom-plugin = plugin("custom_plugin.wasm")

#let custom = (
    "angle": 90deg,
    "color": red,
    "datetime": datetime.today(),
)

#let encoded = typwire.cbor.encode(custom)

#custom-plugin.custom_fn(encoded)
```

## Supported types

 - ✅ int
 - ✅ float
 - ✅ bytes
 - ✅ str
 - ✅ bool
 - ✅ content
 - ✅ none
 - ✅ array
 - ✅ dictionary
 - ✅ angle
 - ✅ length
 - ✅ ratio
 - ✅ color
 - ✅ gradient
 - ✅ datetime
 - ✅ duration
 - ✅ version
 - ✅ type
 - ❌ fraction
 - ❌ direction
 - ❌ relative
 - ❌ decimal

## Missing features

- Color conversion in Rust
- Dynamic Value type that includes all Typst types
- Decoding from plugin
- Static Gradient defaults
- Support for all types
