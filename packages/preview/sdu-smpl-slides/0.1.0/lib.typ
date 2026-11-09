#import "@preview/touying:0.8.0": *
#import "@preview/touying:0.8.0" as touyingpkg
#import "@preview/codly:2.0.0" as codly
#import "@preview/codly-languages:0.1.10": *
#import "@preview/gentle-clues:1.3.1": *
#import "@preview/lovelace:0.3.1": *
#import "@preview/pinit:0.2.2": *
#import "@preview/cuti:0.4.0": show-cn-fakebold, show-cn-fakeitalic

#let sdu-content-top-gap = 1.0em
#let sdu-equation-lines-per-page = 5
#let sdu-equation-row-gap = 2.25em
#let sdu-equation-body-gap = 1.75em

// A row holding nothing but math spacing renders as an invisible line that
// still consumes a full row gap. `$ a \ b \ $` — a trailing `\` before the
// closing delimiter — is the common source of one.
#let _sdu-space-func = [ ].func()

#let _sdu-row-is-blank(row) = row.all(child => child.func() == _sdu-space-func)

// Typst lays out a multiline block equation as one unbreakable object. On a
// slide, a tall equation can therefore run past the page and lose its trailing
// lines. Split only top-level math line breaks into grid rows so the equation
// can continue on the next page. The first explicit alignment point (`&`) is
// respected; when it is omitted, the first `=` on each row is used instead.
#let _sdu-equation-rows(body) = {
  let children = if body.has("children") { body.children } else { (body,) }
  let rows = ()
  let row = ()

  for child in children {
    if child.func() == linebreak {
      rows.push(row)
      row = ()
    } else {
      row.push(child)
    }
  }
  rows.push(row)

  // Drop the blank rows a stray leading or trailing `\` introduces, but keep
  // interior ones: those are the author asking for vertical space.
  while rows.len() > 0 and _sdu-row-is-blank(rows.first()) {
    rows = rows.slice(1)
  }
  while rows.len() > 0 and _sdu-row-is-blank(rows.last()) {
    rows = rows.slice(0, -1)
  }
  rows
}

// LaTeX's `\thickmuskip`, the space a relation normally gets on either side.
// Splitting a row at the relation drops the space that preceded it — the left
// half's trailing space is trimmed at the column edge — so it has to be put
// back explicitly, inside the fitted equation so it scales with the row.
#let sdu-equation-relation-space = 0.278em

// `math.align-point` is not exported, so derive the element function from a
// throwaway `$&$` instead of matching on `repr()`. A repr comparison would keep
// compiling but silently stop aligning anything if Typst ever reformats it.
#let _sdu-align-point-func = $&$.body.func()

// Split a row into the cells that share an alignment axis. Every `&` starts a
// new cell, so `a &= b &= c` aligns on both relations the way LaTeX's `align`
// does; earlier only the first `&` was honoured and the rest vanished. Rows
// without any `&` fall back to their first `=`.
#let _sdu-equation-cells(row) = {
  let points = row
    .enumerate()
    .filter(((index, child)) => child.func() == _sdu-align-point-func)
    .map(((index, child)) => index)

  if points.len() > 0 {
    let cells = ()
    let start = 0
    for point in points {
      cells.push(row.slice(start, point))
      start = point + 1
    }
    cells.push(row.slice(start))
    return cells
  }

  let equality = row.position(child => child.has("text") and child.text == "=")
  if equality != none {
    (row.slice(0, equality), row.slice(equality))
  } else {
    none
  }
}

#let _sdu-row-equation(children) = math.equation(
  block: false,
  // A split row is technically inline content, so explicitly restore the
  // display style used by a normal `$ ... $` block equation.
  math.display(children.sum(default: none)),
)

// Preserve the normal display-math size whenever the row fits. Only shrink a
// row when its natural width would otherwise run outside the slide.
#let _sdu-fit-equation(body) = touyingpkg.utils.fit-to-width(
  grow: false,
  100%,
  body,
)

// Splitting an equation into rows replaces the original element, so Typst no
// longer paints its number even though the equation counter has already been
// stepped and `@refs` to it still resolve. Reproduce the number by hand so the
// printed tag and the reference agree.
#let _sdu-equation-number(equation) = {
  if equation.numbering == none {
    return none
  }
  context numbering(equation.numbering, ..counter(math.equation).get())
}

