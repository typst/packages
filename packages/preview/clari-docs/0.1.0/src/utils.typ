// ============================================================
// clari-slides — Utility Functions
// ============================================================

#import "state.typ": *

// ------------------------------------------------------------
// Text helpers
// ------------------------------------------------------------

/// Colors body text with the current primary color.
#let primary-text(body) = context text(fill: cs-primary.get())[#body]

/// Colors body text with the current accent color.
#let accent-text(body) = context text(fill: cs-accent.get())[#body]

/// Semibold + primary color — use to stress important terms.
#let stress(body) = context text(fill: cs-primary.get(), weight: "semibold")[#body]

// ------------------------------------------------------------
// Progress bar (bottom of slide)
// ------------------------------------------------------------

/// Renders a two-tone bottom progress bar.
/// The filled portion reflects completed slides.
#let _progress-bar(color: black, height: 3pt) = context {
  let current = counter(page).get().first()
  let total   = counter(page).final().first()
  let ratio   = if total == 0 { 0% } else { (current / total) * 100% }

  place(bottom + left, rect(width: 100%,  height: height, fill: color.lighten(75%)))
  place(bottom + left, rect(width: ratio, height: height, fill: color))
}

/// Returns the progress bar element if the global setting is on.
#let _get-progress-bar(color: none) = context {
  if cs-show-prog.get() {
    let c = if color != none { color } else { cs-primary.get() }
    _progress-bar(color: c, height: cs-prog-height.get())
  } else { none }
}

// ------------------------------------------------------------
// Progress divider (horizontal rule showing progress)
// ------------------------------------------------------------

/// A horizontal rule where the filled segment = current progress.
#let _progress-divider(color: none) = context {
  let c = if color != none { color } else { cs-primary.get() }
  let current = counter(page).get().first()
  let total   = counter(page).final().first()
  let ratio   = if total == 0 { 0% } else { (current / total) * 100% }

  stack(
    dir: ltr,
    rect(width: ratio,        height: 2.5pt, fill: c,               radius: 0pt),
    rect(width: 100% - ratio, height: 2.5pt, fill: c.lighten(60%),  radius: 0pt),
  )
}

/// A simple full-width solid rule (no progress).
#let _divider(color: none, thickness: 2.5pt) = context {
  let c = if color != none { color } else { cs-primary.get() }
  line(length: 100%, stroke: thickness + c)
}

// ------------------------------------------------------------
// Page number helper
// ------------------------------------------------------------

#let _page-number() = context {
  if cs-show-nums.get() {
    counter(page).display("1 / 1", both: true)
  } else { none }
}

// ------------------------------------------------------------
// Slide header bar
// ------------------------------------------------------------

/// Colored header bar containing the slide title and page number.
/// `outlined` = true inserts a metadata tag so the TOC picks it up.
#let _slide-header(title, outlined, color, page-num: none) = {
  let header-h = if title != none { 1.55cm } else { 0.9cm }

  rect(
    fill: color, width: 100%, height: header-h, inset: (x: 0.6cm, y: 0.4cm),
    if title != none {
      grid(
        columns: (1fr, auto),
        align: (left + horizon, right + horizon),
        if outlined {
          [#text(white, weight: "semibold", size: 22pt)[#h(.1cm)#title]
           #metadata(title) <cs-subsection>]
        } else {
          text(white, weight: "semibold", size: 22pt)[#h(.1cm)#title]
        },
        if page-num != none {
          text(white, weight: "semibold", size: 11pt)[#page-num]
        },
      )
    },
  )
}

// ------------------------------------------------------------
// Auto-resize text to fill available height (used by focus slide)
// ------------------------------------------------------------

#let _resize-text(body) = layout(size => {
  let sz = text.size
  let (height,) = measure(block(width: size.width, text(size: sz)[#body]))
  let max-h = size.height

  while height > max-h and sz > 4pt {
    sz -= 0.3pt
    height = measure(block(width: size.width, text(size: sz)[#body])).height
  }
  block(height: height, width: 100%, text(size: sz)[#body])
})

// ------------------------------------------------------------
// Common text style rules applied inside content slides
// ------------------------------------------------------------

#let _slide-text-rules() = {
  set list(marker: context text(cs-primary.get(), [•]))
  set enum(numbering: it => context text(fill: cs-primary.get())[*#it.*])
  set text(size: 20pt)
  set par(justify: true)
}

// ------------------------------------------------------------
// Section registration (for TOC)
// ------------------------------------------------------------

#let _register-section(name) = context {
  let pos = here().position()
  cs-sections.update(ss => { ss.push((body: name, loc: pos)); ss })
}
