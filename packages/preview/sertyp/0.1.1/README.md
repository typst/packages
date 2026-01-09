# Sertyp

Type-preserving serialization for Typst values. Converts Typst objects into an intermediate representation. This can be used for communication with WASM plugins.

## What is this?

Unlike `repr()` or `cbor.encode()`, which produce ambiguous strings or lose type information, `sertyp`:

- **Enables roundtrips**: Deserialize back to the original displayable value, not just a string representation. This means a content object will again be fully displayed as content.
- **Works with WASM plugins**: The intermediate representation can be further serialized to cbor and passed over the WASM boundary.

The [Rust backend](https://github.com/Uhrendoktor/sertyp/blob/main/rust/README.md) provides deserialization logic and typed data structures so plugins can work with actual Typst types instead of manual parsing efforts.

## Installation

```typst
#import "@preview/sertyp:0.1.1"
``` 

## Examples

### Basic serialization

```typst
#import "@preview/sertyp:0.1.1"

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

### WASM plugin communication

Pass typed data to Rust plugins and get typed results back:

```typst
#import "@preview/sertyp:0.1.1"
#let math_plugin = plugin("<...>/matrix_ops.wasm")

// Send a matrix to the plugin
#let I = $mat(1,2;-2,1)$
#let transposed = sertyp.deserialize_cbor(
    math_plugin.transpose(sertyp.serialize_cbor(I))
)
#assert(repr(transposed) == repr($mat(1,-2;2,1)$))
```

### Type preservation examples

```typst
#import "@preview/sertyp:0.1.1"

// Colors preserve their color space
#let color = rgb(255, 128, 0)
#let restored = sertyp.deserialize(sertyp.serialize(color))
// restored is still rgb(255, 128, 0), not a string

// Lengths keep their units
#let len = 2.5em + 10pt
#let restored = sertyp.deserialize(sertyp.serialize(len))
// restored is still a length with both em and pt components

// Functions preserve their names
#let fn = math.floor
#let restored = sertyp.deserialize(sertyp.serialize(fn))
// Plugin can extract "math.floor" as a string
```

## API

### `serialize(value) -> any`

Converts a Typst value into an intermediate representation (nested dicts/arrays with type tags).

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

### `serialize_cbor(value) -> bytes`

Serializes to CBOR binary format for WASM plugins.

```typst
let bytes = sertyp.serialize_cbor(my_value)
// Returns CBOR-encoded bytes
```

### `deserialize_cbor(bytes) -> any`

Deserializes from CBOR bytes back to a Typst value.

```typst
let value = sertyp.deserialize_cbor(plugin_output)
```

**Security note**: Deserialization uses `eval()` internally. Only deserialize trusted data.

## Supported Types

**Primitives**: `bool`, `int`, `float`, `decimal`, `string`, `bytes`, `none`, `auto`

**Collections**: `array`, `dictionary`

**Numeric with units**: `length`, `angle`, `ratio`, `fraction`, `duration`, `relative`

**Text & content**: `content`, `label`, `regex`, `symbol`, `version`, `datetime`

**Visual**: `color`, `stroke`, `gradient`, `alignment`, `direction`, `tiling`

**Advanced**: `function`, `module`, `selector`, `type`, `arguments`, `styles`

## Known Limitations

- **`selector`**: Requires custom parsing for proper serialization (partially supported)
- **Dynamic types**: `context` and other runtime-dependent elements cannot be fully serialized
- **Closures**: Inline functions `(..) => ..` serialize but lose their captured state

## Plugin Development

See the [Rust README](https://github.com/Uhrendoktor/sertyp/blob/main/rust/README.md) for details on building WASM plugins that work with sertyp.