#let _sdu-display-equation(equation) = {
  let rows = _sdu-equation-rows(equation.body)

  // `<= 1` rather than `== 1`: trimming blank rows can empty the list, and an
  // equation made only of line breaks still has to render as itself.
  if rows.len() <= 1 {
    align(center, _sdu-fit-equation(equation))
  } else {
    let number = _sdu-equation-number(equation)
    let parsed = rows.map(row => {
      let cells = _sdu-equation-cells(row)
      if cells == none {
        (body: row, cells: none)
      } else {
        (
          body: row,
          // Every cell after the first opens with the relation it aligns on, so
          // it needs the space that the split removed.
          cells: cells
            .enumerate()
            .map(((index, cell)) => if index == 0 {
              cell
            } else {
              (h(sdu-equation-relation-space),) + cell
            }),
        )
      }
    })
    let aligned-rows = parsed.filter(row => row.cells != none)
    let column-count = calc.max(2, ..aligned-rows.map(row => row.cells.len()))

    let chunks = ()
    let chunk = ()
    for row in parsed {
      chunk.push(row)
      if chunk.len() == sdu-equation-lines-per-page {
        chunks.push(chunk)
        chunk = ()
      }
    }
    if chunk.len() > 0 { chunks.push(chunk) }

    // Each small chunk is indivisible, so Typst either keeps it in the
    // remaining slide area or moves the complete chunk below the next page's
    // header. Longer derivations are split at deterministic row boundaries.
    for (chunk-index, chunk) in chunks.enumerate() {
      block(
        width: 100%,
        breakable: false,
        // Put the gap inside the indivisible block. An `above` gap can be
        // discarded at the top of a page, which lets tall fractions and
        // brackets collide with the header rule.
        above: 0pt,
        below: 0pt,
        {
          v(sdu-equation-body-gap)
          for (row-index, row) in chunk.enumerate() {
            let is-last-row = chunk-index == chunks.len() - 1 and row-index == chunk.len() - 1
            block(
              width: 100%,
              breakable: false,
              below: if row-index == chunk.len() - 1 { 0pt } else { sdu-equation-row-gap },
              {
                // The tag rides along with the closing row, matching where
                // Typst puts it for an unsplit block equation.
                if is-last-row and number != none {
                  place(right + horizon, number)
                }
                if row.cells == none or aligned-rows.len() == 1 {
                  // Nothing to align against — with a single aligned row there
                  // is no second axis either — so keep the expression as one
                  // unit. This gives a long RHS the full slide width and scales
                  // both sides by exactly the same amount.
                  align(center, _sdu-fit-equation(_sdu-row-equation(row.body)))
                } else {
                  grid(
                    // Keep one shared alignment axis while leaving enough room
                    // for the usually longer right-hand side of derivations.
                    // Extra `&` columns are sized to their content so a third
                    // alignment point sits next to the second, not half a slide
                    // away; the last column still absorbs the remaining width.
                    columns: (40%,) + (auto,) * (column-count - 2) + (1fr,),
                    column-gutter: 0pt,
                    // Horizontal alignment only: `horizon` would collapse the
                    // row height for fractions, products, and large sums.
                    ..row
                      .cells
                      .enumerate()
                      .map(((index, cell)) => align(
                        if index == 0 { right } else { left },
                        _sdu-fit-equation(_sdu-row-equation(cell)),
                      )),
                  )
                }
              },
            )
          }
          if chunk-index == chunks.len() - 1 {
            v(sdu-equation-body-gap)
          }
        },
      )
    }
  }
}

#let _get-last-heading-label(current-headings) = {
  if current-headings != () and current-headings.at(-1).has("label") {
    str(current-headings.at(-1).label)
  }
}

#let _display-page-heading(self) = {
  let last-heading-label = _get-last-heading-label(self.headings)
  touyingpkg.utils.display-current-heading(
    // A hidden heading means the title comes from one level up, but `depth: 0`
    // matches nothing and would leave the header blank on a `slide-level: 1`
    // deck, so never go below the top level.
    depth: if last-heading-label == "touying:hidden" {
      calc.max(1, self.slide-level - 1)
    } else {
      self.slide-level
    },
    style: none,
  )
}

