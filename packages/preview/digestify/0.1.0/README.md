# Digestify

A blazing fast cryptographic hash package for Typst, powered by WebAssembly.

## Features

- **Comprehensive**: Supports MD4, MD5, SHA-1, SHA-224, SHA-256, SHA-384, and SHA-512
- **Easy to Use**: Simple and intuitive API, almost a drop-in replacement for [jumble](https://typst.app/universe/package/jumble/)
- **Blazing Fast**: Powered by WebAssembly, way faster than native Typst packages

## Usage

### Basic Example

```typst
#import "@preview/digestify:0.1.0": *

// Hash a string
#let text = "Hello, World!"
#let data = bytes(text)

// Compute different hashes
#let md5_hash = md5(data)
#let sha256_hash = sha256(data)

// Convert to hex string for display
#bytes-to-hex(md5_hash)
#bytes-to-hex(sha256_hash)
```

### All Supported Hash Functions

```typst
#import "@preview/digestify:0.1.0": *

#let data = bytes("Your input text here")

// MD family
#let md4_result = md4(data)
#let md5_result = md5(data)

// SHA-1
#let sha1_result = sha1(data)

// SHA-2 family
#let sha224_result = sha224(data)
#let sha256_result = sha256(data)
#let sha384_result = sha384(data)
#let sha512_result = sha512(data)
```

## License

MIT.
