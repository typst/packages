# Digestify

A blazing fast cryptographic hash package for Typst, powered by WebAssembly.

## Features

- **Comprehensive**: Supports MD4, MD5, SHA-1, SHA-2, and SHA-3 hash families
- **Easy to Use**: Simple and intuitive API, almost a drop-in replacement for [jumble](https://typst.app/universe/package/jumble/)
- **Blazing Fast**: Powered by WebAssembly, way faster than native Typst packages

## Usage

### Basic Example

```typst
#import "@preview/digestify:0.2.0": *

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
#import "@preview/digestify:0.2.0": *

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

// SHA-3 family
#let sha3_224_result = sha3_224(data)
#let sha3_256_result = sha3_256(data)
#let sha3_384_result = sha3_384(data)
#let sha3_512_result = sha3_512(data)
```

## License

MIT.
