# typed

An extended CBOR encoder for the [Typst](https://typst.app/) plugin system.

This library provides a CBOR encoder with extended [support](#supported-types) for Typst types, along with corresponding Rust types and deserialization, enabling seamless data exchange between Typst and Rust WASM plugins.

## Usage

**Note:** The versions used in Typst and Rust **MUST** match exactly.

**Rust:**

Add `typed` to your Rust project like this:

```sh
cargo add typed --git https://github.com/T1mVo/typed.git --tag v0.1.0
```

```rs
use serde::Deserialize;
use typed::{Angle, Color, DateTime, FromBytes as _};
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
#import "@preview/typed:0.1.0"

#let custom-plugin = plugin("custom_plugin.wasm")

#let custom = (
    "angle": 90deg,
    "color": red,
    "datetime": datetime.today(),
)

#let encoded = typed.cbor.encode(custom)

#custom-plugin.custom_fn(encoded)
```

## Supported types

 - [x] int
 - [x] float
 - [x] bytes
 - [x] str
 - [x] bool
 - [x] content
 - [x] none
 - [x] array
 - [x] dictionary
 - [x] angle
 - [x] length
 - [x] ratio
 - [x] color
 - [x] gradient
 - [x] datetime
 - [x] duration
 - [x] version
 - [x] type
 - [ ] fraction
 - [ ] direction
 - [ ] relative
 - [ ] decimal

## Missing features

- Color conversion in Rust
- Dynamic Value type that includes all Typst types
- Decoding from plugin
- Static Gradient defaults
- Support for all types
