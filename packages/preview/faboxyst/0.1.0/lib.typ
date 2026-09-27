// ===========================================================================
//  faboxyst — coloured boxes for Typst, in the spirit of tcolorbox.
//
//    #import "faboxyst/lib.typ": *
//    #show: faboxyst.with(theme: themes.notebook)
//
//    #fabox(title: [Note])[A titled box.]
//    #tip[A semantic tip.]
//
//  Typst 0.15.x · uses the fonts installed on the system.
// ===========================================================================

#import "src/theme.typ": *
#import "src/blocks.typ": sketch-box, highlight, def-card, sticky
#import "src/fabox.typ": fabox, fabox-sign, fabox-note, example-header, is-rtl
#import "src/numbox.typ": numbox, numbox-reset, numbox-counter
#import "src/iconbox.typ": iconbox, tip-card, concept-card, ico-star, ico-bulb, ico-pencil
#import "src/crestbox.typ": crestbox, plate
#import "src/ribbonbox.typ": ribbonbox
#import "src/helixbox.typ": helixbox
#import "src/swooshbox.typ": swooshbox
#import "src/circuitbox.typ": circuitbox
#import "src/keybox.typ": keybox
#import "src/ringbox.typ": ringbox
#import "src/punchbox.typ": punchbox
#import "src/plannerbox.typ": plannerbox
#import "src/filebox.typ": filebox
#import "src/stubbox.typ": stubbox
#import "src/stackbox.typ": stackbox
#import "src/calloutbox.typ": calloutbox
#import "src/tapebox.typ": tapebox
#import "src/boardbox.typ": boardbox, chalkbox, markerbox, bb-colours
#import "src/screwbox.typ": screwbox
#import "src/sashbox.typ": sashbox, ruban
#import "src/notebook.typ": notebook-box, notebook-box-clean
#import "src/fancy.typ": (
  sloppy-box, post-it, vignette, spread-box,
  ticket, folder, terminal, neon, polaroid,
  mark, hl, mark-emph, MARKS,
  flag-ribbon, speed-bar, banner-3d,
  spiral-binding, bound-page,
)
#let ticketbox = ticket
#import "src/scrapbook.typ": (
  sb-colours, sb-heart, sb-tape, sb-pin, sb-clip, sb-inks,
  torn-note, ruled-sheet, stamp-card, grid-note, index-card,
  deckle-tag, notepad, lesson-card, lesson-table,
  sb-underline, sb-divider,
  highlight as felt,
)

// ---------------------------------------------------------------------------
//  setup — apply a theme without taking over the page
// ---------------------------------------------------------------------------

/// Apply a theme (and optional text direction) to the rest of the document.
/// This is a *show* rule, not a document class: it does not set the page.
///
/// ```typ
/// #show: faboxyst.with(theme: themes.arabic)
/// #show: faboxyst.with(theme: (accent: red, roughness: 1.4))
/// ```
#let faboxyst(
  theme: default-theme,
  ..over,
  body,
) = {
  let th = if type(theme) == dictionary and "palette" in theme { theme } else {
    default-theme + theme
  }
  th = th + over.named()
  theme-state.update(th)
  set text(lang: th.lang, dir: th.dir)
  body
}

// ---------------------------------------------------------------------------
//  semantic boxes — sketch-box with opinionated defaults
// ---------------------------------------------------------------------------

/// A plain note in the theme accent.
#let note(body, ..a) = sketch-box(body, ..a)

/// A tip / info block (lime).
#let tip(body, colour: auto, ..a) = context sketch-box(body,
  stroke-colour: if colour == auto { theme-state.get().palette.lime } else { colour },
  ..a)

/// A warning block (red).
#let warning(body, colour: auto, ..a) = context sketch-box(body,
  stroke-colour: if colour == auto { theme-state.get().palette.red } else { colour },
  ..a)

/// A worked example, tinted.
#let example(body, colour: auto, ..a) = context {
  let p = theme-state.get().palette
  sketch-box(body,
    stroke-colour: if colour == auto { p.navy } else { colour },
    fill: if colour == auto { p.sky.lighten(55%) } else { colour.lighten(75%) },
    ..a)
}

/// A key definition: bold term + explanation (+ optional examples).
///
/// ```typ
/// #definition("INTEGERS")[Whole numbers.]
/// #definition("INTEGERS")[Whole numbers.][... −1, 0, 1 ...]
/// ```
#let definition(term, ..a) = {
  let pos = a.pos()
  let named = a.named()
  let body = if pos.len() > 0 { pos.at(0) } else { [] }
  if pos.len() > 1 and "examples" not in named {
    named.insert("examples", pos.at(1))
  }
  def-card(term, body, ..named)
}

/// A starburst callout.
#let burst(body, ..a) = sketch-box(body, shape: "burst", ..a)

/// An extruded flat-3D block.
#let block3d(body, depth: 0.30, ..a) = sketch-box(body, depth: depth,
  shape: "rect", ..a)

/// Hatched block: emphasis without a fill colour.
#let hatched(body, angle: 45, spacing: 0.16, ..a) = sketch-box(body,
  hatch: (angle: angle, spacing: spacing), ..a)

/// A block with a soft drop shadow.
#let shadowed(body, shadow: luma(220), ..a) = sketch-box(body,
  shadow: shadow, ..a)

/// A filled plaque with curling corners.
#let plaque(
  body,
  title: none,
  fill: auto,
  stroke-colour: auto,
  text-fill: auto,
  curl: 0.42,
  title-size: 1.5em,
  ..a,
) = context {
  let th = theme-state.get()
  let f = if fill == auto { th.palette.lime } else { fill }
  let sc = if stroke-colour == auto { th.ink } else { stroke-colour }
  sketch-box(
    shape: "plaque", curl: curl, fill: f, stroke-colour: sc,
    stroke-weight: 2.2pt, text-fill: text-fill, pad: 12pt,
    ..a,
    align(center)[
      #if title != none {
        text(font: th.fonts.heading, weight: heading-weight(th.dir),
          size: title-size, tracking: 1pt, title)
        v(0.35em, weak: true)
      }
      #body
    ],
  )
}

/// A frame drawn twice, as if gone over by hand.
#let double-frame(
  body,
  stroke-colour: auto,
  weight: 3pt,
  pass-offset: 0.09,
  ..a,
) = context {
  let th = theme-state.get()
  sketch-box(body,
    shape: "rect",
    stroke-colour: if stroke-colour == auto { th.palette.gold } else { stroke-colour },
    stroke-weight: weight,
    passes: 2, pass-offset: pass-offset,
    roughness: 0.5, radius: 0.05, pad: 14pt,
    ..a)
}

/// A filled stadium / pill.
#let pill-box(body, fill: auto, stroke-colour: auto, ..a) = context {
  let th = theme-state.get()
  sketch-box(body,
    shape: "stadium",
    fill: if fill == auto { th.palette.sky } else { fill },
    stroke-colour: if stroke-colour == auto { th.ink } else { stroke-colour },
    stroke-weight: 2pt,
    pad: 13pt,
    ..a)
}
