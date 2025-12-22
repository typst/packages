# diff-doc

This is a library for displaying document differences in Typst.

## Usage

### diff-string

Compares two strings and highlights the differences.

```typst
#import "@preview/diff-doc:0.1.0": *

#let a = "hello, workd. こんばんは"
#let b = "hello, world. こんにちは"

#diff-string(a, b)
```

The output will look like this:

<img src="./figure/diff-string.png">

### diff-content

Compares two Typst contents and highlights the differences, preserving styles.

```typst
#import "@preview/diff-doc:0.1.0": *

#diff-content(
  include "diff-a.typ",
  include "diff-b.typ"
)
```

<img src="./figure/diff-content.png">

## Functions

### `diff-string(a, b, format-plus, format-minus, split-regex)`

- `a`, `b`: The two strings to compare.
- `format-plus`: A function to format added text. (Default: `x => text(x, fill: blue, weight: "bold")`)
- `format-minus`: A function to format removed text. (Default: `x => strike(text(x, fill: red, size: 0.75em))`)
- `split-regex`: A regular expression string to split the strings for comparison. (Default: `"[^A-Za-z0-9]"`)

### `diff-content(a, b, format-plus, format-minus, split-regex)`

- `a`, `b`: The two Typst contents to compare.
- `format-plus`: A function to format added text. (Default: `x => text(x, fill: blue, weight: "bold")`)
- `format-minus`: A function to format removed text. (Default: `x => strike(text(x, fill: red, size: 0.75em))`)
- `split-regex`: A regular expression string to split the contents for comparison. (Default: `"[^A-Za-z0-9]"`)

## License

This project is licensed under the MIT License.
