# Marginalia

## Setup

Put something akin to the following at the start of your `.typ` file:

```typ
#import "@preview/marginalia:0.2.4" as marginalia: note, notefigure, wideblock

#show: marginalia.setup.with(
  // inner: ( far: 5mm, width: 15mm, sep: 5mm ),
  // outer: ( far: 5mm, width: 15mm, sep: 5mm ),
  // top: 2.5cm,
  // bottom: 2.5cm,
  // book: false,
  // clearance: 12pt,
)
```

If `book` is `false`, `inner` and `outer` correspond to the left and right
margins respectively. If book is true, the margins swap sides on even and odd
pages. Notes are placed in the outside margin by default.

Where you can then customize these options to your preferences.
Shown here (as comments) are the default values taken if the corresponding keys are unset.
[Please refer to the PDF documentation for more details on the configuration and the provided commands.](https://github.com/nleanba/typst-marginalia/blob/v0.2.4/Marginalia.pdf?raw=true)

(Note that the above configuration step is not necessary if you are happy with the defaults provided and are using a4 paper.)

## Margin-Notes

Provided via the `#note[...]` command.

- `#note(side: "inner")[...]` to put it on the inside margin (left margin for single-sided documents).
- `#note(numbering: none)[...]` to remove the marker.
- `#note(shift: false)[...]` to force exact position of the note.
- `#note(shift: "ignore")[...]` to force exact position of the note and disable collision.
- ..and more


## Wide Blocks

Provided via the `#wideblock[...]` command.

- `#wideblock(side: "inner")[...]` to extend into the inside margin instead.
- `#wideblock(side: "both")[...]` to extend into both margins.

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
#notefigure(
  rect(width: 100%),
  label: <aaa>,
  caption: [A notefigure.],
)
```

## Manual

[Full Manual →](https://github.com/nleanba/typst-marginalia/blob/v0.2.4/Marginalia.pdf?raw=true)
[![first page of the documentation](https://github.com/nleanba/typst-marginalia/raw/refs/tags/v0.2.4/preview.svg)](https://github.com/nleanba/typst-marginalia/blob/v0.2.4/Marginalia.pdf?raw=true)

## Feedback
Have you encountered a bug? [Please report it as an issue in my github repository.](https://github.com/nleanba/typst-marginalia/issues)

Has this package been useful to you? [I am always happy when someone gives me a ~~sticker~~ star⭐](https://github.com/nleanba/typst-marginalia)