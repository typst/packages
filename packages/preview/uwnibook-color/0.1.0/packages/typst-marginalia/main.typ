#import "lib.typ" as marginalia: note, wideblock

#let config = (
  inner: (far: 16mm, width: 20mm, sep: 8mm),
  outer: (far: 16mm, width: 40mm, sep: 8mm),
  top: 32mm + 11pt,
  bottom: 16mm,
  book: true,
  // clearance: 30pt,
  // flush-numbers: false,
  // numbering: (..i) => super(numbering("a", ..i)),
  // numbering: marginalia.note-numbering.with(repeat: false, markers: ())
  // numbering: marginalia.note-numbering.with(repeat: false)
)

#marginalia.configure(..config)

// testing html
// #show: everything => context {
//   if target() == "paged" {
#set page(
  ..marginalia.page-setup(..config),
  header-ascent: 16mm,
  header: context {
    // marginalia.notecounter.update(0)
    let book = marginalia._config.get().book
    let leftm = marginalia.get-left()
    let rightm = marginalia.get-right()
    if here().page() > 1 {
      wideblock(
        double: true,
        {
          box(
            width: leftm.width,
            {
              if not (book) or calc.odd(here().page()) [
                Page
                #counter(page).display("1 of 1", both: true)
              ] else [
                #datetime.today().display("[day]. [month repr:long] [year]")
              ]
            },
          )
          h(leftm.sep)
          box(width: 1fr, smallcaps[Marginalia])
          h(rightm.sep)
          box(
            width: rightm.width,
            {
              if not (book) or calc.odd(here().page()) [
                #datetime.today().display("[day]. [month repr:long] [year]")
              ] else [
                Page
                #counter(page).display("1 of 1", both: true)
              ]
            },
          )
        },
      )
    }
  },
  background: context {
    let leftm = marginalia.get-left()
    let rightm = marginalia.get-right()
    place(
      top,
      dy: marginalia._config.get().top,
      line(length: 100%, stroke: 0.5pt + luma(90%)),
    )
    place(
      top,
      dy: marginalia._config.get().top - page.header-ascent,
      line(length: 100%, stroke: 0.5pt + luma(90%)),
    )
    place(
      bottom,
      dy: -marginalia._config.get().bottom,
      line(length: 100%, stroke: 0.5pt + luma(90%)),
    )
    place(
      dx: leftm.far,
      rect(
        width: leftm.width,
        height: 100%,
        stroke: (x: 0.5pt + luma(90%)),
        inset: 0pt,
        {
          // place(
          //   top,
          //   dy: marginalia._config.get().top,
          //   line(length: 100%, stroke: luma(90%)),
          // )
        },
      ),
    )
    place(
      dx: leftm.far + leftm.width + leftm.sep,
      rect(width: 10pt, height: 100%, stroke: (left: 0.5pt + luma(90%))),
    )
    place(
      right,
      dx: -rightm.far,
      rect(width: rightm.width, height: 100%, stroke: (x: 0.5pt + luma(90%))),
    )
    place(
      right,
      dx: -rightm.far - rightm.width - rightm.sep,
      rect(width: 10pt, height: 100%, stroke: (right: 0.5pt + luma(90%))),
    )
  },
)
//     everything
//   } else {
//     everything
//   }
// }

#show heading.where(level: 1): set block(above: 36pt, below: 12pt)

#set par(justify: true, linebreaks: "optimized")
#set text(fill: luma(30), size: 10pt)
#show raw: set text(font: ("IBM Plex Mono", "DejaVu Sans Mono"))
#show link: underline

#let codeblock(code) = {
  wideblock(
    reverse: true,
    {
      // #set text(size: 0.84em)
      block(stroke: 0.5pt + luma(90%), fill: white, width: 100%, inset: (y: 5pt), code)
    },
  )
}

#v(16mm)
#block(
  text(size: 3em, weight: "black")[
    Marginalia
    #text(size: 10pt)[#note(numbered: false)[
        #outline(indent: 1em, depth: 2)
      ]]],
)
_Write into the margins!_
#v(1em)

