# `delimitizer`

This package lets you customize the size of delimiters in your math equations. It is useful when you want to make your equations more readable by increasing the size of certain delimiters. Just like `\big`, `\Big`, `\bigg`, and `\Bigg` in LaTeX, `delimitizer` provides you with the same functionality in Typst.

- `big(delimiter)`: Makes the delimiters bigger than the default size.
- `Big(delimiter)`: Makes the delimiters bigger than `big()`.
- `bigg(delimiter)`: Makes the delimiters bigger than `Big()`.
- `Bigg(delimiter)`: Makes the delimiters bigger than `bigg()`.
- `scaled-delimiter(delimiter, size)`: Scales the delimiters by a factor of your choice.
- `paired-delimiter(left, right)`: Make a short hand for paired delimiters. This function returns a closure `f(size = auto: auto | none | big | Big | bigg | Bigg | relative, content: content)`. The keyed argument `size` is optional and defaults to `auto`. The positional argument `content` is required.
  - when `size` is `auto`, the size of the delimiters is automatically determined.
  - when `size` is `none`, the size of the delimiters is `1em`.
  - when `size` is `big`/`Big`/`bigg`/`Bigg`, the size of the delimiters is set to `big`/`Big`/`bigg`/`Bigg` respectively.
  - when `size` is `relative` length like `3em` or `150%`, the size of the delimiters is scaled by the factor you provide.

Example:
```typst
#let parn = paired-delimiter("(", ")")

$
parn(size: bigg,
  parn(size: big, (a+b)times (a-b))
div
  parn(size: big, (c+d)times (c-d))
) + d \ = (a^2-b^2) / (c^2-d^2)+d
$

```

![demo](./demo.svg)