# mandolin

Render manpages to PDF using [mandoc](https://mandoc.bsd.lv).

## Example

Render the `mandoc.1` manual side-by-side.

```typst
#import "@preview/mandolin:1.0.0": render-manpage

#set page(margin: 0mm, flipped: true)

#let (mandoc-1, pages) = render-manpage(read("mandoc.1"))
#grid(
  columns: 2,
  ..range(1, pages+1).map(page => image(mandoc-1, page: page)),
)
```

## Reference

```typst
#let (pdf, pages) = render-manpage(man-text,
                                   paper: "A4",
                                   os: "Typst",
                                   lineheight: 1.4,
                                   parspacing: 1)
```

**Arguments**:
- `man-text`: Contents of the manpage, typically from `read()`.
- `paper`: Paper size. Options: A3, A4, A5, Letter, or a custom size in mm like 100x200.
- `os`: Default OS shown in the footer, if not set in the manpage.
- `lineheight`: Line height in em.
- `parspacing`: Spacing between paragraphs as a fraction of lineheight.

**Return values**:
- `pdf`: The rendered PDF, for passing to `image()`.
- `pages`: The number of pages in the rendered PDF.

## Limitations

- Reading compressed manpages is not supported.
- Including other source files with `.so` is not possible.