#show heading.where(level: 1): set heading(numbering: "1.1")
#show heading.where(level: 2): set heading(numbering: "1.1")

= Setup
Put something akin to the following at the start of your `.typ` file:
#codeblock[
  ```typst
  #import "@preview/marginalia:0.1.4" as marginalia: note, wideblock
  #let config = (
    // inner: ( far: 5mm, width: 15mm, sep: 5mm ),
    // outer: ( far: 5mm, width: 15mm, sep: 5mm ),
    // top: 2.5cm,
    // bottom: 2.5cm,
    // book: false,
    // clearance: 12pt,
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
]

Where you can then customize `config` to your preferences. Shown here (as comments) are the default values taken if the corresponding keys are unset.

See the appendix for a more detailed explanation of the #link(label("marginalia-configure()"), [```typc configure()```])
and #link(label("marginalia-page-setup()"), [```typc page-setup()```])
functions.


// // #context if calc.even(here().page()) {pagebreak(to: "odd", weak: true)}
// #pagebreak(to: "odd", weak: true)
// = Showcase
// (or all pages ```typst #if book = false```)

= Margin-Notes
By default, the #link(label("marginalia-note()"))[```typst #note[...]```] command places a note to the right/outer margin, like so:#note[
  This is a note.

  They can contain any content, and will wrap within the note column.
  // #note(dy: -1em)[Sometimes, they can even contain other notes! (But not always, and I don't know what gives.)]
].
By giving the argument ```typc reverse: true```, we obtain a note on the left/inner margin.#note(reverse: true)[Reversed.]
If ```typc config.book = true```, the side will of course be adjusted automatically.

If~#note[Note 1] we~#note[Note 2] place~#note[Note 3] multiple~#note[Note 4] notes~#note[Note 5] in~#note(dy:15pt)[This note was given ```typc 15pt``` dy, but it was shifted more than that to avoid Notes 1--5.] one~#note(reverse: true, dy:15pt)[This note was given ```typc 15pt``` dy.] line,#note(dy:10cm)[This note was given ```typc 10cm``` dy and was shifted less than that to stay on the page.] they automatically adjust their positions.
Additionally, a ```typc dy``` argument can be passed to shift their initial position by that amount vertically. They may still get shifted around, unless configured otherwise via the #link(label("marginalia-note.shift"))[```typc shift```] parameter of ```typ #note()```.

Notes will shift vertically to avoid other notes, wideblocks, and the top page margin.
It will attempt to move one note below a wide-block if there is not enough space above, but if there are multiple notes that would need to be rearranged you must assist by manually setting `dy` such that their initial position is below the wideblock.

// #text(fill: red)[TODO: OUTDATED]
// Currently, notes (and wideblocks) are not reordered,
// #note[This note lands below the previous one!]
// so two ```typ #note```s are placed in the same order vertically as they appear in the markup, even if the first is shifted with a `dy` such that the other would fit above it.

// #pagebreak(weak: true)
#columns(3)[
  Margin notes also work from within most containers such as blocks or ```typ #column()```s.#note(keep-order: true)[#lorem(4)]
  #colbreak()
  Blah blah.#note[Note from second column.]
  To force the notes to appear in the margin in the same order as they appear in the text, use
  #colbreak()
  ```typ #note(keep-order: true)[]```#note(keep-order: true)[Like so. The lorem-ipsum note was also placed with `keep-order`.]
  for _all_ notes whose relative order is important.
]

== Markers
The margin notes are decorated with little symbols, which by default hang into the gap. If this is not desired, set the configuration option ```typc flush-numbers: true```.
#marginalia.configure(flush-numbers: true)
#note[
  This note is sandwiched between two calls to
  ```typc configure()```.// toggling `flush-numbers`.
]
#marginalia.configure(flush-numbers: false)

Setting the argument ```typc numbered: false```,#note[Unnumbered notes ```typc "avoid"``` being shifted if possible, preferring to shift other notes up.]
we obtain notes without icon/number:#note(numbered: false)[Like this.]

