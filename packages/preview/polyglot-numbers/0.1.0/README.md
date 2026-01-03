# polyglot-numbers
> **NOTE!**

> This is a fork of the `name-it` package, originally intended for the English language only.
> I've modularized it to support multiple languages!

Get the names of integers in any language!

## Example
### In English!
![Example](./examples/example-en.png)
```typ
#import "@preview/name-all-the-numbers:0.1.0": name-it
#set page(width: auto, height: auto, margin: 1cm)

=== English
- #name-it(-5)
- #name-it(0)
- #name-it(1)
- #name-it(10)
- #name-it(11)
- #name-it(42)
- #name-it(100)
- #name-it(110)
- #name-it(1104)
- #name-it(11040)
- #name-it(11000)
- #name-it(110000)
- #name-it(1100004)
- #name-it(10000000000006)
- #name-it(10000000000006, show-and: false)
- #name-it("200000000000000000000000007")
```

### In Indonesian!
![Indonesian](./examples/example-id.png)
```typ
#import "@preview/name-all-the-numbers:0.1.0": name-it
#set page(width: auto, height: auto, margin: 1cm)

=== Indonesian
- #name-it(-5, lang: "id")
- #name-it(0, lang: "id")
- #name-it(1, lang: "id")
- #name-it(10, lang: "id")
- #name-it(11, lang: "id")
- #name-it(42, lang: "id")
- #name-it(100, lang: "id")
- #name-it(110, lang: "id")
- #name-it(1104, lang: "id")
- #name-it(11040, lang: "id")
- #name-it(11000, lang: "id")
- #name-it(110000, lang: "id")
- #name-it(1100004, lang: "id")
- #name-it(10000000000006, lang: "id")
- #name-it("200000000000000000000000007", lang: "id")
```

## Usage
### `name-it`
Convert the given number into its word representation in your specified language!
```typ
#let name-it(num, lang: "en", ..options) = { .. }
```

**Arguments:**
- `num`: [`int`] or [`str`] The number to name. Strings are accepted to support very large numbers that exceed integer limits.
- `lang`: [`str`] The language code for conversion. Currently supported: `"en"` (English), `"id"` (Indonesian). Default: `"en"`.
- `..options`: Additional language-specific options:
  - `show-and`: [`bool`] (English only) Whether "and" should be used in certain places. For example, "one hundred ten" vs "one hundred and ten". Default: `true`.

**Returns:** [`str`] The word representation of the number.

## Supported Languages
- **English** (`"en"`)
- **Indonesian** (`"id"`)

## Contributing New Languages
Want to add support for a new language? Great! Here's how:

1. Create a new file in `languages/` (e.g., `languages/fr.typ` for French)
2. Implement the following functions:
   - `convert-group(digits, scale-idx, options)` - For converting a 3-digit group to words
   - `join-parts(parts, options)` - Join all parts with scale names
   - `format-negative(text)` - Format numbers into their negative counterparts
3. Export a `lang-config` dictionary with:
   - `zero-name` - The word for zero
   - The three functions above
4. Add your language to `lib.typ` in the `languages` dictionary
5. Submit a pull request!

See `languages/en.typ` and `languages/id.typ` for examples.

[`str`]: https://typst.app/docs/reference/foundations/str/
[`int`]: https://typst.app/docs/reference/foundations/int/
[`bool`]: https://typst.app/docs/reference/foundations/bool/