// Typst turns ordered-list items separated by other block content into
// independent lists, so each fragment normally starts at 1. Give top-level
// items explicit numbers that carry across the interruption, restarting at
// every heading. Nested items remain local to their parent list, and an
// explicitly numbered item is preserved.
//
// The restart point used to be second-level headings only, which meant decks
// built from `=` headings alone — or lists sitting under a `===` — never got
// continued numbering at all.
#let _sdu-continue-enums(body) = {
  let children = if touyingpkg.utils.tree.is-sequence(body) { body.children } else { (body,) }
  let in-section = false
  let next-number = 1
  let result = ()

  for child in children {
    if type(child) == content and child.func() == heading {
      in-section = true
      next-number = 1
    }

    if in-section and type(child) == content and child.func() == enum.item {
      let fields = child.fields()
      let item-number = fields.at("number", default: auto)
      let number = if item-number == auto { next-number } else { item-number }
      let label = fields.at("label", default: none)
      child = enum.item(number, child.body)
      if label != none {
        child = touyingpkg.utils.tree.label-it(child, label)
      }
      next-number = number + 1
    }

    result.push(child)
  }

  result.sum(default: none)
}

// Keep backgrounds in config-page: nested page rules create blank trailing
// pages with Touying 0.8's slide layout anchor.
#let sdu-footer-height = 0.95cm

// Full-width bar along the bottom of every slide: author | title | page.
#let _sdu-footer-bar(self) = {
  let info = self.info
  let footer-right = self.store.at(
    "footer-right",
    default: context str(touyingpkg.utils.slide-counter.get().first() + 1) + " / " + touyingpkg.utils.last-slide-number,
  )
  let title = if info.at("short-title", default: auto) not in (auto, none) { info.short-title } else { info.title }
  block(
    width: 100%,
    height: sdu-footer-height,
    fill: self.colors.primary,
    inset: (x: 0.55cm),
    {
      set text(size: 11pt, weight: "bold", fill: self.colors.neutral-lightest)
      set par(justify: false)
      grid(
        columns: (1fr, 2fr, 1fr),
        align: (left + horizon, center + horizon, right + horizon),
        rows: 100%,
        if info.author != none { info.author },
        if title != none { title },
        touyingpkg.utils.call-or-display(self, footer-right),
      )
    },
  )
}

#let _sdu-background(self) = {
  let width = if self.show-notes-on-second-screen == right { 50% } else { 100% }
  place(left + bottom, block(width: width, self.store.background))
  place(left + bottom, block(width: width, _sdu-footer-bar(self)))
}

#let sdu-header(self) = {
  set align(top)
  grid(
    inset: (top: 0.85em, x: 1.7em),
    rows: (auto, auto),
    row-gutter: -0.25em,
    grid(
      columns: (1fr, auto),
      column-gutter: 1.2em,
      align(left + horizon, text(
        size: 1.18em,
        weight: "bold",
        fill: self.colors.neutral-darkest,
        _display-page-heading(self),
      )),
      align(right + horizon, box(height: 2.52cm, self.store.logo)),
    ),
    align(left, line(length: 100%, stroke: (paint: self.colors.primary, thickness: 1.05pt))),
  )
}

#let sdu-footer(self) = none

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = touyingpkg.utils.merge-dicts(
    self,
    config-page(background: _sdu-background(self), header: sdu-header, footer: sdu-footer, margin: (top: 4.4em, bottom: 1.6cm, left: 1.72cm, right: 1.45cm)),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: body => {
      // Keep the slide body in the normal page flow. A wrapping `pad` loses
      // the page's top margin when it fragments, causing continuation content
      // to overlap the header and footer.
      v(sdu-content-top-gap)
      setting(body)
    },
    composer: composer,
    ..bodies,
  )
})

