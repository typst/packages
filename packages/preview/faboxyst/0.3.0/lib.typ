// ===========================================================================
//  faboxyst — coloured boxes for Typst, in the spirit of tcolorbox.
//
//    #import "@preview/faboxyst:0.3.0": *
//    #show: faboxyst.with(theme: themes.notebook)
//
//    #fabox(title: [Note])[A titled box.]
//    #tip[A semantic tip.]
//    #khatambox(title: [تمرين], badge: [1])[An ornate plate.]
//    #flagbox(title: [Note])[A title hanging from a rod.]
//
//  0.3.0 adds the antique vintage effect (engraved strokes, drawn with nibart):
//    #show: faboxyst.with(theme: themes.antique)
//    #show: planche.with(number: [Plate I], title: [...])
//    #cadre-grave[An engraved double rule around this text.]
//
//  Typst 0.15.x · uses the fonts installed on the system.
// ===========================================================================

#import "src/theme.typ": *
#import "src/postit.typ": postit, study-postit
#import "src/postit-butterfly.typ": postit-butterfly
#import "src/garnet-box.typ": garnet-box
#import "src/numbered-header-box.typ": numbered-header-box
#import "src/folded-banner.typ": folded-banner
#import "src/abstract-textbox.typ": abstract-textbox
#import "src/alternating-block-process.typ": alternating-block-process
#import "src/alternating-line-block-process.typ": alternating-line-block-process
#import "src/infostacks.typ": ring-linked-boxes, wire-linked-pills, brush-stroke-rows, twisted-ribbon-rows, bubble-tail-boxes, striped-poster-cards, pencil-frame-flow, index-notebook, film-strip, chevron-slideshow-frame
#import "src/sketchframes.typ": vintage-frame, charcoal-frame, crayon-frame, pencil-sketch-frame
#import "src/infocards.typ": puzzle-tab-cards, folded-tab-cards, half-disc-tab-cards, u-backed-cards, circle-head-outline-cards, dashed-pill-cards, skewed-badge-cards, badge-timeline-cards
#import "src/banners-with-circles.typ": banners-with-circles
#import "src/calendar-list.typ": calendar-list
#import "src/capsule-text-boxes.typ": capsule-text-boxes
#import "src/cards-with-corner-sleeve.typ": cards-with-corner-sleeve
#import "src/connected-cards-process.typ": connected-cards-process
#import "src/cornered-cards.typ": cornered-cards
#import "src/cube-block-list.typ": cube-block-list
#import "src/double-duo-neumorphic.typ": double-duo-neumorphic
#import "src/three-step-highlight-cards.typ": three-step-highlight-cards
#import "src/hand-drawn-speech-bubbles.typ": hand-drawn-speech-bubbles
#import "src/four-feature-icon-cards.typ": four-feature-icon-cards
#import "src/six-step-numbered-card-list.typ": six-step-numbered-card-list
#import "src/concentric-tier-cards.typ": concentric-tier-cards
#import "src/l-shaped-header-box.typ": l-shaped-header-box
#import "src/text-box-tags.typ": text-box-tag
#import "src/frame-accent-block.typ": frame-accent-block
#import "src/tabbed-folder-box.typ": tabbed-folder-box
#import "src/perspective-text-box.typ": perspective-text-box
#import "src/peak-header-box.typ": peak-header-box
#import "src/pocket-card-box.typ": pocket-card-box
#import "src/folder-step-box.typ": folder-step-box
#import "src/folder-text-block.typ": folder-text-block
#import "src/folder-text-box.typ": folder-text-box
#import "src/four-step-parchment-process.typ": four-step-parchment-process
#import "src/vertical-banner-box.typ": vertical-banner-box
#import "src/half-framed-text-box.typ": half-framed-text-box
#import "src/hexagonal-header-box.typ": hexagonal-header-box
#import "src/horizontal-bubble-box.typ": horizontal-bubble-box
#import "src/horizontal-chevron-block.typ": horizontal-chevron-block
#import "src/kinds-text-box-1.typ": kinds-text-box-1
#import "src/kinds-text-box-2.typ": kinds-text-box-2
#import "src/kinds-text-box-3.typ": kinds-text-box-3
#import "src/three-color-infographic-card.typ": three-color-infographic-card, three-color-infographic-stack
#import "src/vertical-chevron-list-item.typ": vertical-chevron-list-item
#import "src/modern-block-list-box.typ": modern-block-list-box
#import "src/nested-file-text-box.typ": nested-file-text-box
#import "src/information-block-box.typ": information-block-box
#import "src/simple-rounded-text-box.typ": simple-rounded-text-box
#import "src/two-column-information-card.typ": two-column-information-card
#import "src/card-list-box.typ": card-list-box
#import "src/staggered-hanging-card-box.typ": staggered-hanging-card-box
#import "src/diagonal-banner-card-box.typ": diagonal-banner-card-box
#import "src/rounded-tab-card-box.typ": rounded-tab-card-box
#import "src/side-banner-card-box.typ": side-banner-card-box
#import "src/top-banner-card-box.typ": top-banner-card-box
#import "src/text-box-process-box.typ": text-box-process-box
#import "src/continuous-block-process-box.typ": continuous-block-process-box
#import "src/corner-ribbon-process-box.typ": corner-ribbon-process-box
#import "src/serpentine-process-box.typ": serpentine-process-box
#import "src/stacked-summary-card-box.typ": stacked-summary-card-box
#import "src/stacked-banner-row.typ": stacked-banner-row
#import "src/looped-chevron-callout.typ": looped-chevron-callout
#import "src/text-box-display-card.typ": text-box-display-card
#import "src/quad-step-card.typ": quad-step-card
#import "src/paper-note-box.typ": paper-note-box
#import "src/interlocked-abstract-textbox.typ": interlocked-abstract-textbox
#import "src/perspective-panels.typ": perspective-panels
#import "src/folded-banner-info-box.typ": folded-banner-info-box
#import "src/folding-card-box.typ": folding-card-box
#import "src/feature-callout-box.typ": feature-callout-box
#import "src/wavy-infographic-box.typ": wavy-infographic-box
#import "src/neumorphic-diamond-box.typ": neumorphic-diamond-box
#import "src/neumorphic-text-panel.typ": neumorphic-text-panel
#import "src/six-boxes-template-box.typ": six-boxes-template-box
#import "src/six-boxes-outline-box.typ": six-boxes-outline-box
#import "src/six-boxes-tilted-box.typ": six-boxes-tilted-box
#import "src/six-boxes-folder-card.typ": six-boxes-folder-card
#import "src/six-boxes-banded-box.typ": six-boxes-banded-box
#import "src/six-boxes-pointer-card.typ": six-boxes-pointer-card
#import "src/postage-stamp-card.typ": postage-stamp-card
#import "src/hand-drawn-bullet-panel.typ": hand-drawn-bullet-panel
#import "src/hand-drawn-business-callout.typ": hand-drawn-business-callout
#import "src/hand-drawn-folded-ribbon.typ": hand-drawn-folded-ribbon
#import "src/hand-drawn-photo-frame.typ": hand-drawn-photo-frame
#import "src/hand-drawn-business-brochure-card.typ": hand-drawn-business-brochure-card
#import "src/pencil-sketch-box.typ": pencil-sketch-box
#import "src/pencil-sketch-ellipse.typ": pencil-sketch-ellipse
#import "src/pencil-sketch-graphite-box.typ": pencil-sketch-graphite-box
#import "src/taped-curl-note.typ": taped-curl-note
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
#import "src/lace.typ": lace
#import "src/lacebox.typ": lacebox
#import "src/pgfornament.typ": pgfornament
#import "src/ringbox.typ": ringbox
#import "src/punchbox.typ": punchbox
#import "src/plannerbox.typ": plannerbox
#import "src/filebox.typ": filebox
#import "src/stubbox.typ": stubbox
#import "src/stackbox.typ": stackbox
#import "src/calloutbox.typ": calloutbox
#import "src/tapebox.typ": tapebox
#import "src/boardbox.typ": boardbox, chalkbox, markerbox, bb-colours
#import "src/plankbox.typ": plankbox, pancarte, plank-colours
#import "src/tornpage.typ": tornpage, page-dechiree
#import "src/coilbox.typ": coilbox, cahier, coil-colours
#import "src/gelbox.typ": gelbox, bouton
#import "src/engine.typ": relief, insetbox, boite-creusee
#import "src/ogeebox.typ": ogeebox, banniere, frisebox, frise, medallion, rosette, girih, ogee-colours
#import "src/volutebox.typ": volutebox, cadre-volute, volute-colours, flourish, spiral-pts, ink-pts
#import "src/parchemin.typ": parchemin, lettre, scroll-colours
#import "src/fills.typ": halftone, trame, tikzpattern, motif-tikz
#import "src/vintage.typ": vintageframe, cadre-vintage, vintagebox, plaque-vintage
#import "src/antique.typ": (
  antique-palette, antique-fonts,
  nib-pen, nib-stroke, nib-polylines, nib-line-path, nib-rect-path, polyline-path,
  nib-envelope, nib-curve, vintage-pts, vintage-outline,
  engraved, engraved-rule, engraved-frame,
  plate-page, patent-page, figure-caption,
  antique-label, antique-notes, antique-note,
)
#import "src/programme.typ": (
  leconbox, lecon, lecon-reset, lecon-counter, prog-colours,
  pinbox, epingle, brushbox, pinceau, matierebox, cartouche,
  arc-pts, poly-pts, round-poly,
)
#import "src/meter.typ": meter, difficulty, pictochrono
#import "src/pictos.typ": (
  tkzpicto, competence-crayon, level-counter,
  niveaudiffexos, pictocible, pictoskills, bicolor-title, bicolor-bignum,
  banner-tri, banner-tri-bis, highway-sign, sale-poster,
  tcbwhiteboard, tcboxnotebook, smooth-pts,
)
#import "src/rosette.typ": (
  rosettebox, cadre-rosette,
  rosette-ink, rosette-gold, rosette-leaf,
)
#import "src/cover.typ": book-cover
#import "src/screwbox.typ": screwbox
#import "src/sashbox.typ": sashbox, ruban
#import "src/notebook.typ": notebook-box, notebook-box-clean
#import "src/fancy.typ": (
  sloppy-box, post-it, vignette, spread-box,
  ticket, folder, terminal, neon, polaroid,
  mark, hl, mark-emph, MARKS,
  highlight-formula, highlight-text, surligner-formule, surligner-texte,
  flag-ribbon, speed-bar, banner-3d,
  spiral-binding, bound-page,
)
#let ticketbox = ticket

