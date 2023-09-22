# `syntastica` for Typst

Tree-sitter syntax highlighting for code blocks.

## Showcase

![Comparison between normal and syntastica highlighting](https://raw.githubusercontent.com/RubixDev/syntastica-typst/main/examples/comparison.png)

````typ
#import "@preview/syntastica:0.1.0": syntastica

#set page(height: auto, width: auto, margin: 1cm)

Without `syntastica`:

```rust
fn fib(n: usize) -> usize {
    if n < 2 {
        n
    } else {
        fib(n - 1) + fib(n - 2)
    }
}
```

#show raw: syntastica

With `syntastica`:

```rust
fn fib(n: usize) -> usize {
    if n < 2 {
        n
    } else {
        fib(n - 1) + fib(n - 2)
    }
}
```
````

For more examples, have a look at the
['examples'](https://github.com/RubixDev/syntastica-typst/tree/main/examples/)
directory.

## Performance

Please bear in mind that this package is **slow**. And the more different
languages you make use of, the slower it will get. This is actually somewhat
fine when using an LSP, which will run the language initialization code in the
plugin once, and then keep it in memory for following compilations.

One way to go about this is to add a top-level variable for toggling
`syntastica` and only set it to `true` for production builds. See the
[`prod_toggle` example](https://github.com/RubixDev/syntastica-typst/blob/main/examples/prod_toggle.typ)
for an implementation of this approach.

## Usage

### `syntastica`

Apply `syntastica` highlighting to a raw code element.

```typ
#let syntastica(it, theme: "one::light") = { ... }
```

**Arguments:**

- `it`: [`content`] &mdash; The
  [raw element](https://typst.app/docs/reference/text/raw/) to apply
  highlighting to.
- `theme`: [`str`] &mdash; The theme to use. See
  [here](https://github.com/RubixDev/syntastica-typst/blob/main/examples/all_themes.pdf)
  for a list of all themes.

### `languages`

Get a list of all supported languages.

```typ
#let languages() = { ... }
```

**Returns:** An [`array`] of [`str`]s.

### `themes`

Get a list of all supported themes.

```typ
#let themes() = { ... }
```

**Returns:** An [`array`] of [`str`]s.

### `theme-bg`

Get the default background color of a theme.

```typ
#let theme-bg(theme) = { ... }
```

**Arguments:**

- `theme`: [`str`] &mdash; The theme name.

**Returns:** [`color`] or `none`

### `theme-fg`

Get the default foreground color of a theme.

```typ
#let theme-fg(theme) = { ... }
```

**Arguments:**

- `theme`: [`str`] &mdash; The theme name.

**Returns:** [`color`] or `none`

[`array`]: https://typst.app/docs/reference/foundations/array/
[`str`]: https://typst.app/docs/reference/foundations/str/
[`content`]: https://typst.app/docs/reference/foundations/content/
[`color`]: https://typst.app/docs/reference/visualize/color/
