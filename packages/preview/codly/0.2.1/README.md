
# Codly: simple and beautiful code blocks for Typst

Codly is a package that lets you easily create beautiful code blocks for your Typst documents.
It uses the newly added [`raw.line`](https://typst.app/docs/reference/text/raw/#definitions-line)
function to work across all languages easily. You can customize the icons, colors, and more to
suit your document's theme. By default it has zebra striping, line numbers, for ease of reading.

````typ
#import "@preview/codly:0.2.0": *
#let icon(codepoint) = {
  box(
    height: 0.8em,
    baseline: 0.05em,
    image(codepoint)
  )
  h(0.1em)
}

#show: codly-init.with()
#codly(languages: (
  rust: (name: "Rust", icon: icon("brand-rust.svg"), color: rgb("#CE412B")),
))

```rust
pub fn main() {
    println!("Hello, world!");
}
```
````

Which renders to:

![Example](./demo.png)

You can find all of the documentation in the [example](https://github.com/Dherse/codly/tree/main/example/main.typ) file.

## Short manual

### Setup

To start using codly, you need to initialize codly using a show rule:

```typ
#show: codly-init.with()
```

Then you need to configure codly with your parameters:

```typ
#codly(
  languages: (
    rust: (name: "Rust", icon: icon("\u{fa53}"), color: rgb("#CE412B")),
  )
)
```

Any parameter that you leave blank will be set to its default.
Therefore calling `codly()` is equivalent to calling with all the default parameters.

Then you just need to add a code block and it will be automatically displayed correctly:

````
```rust
pub fn main() {
    println!("Hello, world!");
}
```
````

### Disabling

To locally disable codly, you can just do the following, you can then later re-enable it using the `codly` configuration function.

```typ
#disable-codly()
```

### Setting an offset

If you wish to add an offset to your code block, but without selecting a subset of lines, you can use the `codly-offset` function:

```typ
// Sets a 5 line offset
#codly-offset(5)
```

### Selecting a subset of lines

If you wish to select a subset of lines, you can use the `codly-range` function. By setting the start to 1 and the end to `none` you can select all lines from the start to the end of the code block.

```typ
#codly-range(start: 5, end: 10)
```

### Disabling line numbers

You can configure this with the `codly` function:

```typ
#codly(
  enable-numbers: false,
)
```

### Disabling zebra striping

You disable zebra striping by setting the `zebra-color` to white.

```typ
#codly(
  zebra-color: white,
)
```

### Customize the stroke

You can customize the stroke surrounding the figure using the `stroke-width` and `stroke-color` parameters of the `codly` function:

```typ
#codly(
  stroke-width: 1pt,
  stroke-color: red,
)
```

### Misc

You can also disable the icon, by setting the `display-icon` parameter to `false`:

```typ
#codly(
  display-icon: false,
)
```

Same with the name, whether the block is breakable, the radius, the padding, and the width of the numbers columns.
