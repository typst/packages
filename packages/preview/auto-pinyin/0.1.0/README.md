# Auto Pinyin

A Typst wrapper for [rust-pinyin](https://github.com/mozillazg/rust-pinyin), providing automatic Chinese to pinyin conversion with an array-based API.

## Features

- **Array-Based API**: Returns arrays for maximum flexibility
- **Multiple Styles**: Support 5 different pinyin output styles
- **Override Support**: Manual override for polyphonic characters
- **Heteronym Support**: Get all possible readings for polyphonic characters
- **Lightweight**: Focused on conversion only, no visual effects
- **WASM Powered**: Fast conversion using WebAssembly
- **rust-pinyin Wrapper**: Built on the reliable rust-pinyin library

## Installation

Import the package in your Typst document:

```typst
#import "@preview/auto-pinyin:0.1.0": to-pinyin, to-pinyin-multi
```

## Usage

### `to-pinyin(chars, style: "tone-num", override: (:))`

Convert Chinese characters to an array of pinyin strings.

**Parameters:**
- `chars`: string or content - Chinese characters to convert
- `style`: string (default: `"tone-num"`) - pinyin output style
  - `"tone-num"`: tone number after vowel (e.g., "pi1n")
  - `"tone-num-end"`: tone number at end (e.g., "pin1")
  - `"tone"`: with tone marks (e.g., "pīn")
  - `"plain"`: without tone (e.g., "pin")
  - `"first-letter"`: first letter only (e.g., "p")
- `override`: dictionary (default: `(:)`) - character/phrase to pinyin mapping

**Returns:** array of strings - one pinyin string per character

**Examples:**
```typst
#import "@preview/auto-pinyin:0.1.0": to-pinyin

// Basic conversion returns an array
#to-pinyin("汉语")                    // → ("ha4n", "yu3")
#to-pinyin("中国")                    // → ("zho1ng", "guo2")
#to-pinyin("Hello世界")               // → ("H", "e", "l", "l", "o", "shi4", "jie4")

// Different styles
#to-pinyin("汉语", style: "plain")    // → ("han", "yu")
#to-pinyin("汉语", style: "tone")     // → ("hàn", "yǔ")
#to-pinyin("汉语", style: "tone-num-end")  // → ("han4", "yu3")
#to-pinyin("汉语", style: "first-letter")  // → ("h", "y")

// Join the array as needed
#to-pinyin("汉语").join("")           // → "ha4nyu3"
#to-pinyin("汉语").join("|")          // → "ha4n|yu3"
#to-pinyin("汉语").join(" ")          // → "ha4n yu3"

// Override polyphonic characters (多音字)
#to-pinyin("重庆", override: (重: "cho2ng"))  // → ("cho2ng", "qi4ng")
#to-pinyin("重庆大学", override: (重庆: ("cho2ng", "qi4ng")))  // → ("cho2ng", "qi4ng", "da4", "xue2")

// Process individual elements
#let pinyin-array = to-pinyin("汉语")
#pinyin-array.first()                 // → "ha4n"
#pinyin-array.last()                  // → "yu3"
#pinyin-array.len()                   // → 2

// Map over pinyin array
#for pinyin in to-pinyin("汉语") {
  [#pinyin\ ]
}
```

### `to-pinyin-multi(char, style: "tone-num")`

Get all possible pinyin readings for a character (heteronym/polyphonic character).

**Parameters:**
- `char`: string or content - Single Chinese character (or string for multi-char)
- `style`: string (default: `"tone-num"`) - pinyin output style (same as `to-pinyin`)

**Returns:** 
- Single character: array of strings - all possible readings
- Multiple characters: array of arrays - readings per character

**Examples:**
```typst
#import "@preview/auto-pinyin:0.1.0": to-pinyin-multi

// Single character: returns all readings as array
#to-pinyin-multi("还")                // → ("ha2i", "hua2n", "fu2")
#to-pinyin-multi("还", style: "plain")  // → ("hai", "huan", "fu")
#to-pinyin-multi("还", style: "tone")   // → ("hái", "huán", "fú")

// Join readings as needed
#to-pinyin-multi("还").join("|")      // → "ha2i|hua2n|fu2"
#to-pinyin-multi("还").join(", ")     // → "ha2i, hua2n, fu2"

// Get the most common reading (first one)
#to-pinyin-multi("还").first()        // → "ha2i"

// Multiple characters: returns array of arrays
#to-pinyin-multi("还没")              // → (("ha2i", "hua2n", "fu2"), ("me2i", "mo4", "me"))

// Process multi-character result
#let readings = to-pinyin-multi("还没")
#readings.at(0)                       // → ("ha2i", "hua2n", "fu2")
#readings.at(1).first()               // → "me2i"
```

## Use Cases

This package is designed for:
- **Text processing**: Extract and manipulate pinyin data
- **Custom formatting**: Build your own pinyin formatting logic
- **Polyphonic characters**: Handle 多音字 with override and multi functions
- **Linguistic analysis**: Explore all possible readings of heteronyms
- **Integration**: Use as base for higher-level packages

### Example: Custom Pinyin Formatter

```typst
#import "@preview/auto-pinyin:0.1.0": to-pinyin

// Build a custom formatter
#let format-pinyin(text, style: "tone", separator: " ") = {
  to-pinyin(text, style: style).join(separator)
}

#format-pinyin("汉语拼音")             // → "hàn yǔ pīn yīn"
#format-pinyin("汉语拼音", separator: "-")  // → "hàn-yǔ-pīn-yīn"
```

### Example: Annotated Text

```typst
#import "@preview/auto-pinyin:0.1.0": to-pinyin

// Create ruby annotations (simplified example)
#let pinyin-ruby(text) = {
  let chars = text.clusters()
  let pinyins = to-pinyin(text, style: "tone")
  
  stack(dir: ttb, spacing: 0.3em,
    text(size: 0.7em, pinyins.join(" ")),
    text,
  )
}

#pinyin-ruby("汉语")
```

### Example: Polyphonic Character Analysis

```typst
#import "@preview/auto-pinyin:0.1.0": to-pinyin-multi

#let all-readings = to-pinyin-multi("还")
#let count = all-readings.len()

"The character '还' has " + str(count) + " possible readings:\n" + \
all-readings.join(", ")
// Output: The character '还' has 3 possible readings: ha2i, huan2, fu2
```

## Comparison with String-Based API

**Before (less flexible):**
```typst
#to-pinyin("汉语", delimiter: "|")    // → "ha4n|yu3" (fixed format)
```

**After (more flexible):**
```typst
#to-pinyin("汉语")                     // → ("ha4n", "yu3")
#to-pinyin("汉语").join("|")           // → "ha4n|yu3"
#to-pinyin("汉语").join("-")           // → "ha4n-yu3"
#to-pinyin("汉语").map(p => p.upper()) // → ("HA4N", "YU3")
```

## API Design Philosophy

This package follows the principle of **returning raw data** and letting users decide how to format it:

1. **Arrays over strings**: Return structured data, not pre-formatted strings
2. **No built-in formatting**: Users control how to join, map, or process results
3. **Composable**: Easy to integrate with other Typst functions and packages
4. **Explicit**: Clear return types that are easy to understand and work with

## Technical Details

This package is a **Typst wrapper** for the [rust-pinyin](https://github.com/mozillazg/rust-pinyin) library. It includes a WASM plugin built with Rust that converts Chinese characters to pinyin. Non-Chinese characters are passed through unchanged.

**Architecture:**
```
Typst Document
     ↓
auto-pinyin (lib.typ)
     ↓
WASM Plugin
     ↓
rust-pinyin (Rust library)
     ↓
pinyin-data
```

The core pinyin conversion logic is provided by rust-pinyin, which uses comprehensive pinyin data from [pinyin-data](https://github.com/mozillazg/pinyin-data). This wrapper adds:
- Typst-friendly array-based API
- Override support for polyphonic characters
- Multi-reading (heteronym) support
- Version tracking of underlying dependencies

## Acknowledgments

This project is a Typst wrapper for [rust-pinyin](https://github.com/mozillazg/rust-pinyin) by @mozillazg. Many thanks to the rust-pinyin project for providing the core pinyin conversion functionality.

The pinyin data comes from [pinyin-data](https://github.com/mozillazg/pinyin-data).

## License

MIT