To change the markers, you can override ```typc config.numbering```-function which is used to generate the markers.

== Styling
Both #link(label("marginalia-note()"))[```typc note()```] and #link(label("marginalia-notefigure()"))[```typc notefigure()```]
accept a `text-style` and `par-style` parameter:
- ```typc text-style: (size: 5pt, font: ("Iosevka Extended"))``` gives~#note(reverse: true, text-style: (size: 5pt, font: ("Iosevka Extended")))[#lorem(5)]
- ```typc par-style: (spacing: 20pt, leading: -2pt)``` gives~#note(reverse: true, par-style: (spacing: 20pt, leading: -2pt))[
    #lorem(4)

    #lorem(4)
  ]

The default options here are meant to be as close as possible to the stock footnote style.

#let note-with-separator = marginalia.note.with(
  block-style: (
    stroke: (top: (thickness: 0.5pt, dash: "dotted")),
    outset: (top: 6pt /* clearance is 12pt */),
    width: 100%,
  ),
)
#let note-with-wide-background = marginalia.note.with(
  block-style: (fill: oklch(90%, 0.06, 140deg), outset: (left: 10pt, rest: 4pt), width: 100%, radius: 4pt),
)
#let note-with-background = marginalia.note.with(
  block-style: (fill: oklch(90%, 0.06, 140deg), inset: (x: 4pt), outset: (y: 4pt), width: 100%, radius: 4pt),
)
To style the block containing the note body, use the `block-style` argument.

- ```typc block-style: (stroke: (top: (thickness: 0.5pt, dash: "dotted")), outset: (top: 6pt /* clearance is 12pt */), width: 100%)``` gives:
  #note-with-separator(keep-order: true)[This is a note with a dotted stroke above.]
  #note-with-separator(numbered: false, keep-order: true, shift: true)[So is this.]
- ```typc block-style: (fill: oklch(90%, 0.06, 140deg), outset: (left: 10pt, rest: 4pt), width: 100%, radius: 4pt)``` gives:
  #marginalia.configure(flush-numbers: true)
  #note-with-background(keep-order: true)[This is a note with a green background and `flush-numbers: true`.]
  #note-with-background(numbered: false, keep-order: true, shift: true)[So is this.]
  #marginalia.configure(flush-numbers: false)

- ```typc block-style: (fill: oklch(90%, 0.06, 140deg), inset: (x: 4pt), outset: (y: 4pt), width: 100%, radius: 4pt)``` gives:
  #note-with-wide-background(keep-order: true)[This is a note with a wide green background.]
  #note-with-wide-background(numbered: false, keep-order: true, shift: true)[So is this.]


// #codeblock(```typ
// #let note-with-wide-background = marginalia.note.with(
//     block-style: (fill: oklch(90.26%, 0.058, 140.43deg), outset: (left: 10pt, rest: 4pt), width: 100%, radius: 4pt)
//   )
// #let note-with-background = marginalia.note.with(
//     block-style: (fill: oklch(90.26%, 0.058, 140.43deg), inset: (x: 4pt), outset: (y: 4pt), width: 100%, radius: 4pt)
//   )
// ```)

//
// #text(fill: red)[TODO: OUTDATED]
// It is recommended to reset the `notecounter` regularly, either per page:
// #block[
//   #set text(size: 0.84em)
//   ```typ
//   #set page(header: { marginalia.notecounter.update(0) })
//   ```
// ]
// or per heading:
// #block[
//   #set text(size: 0.84em)
//   ```typ
//   #show heading.where(level: 1): it =>
//     { marginalia.notecounter.update(0); it }
//   ```
// ]
//
// #note(shift: "ignore")[
//   Vertical offsets in this document:
//   Right:\
//   #context marginalia._note_extends_right.get().at("1") \
//   #context marginalia._note_extends_right.final().at("1") \
//   #context marginalia._note_offset_right("1") \
//   #context marginalia._note_offset_right("2") \
//   #context marginalia._note_offset_right("3") \
//   #context marginalia._note_offset_right("4") \
//   #context marginalia._note_offset_right("5") \
//   #context marginalia._note_offset_right("6") \
//   #context marginalia._note_offset_right("7") \
//   #context marginalia._note_offset_right("8")