#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  // `args` only feeds `info`, so a positional argument would be dropped without
  // a word. Touying's own `config-*` helpers assert the same way.
  assert(args.pos().len() == 0, message: "title-slide takes no positional arguments")
  self = touyingpkg.utils.merge-dicts(
    self,
    config-common(),
    config-page(background: _sdu-background(self), margin: (top: 0.8cm, bottom: 1.3cm, x: 1.6cm)),
  )
  let info = self.info + args.named()
  let body = {
    set align(center + horizon)
    block(width: 100%, height: 100%, {
      v(1fr)
      block(
        width: 88%,
        inset: (x: 1.2cm, y: 0.7cm),
        fill: self.colors.primary,
        radius: 8pt,
        {
          set par(justify: false, leading: 0.6em)
          text(size: 1.9em, fill: self.colors.neutral-lightest, info.title)
          if info.subtitle != none {
            v(0.2em)
            text(size: 1.15em, fill: self.colors.neutral-lightest, info.subtitle)
          }
        },
      )
      v(0.8fr)
      set text(size: 1.1em, fill: self.colors.neutral-darkest)
      if info.author != none {
        block(spacing: 0.5em, info.author)
      }
      if extra != none {
        block(spacing: 0.5em, extra)
      }
      if info.institution != none {
        block(above: 1.1em, text(size: 0.85em, info.institution))
      }
      if info.date != none {
        block(above: 1.1em, touyingpkg.utils.display-info-date(self))
      }
      v(0.8fr)
      box(height: 3.2cm, self.store.logo)
      v(0.6fr)
    })
  }
  // Forward `config` the way the other slide helpers do, instead of folding it
  // into `self` here and dropping it on the floor.
  touying-slide(self: self, config: config, body)
})

// Lists only first-level headings, each behind a numbered red disc.
#let outline-slide(config: (:), title: none, ..args) = touying-slide-wrapper(self => {
  assert(args.pos().len() == 0, message: "outline-slide takes no positional arguments")
  self = touyingpkg.utils.merge-dicts(
    self,
    config-common(),
    config-page(background: _sdu-background(self), margin: (top: 1.4cm, bottom: 1.6cm, left: 2.2cm, right: 1.45cm)),
  )
  let marker(n) = box(
    circle(radius: 0.62em, fill: self.colors.primary, inset: 0pt, align(center + horizon, text(
      size: 0.8em,
      top-edge: "bounds",
      bottom-edge: "bounds",
      fill: self.colors.neutral-lightest,
      str(n),
    ))),
  )
  let body = {
    set align(left + horizon)
    if title != none {
      text(size: 1.4em, weight: "bold", fill: self.colors.primary, title)
      v(1em)
    }
    context {
      let sections = query(heading.where(level: 1)).filter(h => not (
        h.has("label") and str(h.label).starts-with("touying:")
      ))
      set text(size: 1.4em, fill: self.colors.primary)
      show link: set text(fill: self.colors.primary)
      for (i, sec) in sections.enumerate() {
        block(above: 1.1em, below: 1.1em, link(sec.location(), grid(
          columns: (auto, auto),
          column-gutter: 0.8em,
          align: left + horizon,
          marker(i + 1), sec.body,
        )))
      }
    }
  }
  touying-slide(self: self, config: config, body)
})

// The section slide is a title-only divider, so it deliberately ignores the
// positional body touying hands to it. `receive-body-for-new-section-slide-fn`
// is disabled in the theme, which makes touying emit the content that follows a
// first-level heading as an ordinary slide instead of passing it here — without
// that config, everything written before the first `==` would be dropped.
#let new-section-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = touyingpkg.utils.merge-dicts(
    self,
    config-page(background: _sdu-background(self), margin: (top: 1.1cm, bottom: 1.1cm, x: 1.6cm)),
  )
  let layout = {
    set align(left + horizon)
    block(width: 100%, height: 100%, {
      v(0.95fr)
      text(size: 1.45em, weight: "bold", fill: self.colors.neutral-darkest, _display-page-heading(self))
      v(0.28cm)
      line(length: 100%, stroke: (paint: self.colors.primary, thickness: 2pt))
      v(1fr)
    })
  }
  touying-slide(self: self, config: config, layout)
})

