# Documentation
The only function offered by this package is `code`, which renders a block of source code. It's only required parameter is `source`, which is a positional parameter and is expected to be raw text (`raw`). This block can additionally use a syntax specifier (`rs`, `py`, etc.) and it will be handled fine by the system.

## Options
### `line-spacing`: `length | relative`
The spacing between lines of code and wrapped line sections.

*Default*: `5pt`.

### `line-offset`: `length | relative`
The spacing between the line numbers to the lines.

*Default*: `5pt`.

### `numbering`: `bool`
Wether to number the lines in the block. If `true`, the lines will be numbered. If numbering isn't used `line-offset` is ignored.

*Default*: `true`.

### `inset`: `length | relative`
The inset of items in the code block, such as line numbers and lines of code.

*Default*: `5pt`.

### `radius`: `length | relative`
The radius of the code block.

*Default*: `3pt`.

### `number-align`: `alignment`
The alignment of the line numbers.

*Default*: `left`.

### `stroke`: `none | stroke`
The stroke of the code block. If `none` is used, there will be no stroke.

*Default*: `1pt + luma(180)`.

### `fill`: `none | color | gradient`
The filling of the code block. If `none` is used, there will be no filling.

*Default*: `luma(250)`.

### `text-style`: `dictionary`
A dictionary of parameters to pass to the `text` function, used for rendering all text in the code block.

*Default*: `()`.

### `width`: `auto | length | relative`
The width of the code block. Using `auto` means it will be scaled in accordance to the longest line.

*Default*: `auto`.

### `lines`: `(auto | int, auto | int) | auto`
The line range to be displayed in the code block. Lines are specified here starting from `1`, and the range is inclusive. This means that in order to select lines `3` to `10`, we would use the array: `(3, 10)`. When `auto` is used at the top-level, all of the code is displayed. When used for an individual line, it is used to extend until the first/last line based on the location, similarly to `..x` and `x..` ranges.

*Default*: `auto`.

### `lang`: `none | str`
The text shown inside of the top-right box, specifying the language used. The text can be of the full language name, so `Rust`, instead of `rs`, but that need not be. If `none` is used, the box won't be displayed.

*Default*: `none`.

### `lang-box`: `(radius: length | relative, outset: length | relative, fill: none | color | gradient, stroke: stroke | none)`
Used to pass styling options to the top-right box showing the language used. `radius` controls the box radius, `outset`, its outset, `fill`, its fill and `stroke` its, stroke.

*Default*: `(radius: 3pt, outset: 1.75pt, fill: rgb("#ffbfbf"), stroke: 1pt + rgb("#ff8a8a"))`

## Notes
- If any more customization is needed, feel free to open an issue or send a PR. These may not however be accepted, depending on their nature.
- `sourcerer` uses the `"sourcerer"` `kind` for its figures, used for referencing lines. This means that using this same kind will cause issues in your documents.
- It is recommended to use a `set` rule for the `code` function, for styling for example, the font used for rendering.