//   Left:\
//   #context marginalia._note_offset_left("1") \
//   #context marginalia._note_offset_left("2") \
//   #context marginalia._note_offset_left("3") \
//   #context marginalia._note_offset_left("4") \
//   #context marginalia._note_offset_left("5") \
//   #context marginalia._note_offset_left("6") \
//   #context marginalia._note_offset_left("7") \
//   #context marginalia._note_offset_left("8")
// ]

= Wide Blocks
#wideblock[
  The command
  ```typst #wideblock[...]```
  can be used to wrap content in a wide block which spans into the margin-note-column.

  Note: when using an asyymetric page layout with `book: true`, wideblocks which span across pagebreaks are messy, because there is no way for the wideblock to detect the pagebreak and adjust ist position after it.

  It is possible to use notes in a wide block:#note[Voila.]#note(reverse: true)[Wow!].
  They will automatically shift downwards to avoid colliding with the wideblock.
  #note(dy: -8em)[Unless they are given a `dy` argument moving them above the block.]
]

#wideblock(reverse: true)[
  ```typst #wideblock(reverse: true)[...]```: The `reverse` option makes the block extend to the inside margin instead.
  This is analogous to the `reverse` option on notes and allows placing notes in their usual column.

  In this manual, a reverse wideblock is used to set the appendix to make it take up fewer pages.
  This is also why the appendix is no longer using `book: true`.
  #note[Notes above a `wideblock` will shift upwards if necessary.]
]

#wideblock(double: true)[
  ```typst #wideblock(double: true)[...]```: The `double` option makes it extend both ways.
  Note that setting both `reverse: true` and `double: true` is disallowed and will panic.
]

// #pagebreak(weak: true)
= Figures

== Notefigures
For small figures, you can place them in the margin with ```typc marginalia.notefigure```.
#marginalia.notefigure(
  rect(width: 100%, height: 15pt, fill: gradient.linear(..color.map.mako)),
  caption: [A notefigure.],
)
It accepts all arguments `figure` takes (except `placement` and `scope`), plus all arguments `note` takes (except `align-baseline`). However, by default it has no marker, and to get a marker like other notes, you must pass ```typc numbered: true```, it will get a marker like other notes:
#marginalia.notefigure(
  rect(width: 100%, height: 15pt, fill: gradient.linear(..color.map.turbo)),
  numbered: true,
  label: <markedfigure>,
  caption: [A marked notefigure.],
)

Additionally, the `dy` argument now takes a relative length, where ```typc 100%``` is the distance between the top of the figure content and the first baseline of the caption.
//height of the figure content + gap, but without the caption.
By default, figures have a `dy` of ```typc 0pt - 100%```, which results in the caption being aligned horizontally to the text.
#marginalia.notefigure(
  dy: 0pt,
  rect(width: 100%, height: 15pt, fill: gradient.linear(..color.map.crest)),
  numbered: true,
  caption: [Aligned to top of figure with `dy: 0pt`.],
)

A label can be attached to the figure using the `label` argument.// C.f.~@markedfigure.

== Large Figures
For larger figures, use the following set and show rules:
#codeblock[
  ```typ
  #set figure(gap: 0pt)
  #set figure.caption(position: top)
  #show figure.caption.where(position: top): note.with(numbered:false, dy:1em)
  ```
]

#set figure(gap: 0pt)
#set figure.caption(position: top)
#show figure.caption.where(position: top): note.with(numbered: false, dy: 1em)

#figure(
  rect(width: 100%, fill: gradient.linear(..color.map.inferno)),
  caption: [A figure.],
)