// ---------------------------------------------------------------------------
//  the antique vintage effect — French aliases
// ---------------------------------------------------------------------------

#let planche = plate-page
#let brevet = patent-page
#let legende-figure = figure-caption
#let regle-gravee = engraved-rule
#let cadre-grave = engraved-frame
#let etiquette-gravee = antique-label
#import "src/scrapbook.typ": (
  sb-colours, sb-heart, sb-tape, sb-pin, sb-clip, sb-inks,
  torn-note, ruled-sheet, stamp-card, grid-note, index-card,
  deckle-tag, notepad, lesson-card, lesson-table,
  sb-underline, sb-divider,
  highlight as felt,
)
#import "src/ornament.typ": (
  motifs, ornament, ornament-palette, default-palette, make-palette,
  glyph-motif, content-motif, image-motif, tint, turned,
)
#import "src/ornate.typ": (
  ornatebox, khatambox, zellijbox, arabesquebox, mihrabbox, mosaicbox,
  fleuronbox, khatam-badge, sash-shape,
)
#import "src/flagbox.typ": flagbox
#import "src/watermark.typ": with-watermark, paint-watermark
#import "src/bubble.typ": speech-bubble, joined-bubbles, five-w

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
  let base = if theme == "print" { themes.print }
    else if theme == "normal" { default-theme }
    else if type(theme) == dictionary and "palette" in theme { theme }
    else { default-theme + theme }
  // Fill any newly-added theme fields (notably `mode`) when users pass an
  // older or partial theme dictionary.
  let th = default-theme + base + over.named()
  // `roughness` given by the user (partial dictionary or named argument): the
  // boxes whose `rough:` is `auto` turn hand-drawn.
  let user-roughness = ("roughness" in over.named()) or (type(theme) == dictionary and "palette" not in theme and "roughness" in theme)
  let th = if user-roughness { th + (roughness-set: true) } else { th }
  theme-state.update(th)
  set text(lang: th.lang, dir: th.dir)
  if th.mode == "print" { set text(fill: black) }
  body
}

