# Codly: simple and powerful code blocks

<p align="center">
  <a href="https://github.com/Dherse/codly/blob/main/docs.pdf">
    <img alt="Documentation" src="https://img.shields.io/website?down_message=offline&label=manual&up_color=007aff&up_message=online&url=https%3A%2F%2Fgithub.com%2FDherse%2Fcodly%2Fblob%2Fmain%2Fdocs.pdf" />
  </a>
  <a href="https://github.com/Dherse/codly/blob/main/LICENSE">
    <img alt="MIT License" src="https://img.shields.io/badge/license-MIT-brightgreen">
  </a>
  <img src="https://github.com/Dherse/codly/actions/workflows/test.yml/badge.svg" />
</p>

Codly is a package that lets you easily create **beautiful** code blocks for your Typst documents.
It uses the newly added [`raw.line`](https://typst.app/docs/reference/text/raw/#definitions-line)
function to work across all languages easily. You can customize the icons, colors, and more to
suit your document's theme. By default it has zebra striping, line numbers, for ease of reading.

A full set of documentation can be found [in the repo](https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf).

![Example](./demo.png)

````typ
#import "@preview/codly:1.0.0": *
#show: codly-init.with()

#codly(
  languages: (
    rust: (
      name: "Rust",
      icon: text(font: "tabler-icons", "\u{fa53}),
      color: rgb("#CE412B")
    ),
  )
)

```rust
pub fn main() {
    println!("Hello, world!");
}
```
````

### Setup

To start using codly, you need to initialize codly using a show rule:

```typ
#show: codly-init.with()
```
> [!TIP]
> You only need to do this once at the top of your document!

Then you *can* to configure codly with your parameters:

```typ
#codly(
  languages: (
    rust: (name: "Rust", icon: "\u{fa53}", color: rgb("#CE412B")),
  )
)
```

> [!IMPORTANT]
> Any parameter that you leave blank will use the previous values (or the default value if never set) similar to a `set` rule in regular typst. But the changes are always global unless you use the provided `codly.local` function. To get a full list of all settings, see the [documentation](https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf).

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

Alternatively, you can use the `no-codly` function to achieve the same effect locally:

````typ
#no-codly[
  ```typ
  I will be displayed using the normal raw blocks.
  ```
]
````

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

### Adding a "skip"

You can add a "fake" skip between lines using the `skips` parameters:

```typ
// Before the 5th line (indexing start at 0), insert a 32 line jump.
#codly(skips: ((4, 32), ))
```

This can be customized using the `skip-line` and `skip-number` to customize what it looks like.

### Adding annotations

> [!IMPORTANT]
> This is a Beta feature and has a few quirks, refer to [the documentation](https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf) for those

You can annotate a line/group of lines using the `annotations` parameters :

```typ
// Add an annotation from the second line (0 indexing) to the 5th line included.
#codly(
  annotations: (
    (
      start: 1,
      end: 4,
      content: block(
        width: 2em,
        // Rotate the element to make it look nice
        rotate(
          -90deg,
          align(center, box(width: 100pt)[Function body])
        )
      )
    ), 
  )
)
```

### Disabling line numbers

You can configure this with the `codly` function:

```typ
#codly(number-format: none)
```

### Disabling zebra striping

You disable zebra striping by setting the `zebra-fill` to white.

```typ
#codly(zebra-fill: none)
```

### Customize the stroke

You can customize the stroke surrounding the figure using the `stroke` parameter of the `codly` function:

```typ
#codly(stroke: 1pt + red)
```

### Misc

You can also disable the icon, by setting the `display-icon` parameter to `false`:

```typ
#codly(display-icon: false)
```

Same with the name, whether the block is breakable, the radius, the padding, and the width of the numbers columns, and so many more [documentation](https://raw.githubusercontent.com/Dherse/codly/main/docs.pdf).