For wide figures, simply place a figure in a wideblock.
The caption gets placed beneath the figure automatically, courtesy of regular wide-block-avoidance.
#codeblock[
  ```typ
  #wideblock(figure(image(..), caption: [A figure in a wide block.]))
  ```
]
// #pagebreak(weak: true)
#wideblock[
  #figure(
    rect(width: 100%, fill: gradient.linear(..color.map.cividis)),
    caption: [A figure in a wide block.],
  )
]
#wideblock(reverse: true)[
  #figure(
    rect(width: 100%, height: 5em, fill: gradient.linear(..color.map.icefire)),
    caption: [A figure in a reversed wide block.],
  )
]
#wideblock(double: true)[
  #figure(
    rect(width: 100%, fill: gradient.linear(..color.map.spectral)),
    caption: [A figure in a double-wide block.],
  )
]

= Other Tidbits
== Absolute Placement
You can place notes in absolute positions relative to the page using `place`:
#codeblock[
  ```typ
  #place(top, note(numbered: false, reverse: true)[Top])
  #place(bottom, note(numbered: false, reverse: true)[Bottom])
  ```
]
#place(top, note(numbered: false, reverse: true)[Top])
#place(bottom, note(numbered: false, reverse: true)[Bottom])

To avoid these notes moving about, use `shift: false` (or `shift: "ignore"` if you don't mind overlaps.)
#codeblock[
  // #set text(size: 0.84em)
  ```typ
  #place(top, note(numbered: false, shift: false)[Top (no shift)])
  #place(bottom, note(numbered: false, shift: false)[Bottom (no shift)])
  ```
]
#place(top, note(numbered: false, shift: false)[Top (no shift)])
#place(bottom, note(numbered: false, shift: false)[Bottom (no shift)])

By default, notes are aligned to their first baseline.
To align the top of the note instead, set #link(label("marginalia-note.align-baseline"))[```typc align-baseline```] to ```typc false```.
#place(top, note(numbered: false, shift: false, align-baseline: false)[Top (no shift, no baseline align)])
#place(bottom, note(numbered: false, shift: false, align-baseline: false)[Bottom (no shift, no baseline al.)])

== Headers and Background
This is not (yet) a polished feature and requires to access ```typc marginalia._config.get().book``` to read the respective config option.
In your documents, consider removing this check and simplifying the ```typc if``` a bit.
#note[Also, please don't ```typc .update()``` the `marginalia._config` directly, this can easily break the notes.]


Here's how the headers in this document were made:
#codeblock[
  // #set text(size: 0.84em)
  ```typst
  #set page(header: context {
    marginalia.notecounter.update(0)
    let book = marginalia._config.get().book
    let leftm = marginalia.get-left()
    let rightm = marginalia.get-right()
    if here().page() > 1 {
      wideblock(double: true, {
        box(width: leftm.width, {
          if not (book) or calc.odd(here().page()) [
            Page
            #counter(page).display("1 of 1", both: true)
          ] else [
            #datetime.today().display(/**/)
          ]
        })
        h(leftm.sep)
        box(width: 1fr, smallcaps[Marginalia])
        h(rightm.sep)
        box(width: rightm.width, {
          if not (book) or calc.odd(here().page()) [
            #datetime.today().display(/**/)
          ] else [
            Page
            #counter(page).display("1 of 1", both: true)
          ]
        })
      })
    }
  })
  ```
]

And here's the code for the lines in the background:
#note[
  Not that you should copy them, they're mostly here to showcase the columns and help me verify that everything gets placed in the right spot.
]
#codeblock[
  // #set text(size: 0.84em)
  ```typst
  #set page(background: context {
    let leftm = marginalia.get-left()
    let rightm = marginalia.get-right()
    place(top, dy: marginalia._config.get().top,
          line(length: 100%, stroke: luma(90%)))
    place(top, dy: marginalia._config.get().top - page.header-ascent,
          line(length: 100%, stroke: luma(90%)))
    place(bottom, dy: -marginalia._config.get().bottom,
          line(length: 100%, stroke: luma(90%)))
    place(dx: leftm.far,
          rect(width: leftm.width, height: 100%, stroke: (x: luma(90%))))
    place(dx: leftm.far + leftm.width + leftm.sep,
          rect(width: 10pt, height: 100%, stroke: (left: luma(90%))))
    place(right, dx: -rightm.far,
          rect(width: rightm.width, height: 100%, stroke: (x: luma(90%))))
    place(right, dx: -rightm.far - rightm.width - rightm.sep,
          rect(width: 10pt, height: 100%, stroke: (right: luma(90%))))
  })
  ```
]

