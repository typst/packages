# Marginalia

## Setup

Put something akin to the following at the start of your `.typ` file:

```typ
#import "@preview/marginalia:0.1.1" as marginalia: note, wideblock
#let config = (
  // inner: ( far: 5mm, width: 15mm, sep: 5mm ),
  // outer: ( far: 5mm, width: 15mm, sep: 5mm ),
  // top: 2.5cm,
  // bottom: 2.5cm,
  // book: false,
  // clearance: 8pt,
  // flush-numbers: false,
  // numbering: /* numbering-function */,
)
#marginalia.configure(..config)
#set page(
  // setup margins:
  ..marginalia.page-setup(..config),
  /* other page setup */
)
```

If `book` is `false`, `inner` and `outer` correspond to the left and right
margins respectively. If book is true, the margins swap sides on even and odd
pages. Notes are placed in the outside margin by default.

Where you can then customize `config` to your preferences. Shown here (as
comments) are the default values taken if the corresponding keys are unset.
[Please refer to the PDF documentation for more details on the configuration and the provided commands.](https://github.com/nleanba/typst-marginalia/blob/v0.1.1/Marginalia.pdf)

## Margin-Notes

Provided via the `#note[...]` command.

- `#note(reverse: true)[...]` to put it on the inside margin.
- `#note(numbered: false)[...]` to remove the marker.

Note: it is recommended to reset the counter for the markers regularly, e.g. by
putting `marginalia.notecounter.update(0)` into the code for your header.

## Wide Blocks

Provided via the `#wideblock[...]` command.

- `#wideblock(reverse: true)[...]` to extend into the inside margin instead.
- `#wideblock(double: true)[...]` to extend into both margins.

Note: `reverse` and `double` are mutually exclusive.

Note: Wideblocks do not handle pagebreaks in `book: true` documents well.

## Figures

You can use figures as normal, also within wideblocks.
To get captions on the side, use
```typ
#set figure(gap: 0pt)
#set figure.caption(position: top)
#show figure.caption.where(position: top): note.with(numbered: false, dy: 1em)
```

For small figures, the package also provides a `notefigure` command which places the figure in the margin.
```typ
#marginalia.notefigure(
  rect(width: 100%),
  label: <aaa>,
  caption: [A notefigure.],
)
```

-------


[![first page of the documentation](https://github.com/nleanba/typst-marginalia/raw/refs/tags/v0.1.1/preview.svg)](https://github.com/nleanba/typst-marginalia/blob/v0.1.1/Marginalia.pdf)
