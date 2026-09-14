# Vanilla Typst Theme

A vanilla Typst theme that aims for minimalist and clean styling similar to conventional word processor defaults.

## Features

- Clean and familiar document styling
- Single and double spaced paragraph options
- Shadow box elements
- Customizable margins, fonts, and font sizes
- Line spacing styles similar to standard word processing defaults

## Usage

```typst
#import "@preview/vanilla:0.1.1": vanilla, par-single-spaced, par-double-spaced

// Apply the vanilla style to the document
#show: vanilla.with(
  body-line-spacing: "double",
  body-first-line-indent: 0.5in,
  justified: true
)

= Heading 1
== Heading 2
=== Heading 3

#par-double-spaced[
  This paragraph will be double-spaced with indent.
  #lorem(50)
]

#par-single-spaced[
  This paragraph will be single-spaced.
  #lorem(20)
]
```

## Configuration Options

The `vanilla` function accepts the following parameters:

- `margins`: Specify page margins (default: `(left: 1in, right: 1in, top: 1in, bottom: 1in)`)
- `body-font-family`: Main body font (default: `"Libertinus Serif"`)
- `body-font-size`: Main body font size (default: `12pt`)
- `body-line-spacing`: `"single"` or `"double"` (default: `"single"`)
- `body-first-line-indent`: Paragraph indentation (default: `0in`)
- `footnote-font-size`: `10pt`
- `footnote-line-spacing`: `"single"`
- `list-line-spacing`: `"single"`
- `justified`: Whether text should be justified (default: `false`)

### About Spacing

The line spacing parameters aim to mimic the default spacing commonly used in word processors like Microsoft Word and Google Docs. Many forums, such as legal courts, require conformance to the standards set by word processors.

"Double" spacing is actually about 115% of the point size baseline-to-baseline. Double-spacing in Microsoft Word should result in 23 lines of 12-pt Times New Roman in a US letter page (8.5 x 11 in) with 1-in margins.

> The new spacing also contributes to the readability of your document. This new spacing comes from a combination of three things. The new font chosen is more “open” than Times New Roman, the font previously used. We also added a bit of space between each line within the paragraph. Though some folks have described this as “double-spaced,” it is actually 115% of the line height (double-spaced would be 200%). You could call this one-and-about-a-sixth spacing if you’d like. Finally, we added space after each paragraph. That means that rather than having to press Enter twice at the end of a paragraph in order to make the start of the paragraph noticeable, you simply press Enter once and we add the space for you.

[learn.microsoft.com: The new document look (05/21/2006)](https://learn.microsoft.com/en-us/archive/blogs/joe_friend/the-new-document-look)

Note that Typst's layout is a bit more greedy than Word and squeezes in 24 lines (see `examples/linecount.typ`) even with identical line spacing.

## License

This package is licensed under the MIT License. See the LICENSE file for details.