// #pagebreak(weak: true)
= Troubleshooting / Known Bugs

- If the document needs multiple passes to figure out page-breaks,
  #note[This can happen for example with outlines which barely fit/don't fit onto the page.]
  it can break the note positioning.
  - This can usually be resolved by placing a ```typ #pagebreak()``` or ```typ #pagebreak(weak: true)``` in an appropriate location.

- Nested notes may or may not work.
  #note[
    In this manual, for example, it works fine (with warnings) here,
    #note[Probably because there aren't many other notes around.]
    but not on the first page.
    #note(reverse: true)[Notes on the other side are usually fine though.]
  ]
  In nearly all cases, they seem to lead to a "layout did not converge within 5 attempts" warning, so it is probably best to avoid them if possible.
  - Just use multiple paragraphs in one note, or place multiple notes in the main text instead.
  - If really neccessary, use `shift: "ignore"` on the nested notes and manually set `dy`.

- `notefigure`s ignore `flush-numbers: true`, because it is not easily possible for this package to insert the marker _into_ the caption#note[Which is a block-level element] without a newline.

- If `book` is `true`, wideblocks that break across pages are broken. Sadly there doesn't seem to be a way to detect and react to page-breaks from within a `block`, so I don't know how to fix this.

- If you encounter anything else which looks like a bug to you, please #link("https://github.com/nleanba/typst-marginalia/issues")[create an "issue" on GitHub] if no-one else has done so already.

= Thanks
Many thanks go to Nathan Jessurun for their #link("https://typst.app/universe/package/drafting")[drafting] package,
which has served as a starting point and was very helpful in figuring out how to position margin-notes.
// Also check out #link("https://typst.app/universe/package/marge/")[marge] by Eric Biedert which helped motivate me to polish this package to not look bad in comparison.

The `wideblock` functionality was inspired by the one provided in the #link("https://typst.app/universe/package/tufte-memo")[tufte-memo] template.

Also shout-out to #link("https://typst.app/universe/package/tidy")[tidy], which was used to produce the appendix.


// testing html
// #context { if target() == "paged" [

// no more book-style to allow for multipage wideblock
#marginalia.configure(..config, book: false)
#set page(..marginalia.page-setup(..config, book: false))
#context counter(heading).update(0)
#show heading.where(level: 1): set heading(numbering: "A.1", supplement: "Appendix")
#show heading.where(level: 2): set heading(numbering: "A.1", supplement: "Appendix", outlined: false)

#wideblock(reverse: true)[
  = Detailed Documentation of all Exported Symbols
  <appendix>

  #import "@preview/tidy:0.4.2"
  #import "tidy-style.typ" as style
  #let docs = tidy.parse-module(
    read("lib.typ"),
    name: "marginalia",
    // preamble: "notecounter.update(1);",
    scope: (
      notecounter: marginalia.notecounter,
      note-numbering: marginalia.note-numbering,
      note-markers: marginalia.note-markers,
      note-markers-alternating: marginalia.note-markers-alternating,
      marginalia: marginalia,
      internal: (..text) => {
        let text = text.pos().at(0, default: [Internal.])
        note(numbered: false, text)
        h(0pt, weak: true)
        // set text(fill: white, weight: 600, size: 9pt)
        // block(fill: luma(40%), inset: 2pt, outset: 2pt, radius: 2pt, body)
      },
    ),
  )

  #tidy.show-module(
    docs,
    // sort-functions: false,
    style: style,
    first-heading-level: 1,
    // show-outline: false,
    omit-private-definitions: true,
    // omit-private-parameters: false,
    show-module-name: false,
    // break-param-descriptions: true,
    // omit-empty-param-descriptions: false,
  )
]
