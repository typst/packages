# The `koma-labeling` Package

<div align="center">Version 0.2.0</div>

The koma-labeling package for Typst is inspired by the labeling environment from the KOMA-Script bundle in LaTeX. It provides a convenient way to create labeled lists with customizable label widths and optional delimiters, making it perfect for creating structured descriptions and lists in your Typst documents.

## Getting Started

To get started with koma-labeling, simply import the package in your Typst document and use the labeling environment to create your labeled lists.

```typ
#import "@preview/koma-labeling:0.2.0": labeling

#labeling(
  (
    (lorem(1), lorem(10)),
    (lorem(2), lorem(20)),
    (lorem(3), lorem(30)),
  )
)

// or

#labeling(
  (
    ([#lorem(1)], [#lorem(10)]),
    ([#lorem(2)], [#lorem(20)]),
    ([#lorem(3)], [#lorem(30)]),
  )
)
```

Output:

![image](https://github.com/user-attachments/assets/bf382afe-f66d-4032-9055-f46c72a2e7dd)


**Note:** Remember to terminate the list with a comma, even if only one pair of items is passed.

```typ
#import "@preview/koma-labeling:0.2.0": labeling

#labeling(
  (
    (lorem(1), lorem(10)),  // Terminating the list with a comma is REQUIRED
  )
)
```

## Parameters

Although labeling is implemented using `grid`, its usage is similar to `terms`, except that it lacks the `tight` and `hanging-indent` parameters. If you have any questions about the parameters for `labeling`, you can refer to [`terms`](https://typst.app/docs/reference/model/terms/).

```typ
labeling(
  separator: content,
  indent: length,
  spacing: auto length
  body: ((content, content))
)
```

### separator

The separator between the item and the description.

Default: `[:#h(0.6em)]`

### indent

The indentation of each item.

Default: `0pt`

### spacing

The spacing between the items of the term list.

Default: `auto`

### pairs

An array of `(item, description)` pairs.

Example:

```typ
#labeling(
  (
    ([key 1],[description 1]),
    ([keyword 2],[description 2]),
  )
)
```

## Additional Documentation and Acknowledgments

For more information on the koma-labeling package and its features, you can refer to the following resources:

- Typst Documentation: [Typst Documentation](https://typst.app/docs)
- KOMA-Script Documentation: [KOMA-Script Documentation](https://ctan.org/pkg/koma-script)
