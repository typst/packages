// ─── CUSTOM ENVIRONMENTS ──────────────────────────────────────────────────────
// These are called from the document body, so they read the active theme from
// shared state (installed by `thesis(..)`) rather than receiving it as an
// argument.
#import "theme.typ": theme-state

#let rho-box(title: none, body) = context {
  let th = theme-state.get()
  box(
    fill: th.accent-bg,
    radius: 2pt,
    inset: (x: 6pt, y: 5pt),
    width: 100%,
    {
      if title != none {
        text(fill: th.accent, weight: "bold", font: th.font-sans, title)
        v(4pt)
      }
      set text(fill: th.accent, size: 9pt)
      body
    },
  )
}

#let note-block(body, title: none) = {
  if title != none {
    rho-box(title: title, body)
  } else {
    rho-box(body)
  }
}
