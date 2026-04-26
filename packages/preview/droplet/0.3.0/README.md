# droplet

A package for creating dropped capitals.

## Usage

This package exports a single `dropcap` function that is used to create dropped capitals. The function takes one or two positional arguments, and several optional keyword arguments for customization:

| Parameter        | Type                          | Description                                               | Default |
|------------------|-------------------------------|-----------------------------------------------------------|---------|
| `height`         | `integer`, `length`, `auto`   | The height of the dropped capital.                        | `2`     |
| `justify`        | `boolean`, `auto`             | Whether the text should be justified.                     | `auto`  |
| `gap`            | `length`                      | The space between the dropped capital and the text.       | `0pt`   |
| `hanging-indent` | `length`                      | The indent of lines after the first.                      | `0pt`   |
| `overhang`       | `length`, `relative`, `ratio` | How much the dropped capital should hang into the margin. | `0pt`   |
| `depth`          | `integer`, `length`           | The space below the dropped capital.                      | `0pt`   |
| `transform`      | `function`, `none`            | A function to be applied to the dropped capital.          | `none`  |
| `..text-args`    |                               | How to style the `text` of the dropped capital.           |         |

Some parameters allow values of different types for maximum flexibility:

- If `height` is given as an integer, it is interpreted as a number of lines. If given as `auto`, the dropped capital will not be scaled and remain at its original size.
- If `overhang` has a relative part, it is resolved relative to the width of the dropped capital.
- If `depth` is given as an integer, it is interpreted as a number of lines.
- The `transform` function takes the extracted or passed dropped capital and returns the content to be shown.

If two positional arguments are given, the first is used as the dropped capital, and the second as the text. If only one argument is given, the dropped capital is automatically extracted from the text.

### Extraction

If no explicit dropped capital is passed, it is extracted automatically. For this to work, the package looks into the content making up the first paragraph and extracts the first letter of the first word. This letter is then split off from the rest of the text and used as the dropped capital. There are some special cases to consider:

- If the first element of the paragraph is a `box`, the whole box is used as the dropped capital.
- If the first element is a list or enum item, it is assumed that the literal meaning of the list or enum syntax was intended, and the number or bullet is used as the dropped capital.

Affixes, such as punctuation, super- and subscripts, quotes, and spaces will also be detected and stay with the dropped capital.

### Paragraph Splitting

To wrap the text around the dropped capital, the paragraph is split into two parts: the part next to the dropped capital and the part after it. As Typst doesn't natively support wrapping text around an element, this package splits the paragraph at word boundaries and tries to fit as much in the first part as possible. This approach comes with some limitations:

- The paragraph is split at word boundaries, which makes hyphenation across the split impossible.
- Some elements cannot be properly split, such as containers, lists, and context expressions.
- The approach uses a greedy algorithm, which might not always find the optimal split.
- If the split happens at a block element, the spacing between the two parts might be off.

To determine whether an elements fits into the first part, the position of top edge of the element is crucial. If the top edge is above the baseline of the dropped capital, the element is considered to be part of the first part. This means that elements with a large height will be part of the first part. This is done to avoid gaps between the two parts of the paragraph.

### Styling

In case you wish to style the dropped capital more than what is possible with the arguments of the `text` function, you can use a `transform` function. This function takes the extracted or passed dropped capital and returns the content to be shown. The function is provided with the context of the dropped capital.

Note that when using `em` units, they are resolved relative to the font size of the dropped capital. When the dropped capital is scaled to fit the given `height` parameter, the font size is adjusted so that the _bounds_ of the transformed content match the given height. For that, the `top-edge` and `bottom-edge` parameters of `text-args` are set to `bounds` by default.

## Example

```typ
#import "@preview/droplet:0.3.0": dropcap

#set par(justify: true)

#dropcap(
  height: 3,
  gap: 4pt,
  hanging-indent: 1em,
  overhang: 8pt,
  font: "Curlz MT",
)[
  *Typst* is a new markup-based typesetting system that is designed to be as
  _powerful_ as LaTeX while being _much easier_ to learn and use. Typst has:

  - Built-in markup for the most common formatting tasks
  - Flexible functions for everything else
  - A tightly integrated scripting system
  - Math typesetting, bibliography management, and more
  - Fast compile times thanks to incremental compilation
  - Friendly error messages in case something goes wrong
]
```

![Result of example code.](assets/example.svg)
