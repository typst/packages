<!--
Useful QR code scanners, spec-compliant so they don't assume UTF-8:
* https://www.qr-codes.com/decoder
* https://scanqr.ai/
-->

# Zig Port of Nayuki's QR Code Generator

A Zig implementation of [Nayuki's QR Code Generator](https://www.nayuki.io/page/qr-code-generator-library), but which abides by the [Typst plugin protocol](https://typst.app/docs/reference/foundations/plugin/) and is specific to the properties those of [a UPN QR](https://www.zbs-giz.si/wp-content/uploads/2021/10/EN_Tehnicni_standard_UPN_QR.pdf).

Notable changes made in the Zig port:
* Omitted majority of original comments
* Naming conventions:
	* Adapted to Zig
	* Removed long names
	* Removed repetitive prefix inside enums
* Utilised Zig features:
	* Simplified where possible
	* Safe and explicit memory allocations
	* Compile-time values
	* Native UTF-8
	* Error unions
	* Integer types, such as `u8`
	* Integer underflow and overflow prevention
	* Functions inside structs
	* Safe pointers
	* Absence of macros
<!-- * Defer, optionals, tagged unions ... -->

Other principles:
* Single-file
* Single-purpose:
	* As a plugin in the [UPN QR Typst package](https://example.com)
	* See specification

Specification:
* Inherited from the original:
	* QR Code Model 2:
		* Compared to 1, there's an additional alignment pattern visible
	* ISO/IEC 18004 Second Edition 2006-09-01:
		* According to the recommended source Nayuki provides
* Required by UPN QR:
	* Version (size) 15
	* Error correction M
	* Byte mode
	* Encoding ISO/IEC 8859-2

## Source

Tested for [Zig compiler v0.16.0](https://ziglang.org/download/#release-0.16.0), but should support v0.11.0+.

For ease of use, there is neither `build.zig` nor `build.zig.zon`.

<!-- Observed in combination with the `-O ReleaseSmall` flag, the `-fstrip` flag seems to have no effect -->

### Compile

Typst-compliant WASM:
```
zig build-exe main.zig -fno-entry -target wasm32-freestanding -O ReleaseSmall --export=main
```

To contain nearly all files within the same directory, add these flags:
```
--cache-dir . --global-cache-dir .
```

### Test

There are no tests.

### Docs

1. Can be emitted via the `-femit-docs` flag as an HTML file inside `./docs/`
2. Start a web server `python -m http.server -d ./docs/`
3. Visit `localhost:8000` from a web browser

Careful not to dispose of the newline at the end of the Zig files, otherwise [an error might occur](https://ziggit.dev/t/help-msf-error-generate-doc/11373/4) in the opened `index.html`.

The default tab title, the top-left Zig logo, and the orange theme presented in the docs aren't easily customisable.

## Questions and Answers

<details>
<summary>Why is this README not in Slovenian, contrary to the package's?</summary>

This plugin is entirely in English as nothing here is meant to be seen by the (majority Slovenian) user. Errors also are better distinguished this way.
</details>

<details>
<summary>Why are the `0` and `1` reversed?</summary>

Yes, usually dark is `0` and light is `1`, but the emptiness in QR codes on **white** paper would be the **white** space.
</details>

<details>
<summary>Why is this plugin needed for the package?</summary>

There are packages for easily spawning QR codes into Typst, however they:
* Might imply security concerns, especially as this QR code contains banking details
* [`tiaoma`](https://typst.app/universe/package/tiaoma), despite its support for the exact QR:
	* Doesn't allow for colour control because it's SVG
	* Is somewhat of an overkill in terms of package size
* [`zebra`](https://typst.app/universe/package/zebra), despite its abilities to remove the grid lines, visible in PDF viewers, and to have colour control:
	* Doesn't support the exact QR
</details>

<details>
<summary>Why Zig, not Rust?</summary>

It's much simpler for building this plugin yourself. Beside that, I can't grasp Rust :(
</details>

## Attribution

* [Nayuki's QR Code Generator](https://www.nayuki.io/page/qr-code-generator-library)
* [The text _QR Code_ of Denso Wave Incorporated](https://en.wikipedia.org/wiki/QR_code#License)
* [Zig minimal WASM for Typst](https://github.com/typst-community/wasm-minimal-protocol)

* See also:
	* [`typst-community/wasm-zig-typst`](https://github.com/typst-community/wasm-zig-typst)
	* [`peterhellberg/typ`](https://github.com/peterhellberg/typ) and [its blog post](https://c7.se/webassembly-plugins-for-typst-in-zig/)

For more on the official UPN QR standard and its QR code, see the [UPN QR Typst package's README](../../../../README.md).

## AI Disclaimer

The code for the QR code plugin was made entirely by Anthropic's Claude, based on Nayuki's QR code generator, and on-off over the course of several months. Most of the code comments are made by me. This README is entirely made by me.

The rest of the UPN QR package, where this Typst plugin code is used, is entirely made by me.

## Licence

Remains the same as Nayuki's original implementation (MIT).