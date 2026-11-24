// examples/handout.typ — the `print` theme and the pacing clock.
//
// Two things a deck needs once it leaves the projector: colours that do not
// cost a toner cartridge, and some way of telling whether you are running
// late. Compile and print this one double-sided.
#import "@preview/chalkdeck:0.1.0": *

#show: chalkdeck.with(
  theme: "print",              // white paper, no backdrop, ink-frugal colours
  ratio: "a4",                 // a real sheet, landscape
  clock: 20,                   // a 20-minute talk; a plain number is minutes
  title: [Printing a deck],
  subtitle: [the `print` theme and the pacing clock],
  author: [chalkdeck],
  date: [2026],
)

#slide(title: [Why a separate theme])[
  #slide-list(
    [The board themes flood the page with a dark field: fine on a
      projector, ruinous on a printer.],
    [`print` has no backdrop, black on white, and colours dark enough to
      survive a monochrome laser.],
    [Nothing else changes — the same `slide` and `slide-block`.],
  )
]

#slide(title: [The clock in the corner])[
  #slide-block(kind: [What it is])[
    The time you should be *at* on reaching this slide. Glance at the
    corner, glance at your watch: ahead or behind.
  ]

  #slide-block(kind: [Or a real one], colour: rgb("#A81E14"))[
    Typst cannot write a form field, but the PDF can carry one. Pass
    `clock: (live: true)` and run `tools/pdfclock.py` for powerdot's
    actual ticking clock.
  ]
]

#slide(title: [Spelling it])[
  ```typ
  #show: chalkdeck.with(clock: 20)                       // minutes
  #show: chalkdeck.with(clock: duration(minutes: 45))    // or a duration
  #show: chalkdeck.with(clock: (total: 45, mode: "remaining"))
  #show: chalkdeck.with(clock: (n, total) => [#n of #total])
  #slide(clock: none)[ .. ]        // and off for one slide
  ```

  `mode:` is `"elapsed"` (default), `"remaining"` or `"both"`.
]

#slide(title: [A really ticking clock])[
  #slide-list(
    [`clock: (live: true)` leaves an invisible marker in the corner.],
    [`python3 tools/pdfclock.py deck.pdf` covers each marker with a
      read-only PDF form field and attaches `app.setInterval` — the same
      mechanism powerdot uses.],
    [It ticks in Acrobat and is inert elsewhere, exactly like powerdot's.],
  )

  ```sh
  python3 tools/pdfclock.py deck.pdf -o deck-live.pdf
  python3 tools/pdfclock.py deck.pdf --countdown 45   # time REMAINING
  ```
]

#slide(title: [Turned off here], clock: none)[
  This slide passed `clock: none`, so the corner is empty: a title slide or
  a full-bleed figure should not have to carry the furniture.
]

#slide(title: [Counting down], clock: (total: 20, mode: "remaining"))[
  And this one overrides the mode, so the corner shows what is *left*
  rather than what has gone.
]
