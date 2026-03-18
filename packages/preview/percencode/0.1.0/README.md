# Percent Encoding

![GitHub License](https://img.shields.io/github/license/Servostar/typst-percencode)
![GitHub Release](https://img.shields.io/github/v/release/Servostar/typst-percencode)
[![GitHub](https://img.shields.io/badge/github-%23121011.svg?logo=github&logoColor=white)](https://github.com/Servostar/typst-percencode)

This Typst library offers function for encoding and decoding percent escape sequences.
These are typically used to encode unsafe or non-ASCII characters in URLs.
Supported by this library is only Typst's native character encoding and defacto web standard: UTF-8.

Read the [manual](https://github.com/Servostar/typst-percencode/releases/download/v0.1.0/manual.pdf) for further information.

## Usage

You can directly import the package from Typst universe:

```typst
#import "@preview/percencode:0.1.0": *
```

## Example

### Sanitize URLs

The method `url-encode` can be used to escape unsafe characters (as in RFC 2396) in URL strings.

Example:

```
https://example.com/how much is 23€ wörth?
```

Results in:

```
https://example.com/how%20much%20is%2023%E2%82%AC%20w%C3%B6rth?
```

### Encoding

Encode an entire string:

```typst
#percent-encode("Hello, World!")
``` 

Results in:

```
%48%65%6C%6C%6F%2C%20%57%6F%72%6C%64%21
```

### Decoding

Decode an entire string:

```typst
#percent-decode("%48%65%6C%6C%6F%2C%20%57%6F%72%6C%64%21")
``` 

Results in:

```
Hello, World!
```

---

(c) 2025 Sven Vogel. Some right reserved.