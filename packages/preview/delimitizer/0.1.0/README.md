# `delimitizer`

This package lets you customize the size of delimiters in your math equations. It is useful when you want to make your equations more readable by increasing the size of certain delimiters. Just like `\big`, `\Big`, `\bigg`, and `\Bigg` in LaTeX, `delimitizer` provides you with the same functionality in Typst.

- `big(delimiter)`: Makes the delimiters bigger than the default size.
- `Big(delimiter)`: Makes the delimiters bigger than `big()`.
- `bigg(delimiter)`: Makes the delimiters bigger than `Big()`.
- `Bigg(delimiter)`: Makes the delimiters bigger than `bigg()`.
- `scaled-delimiter(delimiter, size)`: Scales the delimiters by a factor of your choice.

Example:
```typst
$
Big(\()
big(\()
(a+b)times (a-b)
big(\))
div
big(\()
(c+d)times (c-d)
big(\))
Big(\))+d \ = (a^2-b^2)/(c^2-d^2)+d
$
```

![demo](./demo.svg)