// Accepts the closing content either positionally (`#end-slide[...]`, matching
// how the other slide helpers read) or as `body:`.
#let end-slide(config: (:), body: auto, ..args) = touying-slide-wrapper(self => {
  assert(args.pos().len() <= 1, message: "end-slide takes at most one positional argument")
  assert(args.named().len() == 0, message: "end-slide got unexpected named arguments: " + repr(args.named()))
  let body = args.pos().at(0, default: body)
  self = touyingpkg.utils.merge-dicts(
    self,
    config-common(new-section-slide-fn: none),
    config-page(background: _sdu-background(self), margin: (top: 1.4cm, bottom: 1.4cm, x: 1.6cm)),
  )
  let final-body = if body == auto {
    [
      #set align(center + horizon)
      #set text(fill: self.colors.primary)
      #text(size: 2.8em, weight: "bold")[感谢聆听]
      #linebreak()
      #v(0.25em)
      #text(font: ("XCharter", "Charter"), size: 1.85em, box[Thanks for Listening])
    ]
  } else {
    body
  }
  let layout = {
    block(width: 100%, align(center + horizon, final-body))
  }
  touying-slide(self: self, config: config, align(center + horizon, layout))
})

#let sdu-theme(
  aspect-ratio: "16-9",
  font: (
    "XCharter",
    "Charter",
    "Songti SC",
    "FandolSong",
  ),
  mono-font: ("Maple Mono", "Menlo", "DejaVu Sans Mono"),
  footer-right: context str(touyingpkg.utils.slide-counter.get().first() + 1) + " / " + touyingpkg.utils.last-slide-number,
  primary: rgb("#8C1D1D"),
  logo: image("image/sdu_logo.svg", height: 100%),
  background: image("image/sdu_bg.png", width: 100%),
  ..args,
  body,
) = {
  set text(size: 18pt)
  set par(justify: true, leading: 1.2em)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 4.1em, bottom: 2.1em, x: 1.45cm),
      header-ascent: 1.2em,
      footer-descent: 0em,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      // `new-section-slide` is a title-only divider. Letting it receive the body
      // would silently swallow every block written between a `=` heading and the
      // first `==` below it; with this off, touying turns that content into a
      // regular slide of its own.
      receive-body-for-new-section-slide-fn: false,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: font)
        show raw: set text(font: mono-font)
        show: codly.set_(gutters: ())
        show: codly.lang-set_(languages: codly-languages)
        show: codly.line-set_(fill: luma(245))
        show: show-cn-fakebold
        show: show-cn-fakeitalic
        show heading: set text(self.colors.primary)
        // External links use a typewriter face; citations retain the body face.
        show link: set text(fill: rgb("#50658A"))
        show link: it => {
          if type(it.dest) == str {
            text(font: mono-font, it)
          } else {
            it
          }
        }
        set bibliography(style: "apa")
        show cite: set text(fill: rgb("#50658A"), font: font)
        set list(marker: text(fill: self.colors.primary)[•])
        show enum: set text(top-edge: "bounds", bottom-edge: "bounds")
        set enum(number-align: right + horizon, numbering: n => move(dy: -0.12em, box(
          circle(
            radius: 0.48em,
            inset: 0pt,
            fill: self.colors.primary,
            align(center + horizon, text(
              size: 0.68em,
              top-edge: "bounds",
              bottom-edge: "bounds",
              fill: self.colors.neutral-lightest,
              str(n),
            )),
          ),
        )))
        show raw.where(block: false): code => box(
          fill: rgb("#eff1f3"),
          inset: (x: 0.35em, y: 0.15em),
          radius: 0.2em,
          text(size: 0.85em, fill: rgb("#24292f"), code),
        )
        show math.equation.where(block: true): _sdu-display-equation
        // Three-line (booktabs-style) tables with a red caption label on top.
        set table(stroke: (_, y) => if y == 1 { (top: 0.6pt) } else { none }, align: left)
        show table: t => block(stroke: (y: 0.9pt), t)
        show figure.where(kind: table): set figure(gap: 0.9em)
        show figure.where(kind: table): set figure.caption(position: top)
        show figure.caption: it => {
          text(fill: self.colors.primary, it.supplement + [ ] + context it.counter.display(it.numbering) + it.separator)
          it.body
        }
        show raw.where(block: true): it => align(
          center,
          block(width: 90%, align(left, codly.new(it))),
        )
        body
      },
      alert: touyingpkg.utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-darkest: rgb("#1F1F1F"),
      neutral-dark: rgb("#555555"),
      neutral-light: rgb("#F6F4F2"),
      neutral-lightest: rgb("#FFFFFF"),
      primary: primary,
    ),
    config-store(
      footer-right: footer-right,
      logo: logo,
      background: background,
    ),
    ..args,
  )

  _sdu-continue-enums(body)
}
