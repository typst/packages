// Page furniture of content slides: the title bar in the page header and
// the footer with slide number and progress bar.

#import "@preview/touying:0.8.0": components, touying-notes, utils
#import "design.typ": *
#import "options.typ": counting-symbols
#import "logo.typ": bar-logo, bar-logo-width

/// Show rule for coloured backgrounds (title bar, focus slide): inline code
/// keeps the code font but drops the light code box and takes the
/// surrounding text colour.
#let plain-inline-code(self, body) = {
  show raw.where(block: false): it => text(
    font: self.store.code-font,
    size: .85em,
    it.text,
  )
  body
}

/// The author field as content: Touying also accepts an array of authors.
#let author-text(author) = if type(author) == array {
  author.join(", ")
} else { author }

#let _bar-min-height(self) = self.store.font-size * bar-height-factor
#let _bar-inset-y(self) = self.store.font-size * .4

// The slide heading shown in the bar, or `none`. Needs context.
#let _bar-heading(self) = {
  let it = utils.current-heading(depth: self.slide-level)
  if it != none { it.body }
}

// The title bar at its natural height and its text size. Needs context.
#let _bar-layout(self) = {
  let body = _bar-heading(self)
  // Space on the right: the margin, or the logo panel plus a gap.
  let logo-width = bar-logo-width(self, _bar-min-height(self))
  let right = if logo-width > 0pt { logo-width + self.store.font-size * .8 } else {
    page-margin-x
  }
  let available = page.width - page-margin-x - right
  let full-size = self.store.font-size * bar-text-factor
  let natural = measure(text(size: full-size, weight: "bold", body)).width
  let ratio = if natural <= available { 1 } else {
    calc.max(bar-min-text-ratio, available / natural)
  }
  let content = {
    set par(leading: .35em)
    show: plain-inline-code.with(self)
    text(size: full-size * ratio, weight: "bold", fill: white, body)
  }
  let inner = block(
    width: page.width,
    inset: (left: page-margin-x, right: right, y: _bar-inset-y(self)),
    content,
  )
  let height = calc.max(_bar-min-height(self), measure(inner).height)
  (inner: inner, height: height)
}

/// Page header of content slides: a full-width Monash blue bar holding the
/// current slide heading. A heading that is too wide first shrinks (down to
/// 75%) and then wraps; the bar grows to fit.
#let title-bar(self) = context {
  let bar = _bar-layout(self)
  place(top + left, block(
    width: 100%,
    height: bar.height,
    fill: monash-blue,
    {
      bar-logo(self, bar.height, _bar-min-height(self))
      align(horizon, bar.inner)
    },
  ))
}

/// Top margin of content slides: room for a one-line title bar plus a gap.
#let content-margin-top(self) = (
  _bar-min-height(self) + self.store.font-size * bar-gap-factor
)

/// Flow spacing that keeps the body below a title bar taller than one line.
#let title-bar-spacer(self) = context {
  let extra = _bar-layout(self).height - _bar-min-height(self)
  if extra > 0pt { v(extra) }
}

// A pattern with one counting symbol shows the current slide only; with two
// it receives (current, total).

/// The formatted slide number. In the appendix only the current number is
/// shown, because the total counts main slides only. Needs no context.
#let slide-number(self) = context {
  let pattern = self.store.slide-numbering
  let current = utils.slide-counter.get().first()
  let total = utils.last-slide-counter.final().first()
  let appendix = self.at("appendix", default: false)
  if type(pattern) == function {
    pattern(current, total)
  } else if appendix or pattern.matches(counting-symbols).len() < 2 {
    numbering(pattern, current)
  } else {
    numbering(pattern, current, total)
  }
}

/// Bottom margin of content slides, which holds the footer.
#let content-margin-bottom(self) = self.store.font-size * footer-height-factor

#let _footer-text(self) = {
  let footer = self.store.footer
  if footer == auto {
    let info = self.info
    let title = if info.short-title != auto { info.short-title } else { info.title }
    let parts = (title, author-text(info.author)).filter(it => it not in (none, [], ()))
    parts.join[#h(.6em)#sym.dot.c#h(.6em)]
  } else {
    footer
  }
}

/// Footer of content slides: optional text on the left, the slide number on
/// the right, and the progress bar along the bottom edge.
#let footer(self) = {
  let line = block(
    width: 100%,
    inset: (x: page-margin-x),
    grid(
      columns: (1fr, auto),
      column-gutter: self.store.font-size,
      align: (left + bottom, right + bottom),
      // Long footer text shrinks to stay on one line above the progress bar.
      utils.fit-to-width(
        grow: false,
        100%,
        text(size: .6em, fill: monash-dark-grey, _footer-text(self)),
      ),
      // monash-dark-grey on white has a contrast ratio of 5.9:1.
      if self.store.slide-numbering != none {
        text(size: .6em, fill: monash-dark-grey, slide-number(self))
      },
    ),
  )
  let bar = if self.store.progress-bar {
    components.progress-bar(
      height: progress-height,
      self.store.accent-color,
      monash-grey-soft,
    )
  }
  block(width: 100%, height: 100%, {
    place(horizon + left, line)
    place(bottom + left, bar)
  })
}

/// Speaker-note panel in theme colours, registered as Touying's `notes-fn`.
#let notes(self: none, ..args) = touying-notes(
  self: self,
  header: self => pad(x: 32pt, y: 16pt, text(
    fill: white,
    weight: "bold",
    utils.display-current-heading(depth: self.slide-level),
  )),
  header-fill: monash-blue,
  fill: monash-blue-wash,
  ..args,
)