/// Apply Blockst-compatible print styling to only one group of boxes.
/// The previous theme is restored immediately after the group.
///
/// ```typ
/// #print-group[
///   #numbered-header-box(title: [Étape], number: 1)[Texte.]
/// ]
/// ```
#let print-group(body) = context {
  let previous = theme-state.get()
  theme-state.update(themes.print)
  set text(fill: black)
  body
  theme-state.update(previous)
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
///
///   stroke-colour    colour of the first frame (default: the theme gold)
///   stroke-colour-2  colour of the second frame (default: same as the first)
#let double-frame(
  body,
  stroke-colour: auto,
  stroke-colour-2: auto,
  weight: 3pt,
  pass-offset: 0.09,
  ..a,
) = context {
  let th = theme-state.get()
  sketch-box(body,
    shape: "rect",
    stroke-colour: if stroke-colour == auto { th.palette.gold } else { stroke-colour },
    pass-colour: stroke-colour-2,
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

// ---------------------------------------------------------------------------
//  explicit re-exports — every public component, star or not
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
//  re-exports — names imported above are otherwise private to this
//  file; the alias bindings make every public component importable
// ---------------------------------------------------------------------------

#let MARKS = MARKS
#let antique-fonts = antique-fonts
#let antique-label = antique-label
#let antique-note = antique-note
#let antique-notes = antique-notes
#let antique-palette = antique-palette
#let arabesquebox = arabesquebox
#let arc-pts = arc-pts
#let banner-3d = banner-3d
#let banner-tri = banner-tri
#let banner-tri-bis = banner-tri-bis
#let banniere = banniere
#let bb-colours = bb-colours
#let bicolor-bignum = bicolor-bignum
#let bicolor-title = bicolor-title
#let boardbox = boardbox
#let boite-creusee = boite-creusee
#let book-cover = book-cover
#let bound-page = bound-page
#let bouton = bouton
#let brushbox = brushbox
#let cadre-rosette = cadre-rosette
#let cadre-vintage = cadre-vintage
#let cadre-volute = cadre-volute
#let cahier = cahier
#let calloutbox = calloutbox
#let cartouche = cartouche
#let chalkbox = chalkbox
#let circuitbox = circuitbox
#let coil-colours = coil-colours
#let coilbox = coilbox
#let competence-crayon = competence-crayon
#let concept-card = concept-card
#let content-motif = content-motif
#let crestbox = crestbox
#let deckle-tag = deckle-tag
#let def-card = def-card
#let default-palette = default-palette
#let difficulty = difficulty
#let engraved = engraved
#let engraved-frame = engraved-frame
#let engraved-rule = engraved-rule
#let epingle = epingle
#let example-header = example-header
#let fabox = fabox
#let fabox-note = fabox-note
#let fabox-sign = fabox-sign
#let felt = felt
#let figure-caption = figure-caption
#let filebox = filebox
#let five-w = five-w
#let flag-ribbon = flag-ribbon
#let flagbox = flagbox
#let fleuronbox = fleuronbox
#let flourish = flourish
#let folder = folder
#let folder-step-box = folder-step-box
#let folder-text-block = folder-text-block
#let folder-text-box = folder-text-box
#let four-step-parchment-process = four-step-parchment-process
#let frise = frise
#let frisebox = frisebox
#let gelbox = gelbox
#let girih = girih
#let glyph-motif = glyph-motif
#let grid-note = grid-note
#let halftone = halftone
#let helixbox = helixbox
#let highlight = highlight
#let highlight-formula = highlight-formula
#let highlight-text = highlight-text
#let highway-sign = highway-sign
#let hl = hl
#let ico-bulb = ico-bulb
#let ico-pencil = ico-pencil
#let ico-star = ico-star
#let iconbox = iconbox
#let image-motif = image-motif
#let index-card = index-card
#let ink-pts = ink-pts
#let insetbox = insetbox
#let is-rtl = is-rtl
#let joined-bubbles = joined-bubbles
#let keybox = keybox
#let khatam-badge = khatam-badge
#let khatambox = khatambox
#let lace = lace
#let lacebox = lacebox
#let lecon = lecon
#let lecon-counter = lecon-counter
#let lecon-reset = lecon-reset
#let leconbox = leconbox
#let lesson-card = lesson-card
#let lesson-table = lesson-table
#let lettre = lettre
#let level-counter = level-counter
#let make-palette = make-palette
#let mark = mark
#let mark-emph = mark-emph
#let markerbox = markerbox
#let matierebox = matierebox
#let medallion = medallion
#let meter = meter
#let mihrabbox = mihrabbox
#let mosaicbox = mosaicbox
#let motif-tikz = motif-tikz
#let motifs = motifs
#let neon = neon
#let nib-line-path = nib-line-path
#let nib-pen = nib-pen
#let nib-polylines = nib-polylines
#let nib-rect-path = nib-rect-path
#let nib-stroke = nib-stroke
#let niveaudiffexos = niveaudiffexos
#let notebook-box = notebook-box
#let notebook-box-clean = notebook-box-clean
#let notepad = notepad
#let numbox = numbox
#let numbox-counter = numbox-counter
#let numbox-reset = numbox-reset
#let ogee-colours = ogee-colours
#let ogeebox = ogeebox
#let ornament = ornament
#let ornament-palette = ornament-palette
#let ornatebox = ornatebox
#let page-dechiree = page-dechiree
#let paint-watermark = paint-watermark
#let pancarte = pancarte
#let parchemin = parchemin
#let patent-page = patent-page
#let pgfornament = pgfornament
#let pictochrono = pictochrono
#let pictocible = pictocible
#let pictoskills = pictoskills
#let pinbox = pinbox
#let pinceau = pinceau
#let plank-colours = plank-colours
#let plankbox = plankbox
#let plannerbox = plannerbox
#let plaque-vintage = plaque-vintage
#let plate = plate
#let plate-page = plate-page
#let polaroid = polaroid
#let poly-pts = poly-pts
#let polyline-path = polyline-path
#let post-it = post-it
#let prog-colours = prog-colours
#let punchbox = punchbox
#let relief = relief
#let ribbonbox = ribbonbox
#let ringbox = ringbox
#let rosette = rosette
#let rosette-gold = rosette-gold
#let rosette-ink = rosette-ink
#let rosette-leaf = rosette-leaf
#let rosettebox = rosettebox
#let round-poly = round-poly
#let ruban = ruban
#let ruled-sheet = ruled-sheet
#let sale-poster = sale-poster
#let sash-shape = sash-shape
#let sashbox = sashbox
#let sb-clip = sb-clip
#let sb-colours = sb-colours
#let sb-divider = sb-divider
#let sb-heart = sb-heart
#let sb-inks = sb-inks
#let sb-pin = sb-pin
#let sb-tape = sb-tape
#let sb-underline = sb-underline
#let screwbox = screwbox
#let scroll-colours = scroll-colours
#let sketch-box = sketch-box
#let sloppy-box = sloppy-box
#let smooth-pts = smooth-pts
#let speech-bubble = speech-bubble
#let speed-bar = speed-bar
#let spiral-binding = spiral-binding
#let spiral-pts = spiral-pts
#let spread-box = spread-box
#let stackbox = stackbox
#let stamp-card = stamp-card
#let sticky = sticky
#let stubbox = stubbox
#let surligner-formule = surligner-formule
#let surligner-texte = surligner-texte
#let swooshbox = swooshbox
#let tapebox = tapebox
#let tcboxnotebook = tcboxnotebook
#let tcbwhiteboard = tcbwhiteboard
#let terminal = terminal
#let ticket = ticket
#let tikzpattern = tikzpattern
#let tint = tint
#let tip-card = tip-card
#let tkzpicto = tkzpicto
#let torn-note = torn-note
#let tornpage = tornpage
#let trame = trame
#let turned = turned
#let vertical-banner-box = vertical-banner-box
#let half-framed-text-box = half-framed-text-box
#let hexagonal-header-box = hexagonal-header-box
#let horizontal-bubble-box = horizontal-bubble-box
#let modern-block-list-box = modern-block-list-box
#let nested-file-text-box = nested-file-text-box
#let information-block-box = information-block-box
#let simple-rounded-text-box = simple-rounded-text-box
#let two-column-information-card = two-column-information-card
#let card-list-box = card-list-box
#let staggered-hanging-card-box = staggered-hanging-card-box
#let diagonal-banner-card-box = diagonal-banner-card-box
#let rounded-tab-card-box = rounded-tab-card-box
#let side-banner-card-box = side-banner-card-box
#let top-banner-card-box = top-banner-card-box
#let vignette = vignette
#let vintagebox = vintagebox
#let vintageframe = vintageframe
#let volute-colours = volute-colours
#let volutebox = volutebox
#let with-watermark = with-watermark
#let zellijbox = zellijbox
#let nib-envelope = nib-envelope
#let nib-curve = nib-curve
#let vintage-pts = vintage-pts
#let vintage-outline = vintage-outline
