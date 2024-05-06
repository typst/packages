# typst-oxifmt (v0.2.1)

A Typst library that brings convenient string formatting and interpolation through the `strfmt` function. Its syntax is taken directly from Rust's `format!` syntax, so feel free to read its page for more information (https://doc.rust-lang.org/std/fmt/); however, this README should have enough information and examples for all expected uses of the library. Only a few things aren't supported from the Rust syntax, such as the `p` (pointer) format type, or the `.*` precision specifier.

A few extras (beyond the Rust-like syntax) will be added over time, though (feel free to drop suggestions at the repository: https://github.com/PgBiel/typst-oxifmt). The first "extra" so far is the `fmt-decimal-separator: "string"` parameter, which lets you customize the decimal separator for decimal numbers (floats) inserted into strings. E.g. `strfmt("Result: {}", 5.8, fmt-decimal-separator: ",")` will return the string `"Result: 5,8"` (comma instead of dot). See more below.

**Compatible with:** [Typst](https://github.com/typst/typst) v0.4.0+

## Table of Contents

- [Usage](#usage)
    - [Formatting options](#formatting-options)
    - [Examples](#examples)
    - [Grammar](#grammar)
- [Issues and Contributing](#issues-and-contributing)
- [Testing](#testing)
- [Changelog](#changelog)
- [License](#license)

## Usage

You can use this library through Typst's package manager (for Typst v0.6.0+):

```typ
#import "@preview/oxifmt:0.2.1": strfmt
```

For older Typst versions, download the `oxifmt.typ` file either from Releases or directly from the repository. Then, move it to your project's folder, and write at the top of your Typst file(s):

```typ
#import "oxifmt.typ": strfmt
```

Doing the above will give you access to the main function provided by this library (`strfmt`), which accepts a format string, followed by zero or more replacements to insert in that string (according to `{...}` formats inserted in that string), an optional `fmt-decimal-separator` parameter, and returns the formatted string, as described below.

Its syntax is almost identical to Rust's `format!` (as specified here: https://doc.rust-lang.org/std/fmt/). You can escape formats by duplicating braces (`{{` and `}}` become `{` and `}`). Here's an example (see more examples in the file `tests/strfmt-tests.typ`):

```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("I'm {}. I have {num} cars. I'm {0}. {} is {{cool}}.", "John", "Carl", num: 10)
#assert.eq(s, "I'm John. I have 10 cars. I'm John. Carl is {cool}.")
```

Note that `{}` extracts positional arguments after the string sequentially (the first `{}` extracts the first one, the second `{}` extracts the second one, and so on), while `{0}`, `{1}`, etc. will always extract the first, the second etc. positional arguments after the string. Additionally, `{bananas}` will extract the named argument "bananas".

### Formatting options

You can use `{:spec}` to customize your output. See the Rust docs linked above for more info, but a summary is below.

(You may also want to check out the examples at [Examples](#examples).)

- Adding a `?` at the end of `spec` (that is, writing e.g. `{0:?}`) will call `repr()` to stringify your argument, instead of `str()`. Note that this only has an effect if your argument is a string, an integer, a float or a `label()` / `<label>` - for all other types (such as booleans or elements), `repr()` is always called (as `str()` is unsupported for those).
    - For strings, `?` (and thus `repr()`) has the effect of printing them with double quotes. For floats, this ensures a `.0` appears after it, even if it doesn't have decimal digits. For integers, this doesn't change anything. Finally, for labels, the `<label>` (with `?`) is printed as `<label>` instead of `label`.
    - **TIP:** Prefer to always use `?` when you're inserting something that isn't a string, number or label, in order to ensure consistent results even if the library eventually changes the non-`?` representation.
- After the `:`, add e.g. `_<8` to align the string to the left, padding it with as many `_`s as necessary for it to be at least `8` characters long (for example). Replace `<` by `>` for right alignment, or `^` for center alignment. (If the `_` is omitted, it defaults to ' ' (aligns with spaces).)
    - If you prefer to specify the minimum width (the `8` there) as a separate argument to `strfmt` instead, you can specify `argument$` in place of the width, which will extract it from the integer at `argument`. For example, `_^3$` will center align the output with `_`s, where the minimum width desired is specified by the fourth positional argument (index `3`), as an integer. This means that a call such as `strfmt("{:_^3$}", 1, 2, 3, 4)` would produce `"__1__"`, as `3$` would evaluate to `4` (the value at the fourth positional argument/index `3`). Similarly, `named$` would take the width from the argument with name `named`, if it is an integer (otherwise, error).
- **For numbers:**
    - Specify `+` after the `:` to ensure zero or positive numbers are prefixed with `+` before them (instead of having no sign). `-` is also accepted but ignored (negative numbers always specify their sign anyways).
    - Use something like `:09` to add zeroes to the left of the number until it has at least 9 digits / characters.
        - The `9` here is also a width, so the same comment from before applies (you can add `$` to take it from an argument to the `strfmt` function).
    - Use `:.5` to ensure your float is represented with 5 decimal digits of precision (zeroes are added to the right if needed; otherwise, it is rounded, **not truncated**).
        - Note that floating point inaccuracies can be sometimes observed here, which is an unfortunate current limitation.
        - Similarly to `width`, the precision can also be specified via an argument with the `$` syntax: `.5$` will take the precision from the integer at argument number 5 (the sixth one), while `.test$` will take it from the argument named `test`.
    - **Integers only:** Add `x` (lowercase hex) or `X` (uppercase) at the end of the `spec` to convert the number to hexadecimal. Also, `b` will convert it to binary, while `o` will convert to octal.
        - Specify a hashtag, e.g. `#x` or `#b`, to prepend the corresponding base prefix to the base-converted number, e.g. `0xABC` instead of `ABC`.
    - Add `e` or `E` at the end of the `spec` to ensure the number is represented in scientific notation (with `e` or `E` as the exponent separator, respectively).
    - For decimal numbers (floats), you can specify `fmt-decimal-separator: ","` to `strfmt` to have the decimal separator be a comma instead of a dot, for example.
        - To have this be the default, you can alias `strfmt`, such as using `#let strfmt = strfmt.with(fmt-decimal-separator: ",")`.
    - Number spec arguments (such as `.5`) are ignored when the argument is not a number, but e.g. a string, even if it looks like a number (such as `"5"`).
- Note that all spec arguments above **have to be specified in order** - if you mix up the order, it won't work properly!
    - Check the grammar below for the proper order, but, in summary: fill (character) with align (`<`, `>` or `^`) -> sign (`+` or `-`) -> `#` -> `0` (for 0 left-padding of numbers) -> width (e.g. `8` from `08` or `9` from `-<9`) -> `.precision` -> spec type (`?`, `x`, `X`, `b`, `o`, `e`, `E`)).

Some examples:

```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s1 = strfmt("{0:?}, {test:+012e}, {1:-<#8x}", "hi", -74, test: 569.4)
#assert.eq(s1, "\"hi\", +00005.694e2, -0x4a---")

#let s2 = strfmt("{:_>+11.5}", 59.4)
#assert.eq(s2, "__+59.40000")

#let s3 = strfmt("Dict: {:!<10?}", (a: 5))
#assert.eq(s3, "Dict: (a: 5)!!!!")
```

### Examples

- **Inserting labels, text and numbers into strings:**
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("First: {}, Second: {}, Fourth: {3}, Banana: {banana} (brackets: {{escaped}})", 1, 2.1, 3, label("four"), banana: "Banana!!")
#assert.eq(s, "First: 1, Second: 2.1, Fourth: four, Banana: Banana!! (brackets: {escaped})")
```

- **Forcing `repr()` with `{:?}`** (which adds quotes around strings, and other things - basically represents a Typst value):
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("The value is: {:?} | Also the label is {:?}", "something", label("label"))
#assert.eq(s, "The value is: \"something\" | Also the label is <label>")
```

- **Inserting other types than numbers and strings** (for now, they will always use `repr()`, even without `{...:?}`, although that is more explicit):
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("Values: {:?}, {1:?}, {stuff:?}", (test: 500), ("a", 5.1), stuff: [a])
#assert.eq(s, "Values: (test: 500), (\"a\", 5.1), [a]")
```

- **Padding to a certain width with characters:** Use `{:x<8}`, where `x` is the **character to pad with** (e.g. space or `_`, but can be anything), `<` is the **alignment of the original text** relative to the padding (can be `<` for left aligned (padding goes to the right), `>` for right aligned (padded to its left) and `^` for center aligned (padded at both left and right)), and `8` is the **desired total width** (padding will add enough characters to reach this width; if the replacement string already has this width, no padding will be added):
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("Left5 {:-<5}, Right6 {:=>6}, Center10 {centered: ^10?}, Left3 {tleft:_<3}", "xx", 539, tleft: "okay", centered: [a])
#assert.eq(s, "Left5 xx---, Right6 ===539, Center10     [a]    , Left3 okay")
// note how 'okay' didn't suffer any padding at all (it already had at least the desired total width).
```

- **Padding numbers with zeroes to the left:** It's a similar functionality to the above, however you write `{:08}` for 8 characters (for instance) - note that any characters in the number's representation matter for width (including sign, dot and decimal part):
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("Left-padded7 numbers: {:07} {:07} {:07} {3:07}", 123, -344, 44224059, 45.32)
#assert.eq(s, "Left-padded7 numbers: 0000123 -000344 44224059 0045.32")
```

- **Defining padding-to width using parameters, not literals:** If you want the desired replacement width (the `8` in `{:08}` or `{: ^8}`) to be passed via parameter (instead of being hardcoded into the format string), you can specify `parameter$` in place of the width, e.g. `{:02$}` to take it from the third positional parameter, or `{:a>banana$}` to take it from the parameter named `banana` - note that the chosen parameter **must be an integer** (desired total width):
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("Padding depending on parameter: {0:02$} and {0:a>banana$}", 432, 0, 5, banana: 9)
#assert.eq(s, "Padding depending on parameter: 00432 aaaaaa432")  // widths 5 and 9
```

- **Displaying `+` on positive numbers:** Just add a `+` at the "beginning", i.e., before the `#0` (if either is there), or after the custom fill and align (if it's there and not `0` - see [Grammar](#grammar) for the exact positioning), like so:
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("Some numbers: {:+} {:+08}; With fill and align: {:_<+8}; Negative (no-op): {neg:+}", 123, 456, 4444, neg: -435)
#assert.eq(s, "Some numbers: +123 +0000456; With fill and align: +4444___; Negative (no-op): -435")

```

- **Converting numbers to bases 2, 8 and 16:** Use one of the following specifier types (i.e., characters which always go at the very end of the format): `b` (binary), `o` (octal), `x` (lowercase hexadecimal) or `X` (uppercase hexadecimal). You can also add a `#` between `+` and `0` (see the exact position at the [Grammar](#grammar)) to display a **base prefix** before the number (i.e. `0b` for binary, `0o` for octal and `0x` for hexadecimal):
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("Bases (10, 2, 8, 16(l), 16(U):) {0} {0:b} {0:o} {0:x} {0:X} | W/ prefixes and modifiers: {0:#b} {0:+#09o} {0:_>+#9X}", 124)
#assert.eq(s, "Bases (10, 2, 8, 16(l), 16(U):) 124 1111100 174 7c 7C | W/ prefixes and modifiers: 0b1111100 +0o000174 ____+0x7C")
```

- **Picking float precision (right-extending with zeroes):** Add, at the end of the format (just before the spec type (such as `?`), if there's any), either `.precision` (hardcoded, e.g. `.8` for 8 decimal digits) or `.parameter$` (taking the precision value from the specified parameter, like with `width`):
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("{0:.8} {0:.2$} {0:.potato$}", 1.234, 0, 2, potato: 5)
#assert.eq(s, "1.23400000 1.23 1.23400")
```

- **Scientific notation:** Use `e` (lowercase) or `E` (uppercase) as specifier types (can be combined with precision):
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("{0:e} {0:E} {0:+.9e} | {1:e} | {2:.4E}", 124.2312, 50, -0.02)
#assert.eq(s, "1.242312e2 1.242312E2 +1.242312000e2 | 5e1 | -2.0000E-2")
```

- **Customizing the decimal separator on floats:** Just specify `fmt-decimal-separator: ","` (comma as an example):
```typ
#import "@preview/oxifmt:0.2.1": strfmt

#let s = strfmt("{0} {0:.6} {0:.5e}", 1.432, fmt-decimal-separator: ",")
#assert.eq(s, "1,432 1,432000 1,43200e0")
```

### Grammar

Here's the grammar specification for valid format `spec`s (in `{name:spec}`), which is basically Rust's format:

```
format_spec := [[fill]align][sign]['#']['0'][width]['.' precision]type
fill := character
align := '<' | '^' | '>'
sign := '+' | '-'
width := count
precision := count | '*'
type := '' | '?' | 'x?' | 'X?' | identifier
count := parameter | integer
parameter := argument '$'
```

Note, however, that precision of type `.*` is not supported yet and will raise an error.

## Issues and Contributing

Please report any issues or send any contributions (through pull requests) to the repository at https://github.com/PgBiel/typst-oxifmt

## Testing

If you wish to contribute, you may clone the repository and test this package with the following commands (from the project root folder):

```sh
git clone https://github.com/PgBiel/typst-oxifmt
cd typst-oxifmt/tests
typst c strfmt-tests.typ --root ..
```

The tests succeeded if you received no error messages from the last command (please ensure you're using a supported Typst version).

## Changelog

### v0.2.1

- Fixed formatting of UTF-8 strings. Before, strings with multi-byte UTF-8 codepoints would cause formatting inconsistencies or even crashes. ([Issue #6](https://github.com/PgBiel/typst-oxifmt/issues/6))
- Fixed an inconsistency in negative number formatting. Now, it will always print a regular hyphen (e.g. '-2'), which is consistent with Rust's behavior; before, it would occasionally print a minus sign instead (as observed in a comment to [Issue #4](https://github.com/PgBiel/typst-oxifmt/issues/4)).
- Added compatibility with Typst 0.8.0's new type system.

### v0.2.0

- The package's name is now `oxifmt`!
- `oxifmt:0.2.0` is now available through Typst's Package Manager! You can now write `#import "@preview/oxifmt:0.2.0": strfmt` to use the library.
- Greatly improved the README, adding a section for common examples.
- Fixed negative numbers being formatted with two minus signs.
- Fixed custom precision of floats not working when they are exact integers.

### v0.1.0

- Initial release, added `strfmt`.

## License

MIT-0 license (see the `LICENSE` file).
