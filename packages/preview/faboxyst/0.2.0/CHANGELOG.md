# Changelog

## 0.2.0 — 2026-09-15 (update 2 — submission)

Two reference sheets become vector components: the annual-programme plate
and a pair of vintage frame sheets (one SVG, one EPS).

- **`leconbox` / `lecon`, `pinbox` / `epingle`, `brushbox` / `pinceau`,
  `matierebox` / `cartouche`** (`src/programme.typ`) — the four boxes of the
  annual-programme plate (السنة الأولى — البرنامج السنوي): the numbered
  lesson bar (grey gradient tag with pointed tail, coloured chevron that
  continues into a bottom underline, comma-shaped number badge, automatic
  two-digit numbering through `lecon-counter`, accent/badge pairs cycling
  through `prog-colours`, mirrored in LTR); the teal map-pin badge (thin
  ring, thick crescent, pointed tail, raised white disc); the dry
  watercolour brush-stroke banner; and the subject-and-year ribbon (teal
  gradient pill with dark fold, halftone end panel with a slanted edge).
  `examples/programme.typ` rebuilds the whole sheet, header included.
- **`vintageframe` / `cadre-vintage`** (`src/vintage.typ`) — the eight
  line-art label frames of the scrollwork SVG sheet, as `style:`
  "volutes", "curls", "loops", "petals", "fans", "waves", "hooks" and
  "fleuron": double rules, notched plaques, stadium, loop and wave
  ornaments, corner volutes sampled with `spiral-pts`.
- **`vintagebox` / `plaque-vintage`** (`src/vintage.typ`) — the six bracket
  plaques of the EPS sheet ("medaillon", "carre", "haut", "colonne",
  "ovale", "banniere"): white plate with concave corners, mid-side points
  or wavy long edges or lobed tabs, black outer rule, thin inner rule and
  a grey drop shadow; `examples/vintage.typ` shows both families.

The wooden pancarte, the torn-paper note and the spiral notebook become
boxes; every one of them can also frame a whole page.

- **`volutebox` / `cadre-volute` / `volute-pages`, `parchemin` / `lettre`**
  (`src/volutebox.typ`, `src/parchemin.typ`) — the blush stationery
  frame with chamfered double rules and ink volutes at the corners,
  as a box *and* as a page frame; and the old-letter scroll: rolled
  title cylinder, deckle-edged sheet with corner flourishes, bottom
  roll and an optional folded signing ribbon (`examples/volute.typ`).
- **`ogeebox` / `banniere`, `frisebox` / `frise`, `medallion`** (`src/ogeebox.typ`)
  — the teal-and-gold banner family after the "28 lettres" plates: an
  ogee-pointed plaque with double gold rule, star rosettes and a
  numbered octagon badge; a full-width frieze band with girih
  line-work at both ends; a scalloped white letter medallion
  (`examples/ogeebox.typ`).
- **`gelbox` / `bouton`** (`src/gelbox.typ`) — glossy aqua buttons after
  the I-Prof menu: gradient gel face, gloss cap, dark rim, soft drop
  shadow and a glossy ball on the top edge (`ball-x` moves it);
  `examples/gelbox.typ` rebuilds the reference menu.
- **Relief shadows, after `shadowed`** — the inset recipe is ported
  faithfully (SVG ring mask blurred with `feGaussianBlur`, clipped to
  the rounded box; the hole is offset for the directional bevel):
  `shadow: "inner"` / `"creuse"` gives the symmetric inner shadow of
  shadowed's inset example, `"emboss"` / `"bombe"` the raised bevel.
  The rim depth is adjustable (`depth`/`blur`, `strength`). New
  `insetbox` / `boite-creusee`: a plain rounded box carved into the
  page; `relief()` is exported for custom boxes; the raised modes'
  drop shadow now hugs the box so its corners coincide.
- **Sketchy-pencil styles for `plankbox`** — `style: "sketch"` draws the
  wavy double graphite banner with sparse pencil ticks radiating off the
  outline; `style: "hatch"` hugs a rough rectangle with a dense scribbled
  band of diagonal strokes; both on off-white paper (see
  `examples/sketch.typ`).
- **Coil edge** — the spiral rings keep the reference artwork's full
  size and overflow the sheet edge (left in LTR, right in RTL) as 3/4
  ellipses, like the clip-art; `coil-pages` keeps them inside the
  physical page.
- **`plank-pages` centring fix** — the sign is no longer shifted by a
  doubled margin; LTR and RTL frames are symmetric.
- **RTL & frames fixes** — `coilbox` punch holes now stay visible on the
  inner side of the spine in RTL mode (the coil end is offset
  direction-aware); the punch holes and coils mirror correctly; the
  `*-pages` rules now own their text margins through scoped `set page`
  calls so chaining several frames in one document (`#plank-pages[...]`,
  then `#torn-pages[...]`, ...) keeps correct margins in every section.
- **`coilbox` / `cahier` / `coil-pages`** (`src/coilbox.typ`) — a spiral
  notebook page after the pink clip-art: rounded pink double frame with a
  3D lip, a pink spine with black punch holes and alternating
  pink/purple coils drawn as sampled Bezier hooks with a gradient tube,
  a dark under-copy and a highlight (3D), the hooks overflowing the
  frame like the original; `coil-pages` sets it as a frame on every page
  with a wider margin on the spine side. RTL mirrors spine and coils.
- **Full-page frames** — `plankbox` and `tornpage` gain `height:`, and
  `plank-pages` / `torn-pages` (after `ornate-pages`) seat the sign or
  the torn sheet in the page background on every page while the text
  flows inside (`plank-pages` levels the sign with `tilt: 0deg`).
- **`mottle` rebuilt** — the papyrus noise is now many soft seeded
  blotches (large overlapping ellipses, random intensity) instead of a
  grid of cells, so the wood and the paper mottle without
  checkerboarding; shared by `plankbox` and `tornpage`.

- **`tornpage` / `page-dechiree`** (`src/tornpage.typ`) — a paper note
  ported from the tcolorbox `tcbnote` of Ignasi (TeX.SE 586474,
  CC BY-SA 4.0; the licence expression in `typst.toml` gains
  `CC-BY-SA-4.0`): a clean sheet with straight top and sides and sharp
  corners whose BOTTOM edge alone is hand-torn — a ragged base line
  (`seg` / `rag`) refined by `depth` passes of recursive midpoint
  displacement (`amp`), the `irregular fractal line` decoration of the
  original — plus a blurred shadow faked by three fading offset copies,
  a hairline rule, the papyrus mottle reused from `plankbox` and a bold
  title seated at the top centre. RTL aligns the body to the right.
  New example `examples/tornpage.typ` and a showcase section in
  `showcase/more.typ`.

- **`plankbox` / `pancarte`** (`src/plankbox.typ`) — a rustic wooden sign,
  front view on the page: light golden-beige planks, elongated and
  slightly irregular, with cut/torn notched ends — deep irregular slits,
  about as long as the box inset, with uneven thicknesses, like a
  hand-split board — and wavy top and bottom edges (dense seeded outline
  from the sketch engine's PRNG, `jitter` / `seed`), a
  darker rim inside a thin bark outline, grain veins, a forked crack,
  light scratches, discreet brown spots and a knot, a matte worn surface
  and a faint light-grey shadow under the lower edge. The title rides the
  upper plank and the body the lower one; without a title the body sits
  alone on a single plank about 2.4 times as wide as high, centred like
  the reference artwork. The whole sign leans very slightly (`tilt`,
  top edge rising to the right; the lower plank leans less) and mirrors
  under RTL (`direction`). `wood` / `edge` / `streak` / `text-fill`
  recolour it, `gap` sets the daylight between the planks.
  `plank-colours` exports the reference palette. New example
  `examples/plankbox.typ` and a showcase section in `showcase/more.typ`.

- **`halftone` / `trame`** (`src/fills.typ`) — the ribbon's right-panel dot
  screen as a reusable `tiling` fill: staggered or square lattice,
  `spacing`, `radius` (as a fraction of the spacing), optional `backdrop`
  paint; `matierebox` now draws its end panel with it.
  `examples/gallery.typ` maps every exported family, one captioned cell
  per function (4 pages, 78 cells), and `thumbnail.typ` mosaics them all.
- **`banner-tri` — `style: "arrondi"`** (`src/pictos.typ`) — the variant
  carried by arabic-exam-kit's exam header: every chevron tip and the body
  panel get quadratic-Bézier corner fillets (ported contour smoothing,
  exported as **`smooth-pts`**); `round` and `body-round` set the fillet
  radii, `style: "pointu"` remains the default.
- **`tikzpattern` / `motif-tikz`** (`src/fills.typ`) — the LaTeX `patterns`
  and `patterns.meta` libraries as first-class `tiling` paints:
  "horizontal lines", "vertical lines", "north east lines",
  "north west lines", "hatch", "lines", "grid", "crosshatch", "dots",
  "crosshatch dots", "checkerboard", "bricks", "fivepointed stars" and
  "sixpointed stars", with the TikZ options `distance`, `angle`,
  `line-width`, `radius` and the pattern `color`, plus a `backdrop` paint.
  A line family tiles seamlessly at *any* angle: the tile is the pattern's
  own lattice cell (Lx = distance/|n.x|, Ly = distance/|n.y|), so
  translating by either edge maps the family onto itself; `grid` and
  `crosshatch` are exact at multiples of 45° and approximated otherwise.

- **`banner-tri-bis`** (`src/pictos.typ`) — the arabic-exam-kit
  `exam-exercise-box` variant the kit carries: a compact three-layer
  rounded-arrow ribbon (rounded wedge + rounded trailing edge, staggered
  by `arrow-gap`) that hugs its `title : (points)` label and sits above
  the body on the leading edge — mirrored in RTL. `banner-tri`'s
  `style: "arrondi"` remains available.
- **`rosettebox` / `cadre-rosette` and `rosette-pages`** (`src/rosette.typ`) — the
  supplied dedication sheet's ornaments rebuilt as components: triple
  rule (ink, gold, rounded light-gold), four interlaced corner curves
  with sage leaves and eight-petal rosettes, diamond rows on the top and
  bottom bands, centre rosettes flanked by segments; the box adapts to
  its content (ornament scale follows the smallest side), mirrors and
  text direction follow LTR/RTL, and `rosette-pages` seats it as a page
  frame like `ornate-pages`. New example `examples/rosette.typ`.
- **`bricks` pattern redrawn** — drawn bricks with mortar joints and
  rounded arrises instead of mortar lines; joint width follows
  `line-width`, course height `distance`.

- **`polaroid` redesigned** (`src/fancy.typ`) — the photo zone becomes a
  real content area: an image *or text* (centred on the tinted
  `photo-fill`, `none` for a transparent zone); `width` gives the card
  width (default 7 cm, photo zone = width − 2·border so the white frame
  always covers it), `photo-height` fixes a flat or empty zone;
  `caption`, `angle`, `shadow`, `rough` unchanged.
- **`arrows` for `banner-tri-bis`** — the number of stacked arrow layers
  is now adjustable (1…n), like `banner-tri`'s long-standing `arrows`.

## 0.2.0 — 2026-09-09 (update 1)

Classroom pictos (customenvs), meters, marks, RTL polish.

### What’s new

- **`meter`** — styles `battery` (fill opposite the black nub), `speedo`, `chrono` / `#pictochrono`, `wifi` (classic hub + arcs), `cible` (white dart, rectangular stem `stroke: 2pt + black`, `fill: white`). Shared `size` parameter. Chili / piment **removed**.
- **`competence-crayon`** — vertical pencil (TeX.SE / `\CrayonDeCompetences`). RTL: pencil on the right, coloured pills against it, card text right-aligned. `size`, `direction`.
- **`sale-poster`** — `\AfficheSoldes`: titled box, old price NW / new SE, slanted SOLDES banner. RTL mirrors layout and uses Arabic labels. `size`, `direction`.
- **`banner-tri`** — `tkzBannerTri`: trapezoid + three nested chevrons. Text is **not** slanted. LTR chevron left (arrow →); RTL chevron **right** (arrow ←). `title`, `size`, `direction`.
- **`bicolor-title`**, **`highway-sign`**, **`level-counter`**, **`tkzpicto`**.
- **`#mark`** — highlight, wave, circle, box, strike, scribble, bracket, jagged, fan. **`#highlight-formula` / `#highlight-text`**.
- Showcase snippets now carry the **full call** (every named parameter used) above each LTR/RTL pair.

### Covers, lace, ornate (same 0.2.0 cut)

The ninth cover style, a submission-ready manifest and a tighter fiche.

- **`src/cover.typ`** — `book-cover` gains a ninth style, `scatter`: a
  night-teal gradient with six ghost rosettes and star dust under a thin
  gold rule ticked at the four corners, a centred stack of #raw-style
  series, title, subtitle and author over a diamond divider, a formula
  line between two side formulas and a note, thirteen tumbling 3D dice in
  ivory, gold and aqua with ground shadows, and a dark footer band.
- **`src/cover.typ`** — the 3D die is now one shared helper (`_die3d` with
  `_pips6`), reused by the `dice` and `scatter` styles.
- **`examples/fiche.typ`** — the side labels ride `swoosh` tabs on the
  trailing edge, the Euclidean divisions are set with
  `@preview/longops:0.1.0` instead of a local helper, and the vertical and
  horizontal gaps between the panels are tightened; the sheet still holds
  on one A4 page.
- **examples and manual** now import the package by specification
  (`@preview/faboxyst:0.2.0`), as the Universe packaging guide recommends.
- **manifest** — imperative description without the word "Typst", SPDX
  license expression `MIT AND LPPL-1.3c AND MIT-0` mirroring the README's
  per-file licensing, compiler floor 0.15.1, and an `exclude` list that
  keeps the manual, examples and thumbnails out of the downloaded bundle.

### Ornate frames & flag box

Ornate frames, a library of vector ornaments and the flag box. Nothing
existing changed except `lib.typ`, `typst.toml`, `manual.typ` and
`README.md`.

- **RTL everywhere** — every box now takes `direction: auto` (force it to
  `ltr` / `rtl`); bodies align to `start`, so an RTL document sets them
  right without wrapping them in `align(right)` (stamp-card, grid-note,
  index-card, deckle-tag, post-it, ticket, terminal, … all fixed).
- **`mark` / `highlight` over several lines** — past one line they fall
  back to the native per-line elements instead of clipping the canvas.
- **`flagbox`** — the ribbon now seats ON the top rule instead of floating
  above the frame: the rod lies astride the rule (lift it with `overhang`)
  and the banner hangs into the box, like the sash of an ornate box.
- **`boardbox`** (`chalkbox` / `markerbox`) — `grid-stroke` sets the ruling:
  a paint, a length for the line thickness, or a stroke dictionary with
  `paint` / `thickness` / `dash`; `auto` keeps the faint tint derived from
  the slate.
- **paper stocks** (`torn-note`, `ruled-sheet`, `stamp-card`, `grid-note`,
  `index-card`, `deckle-tag`, `notepad`, `lesson-card`) — the body now
  aligns physically to the reading direction (right under RTL), fixing
  short last lines that fell to the left inside the placed sheet.
- **`ornatebox`** — default sash caps are an `ogee` S-curve at both ends.
- **`post-it`** — `tape-wide` adjusts the strip's width independently of
  `tape-len`; **`def-card` / `sketch-box`** — `breakable: true` swaps the
  hand-drawn canvas for a native block frame that can cross pages.
- **`src/cover.typ`** — `book-cover`: a full-page cover in three styles
  ported from the TikZ originals — `guilloche` (royal navy: spiralling
  lace, diagonal grid, rosette seal, silver edge strip), `wedges`
  (Boussaada: checker ground, paper wedges, white rounded title cards)
  `spine` (a coloured spine band with rings beside a double-ruled title
  panel) and `medallion` (a cream disc ringed in orange on brown, with a
  drawn atelier of school instruments on a gold pedestal), `compass`
  (indigo streaks, magenta header card, year badge, inset graph and a
  great compass on its ellipse) and `openbook` (a dark title band over an
  open book with two graphed pages, a bookmark and a formula panel) and
  `sunburst` (radial rays, gold motto, yellow bands, bulleted topics and an
  open book ringed by instruments) and `dice` (navy plate, gem motifs,
  rosette and a corner-cut card carrying a swoosh of 3D dice).
- `fabox`: `title-inset` now pads every tab label ("ears", "dots",
  "plaque", "swoosh" and the rest) — it previously only affected the
  inline title, so tabs ignored it; defaults reproduce 0.1.0 exactly.
- New module `src/lace.typ`: four guilloche line families — `spiral`,
  `engine`, `braid`, `moire` — exported as `lace()`.
- `book-cover(style: "guilloche")` gains a `lace` parameter choosing the
  line family of its field.
- New box `lacebox` (`src/lacebox.typ`): a banknote frame — lace border
  band masked by a centre panel, corner rosettes, title plaque. `band`
  sets the frame's width, `weight` the outer rule, `width` the box;
  `model` offers four frames: `band`, `double`, `scallop`, `corners`.
- New example `examples/lace.typ` (three laced plates and a lacebox page)
  and a manual chapter for both.
- **`src/pgfornament.typ`** — the complete ornament bank of the CTAN
  package *pgfornament* v1.3 ported to Typst curves: 276 engraved pieces
  (196 `vectorian`, 78 `han`, 2 `am`) drawn by `pgfornament(n, family:,
  width:, paint:, thickness:)`. Clip (`\i`) and bounding-box (`\ubb`)
  paths are not drawn (no arbitrary path clipping in Typst) — the only
  deviation from the LaTeX original. Port keeps the LPPL 1.3 attribution
  (Alain Matthes; original idea F. Fradin and H. Voss; `han` family
  LIM LianTze).
- **`lacebox`** — `rough: 1.2` (any value > 0) redraws every straight rule
  (outer, panel, inner ring, plaque) with the sketchbook's felt-tip
  wobble; `ornament: 64` + `ornament-family` seat a pgfornament piece,
  mirrored, in the four corners of the frame in place of the rosettes or
  ray fans. `examples/lace.typ` now shows every box in rough mode plus
  two ornament pages (compiled to `rendus/exemple-lace.pdf`, 7 pages).
- **Covers realigned on their source code** — the original Typst sources
  of four plates surfaced; `dice`, `compass`, `sunburst` and `openbook`
  now use their exact palettes (navy `#122035` / gold `#C2AE7D`, violet
  `#3830AD` / magenta `#A02272` with a violet gradient ground and a
  graph-paper grid under the inset curve, green `#317F24` / yellow
  `#FFE557` with an amber outlined motto, teal `#173740` / `#187986` with
  a gold chapter line and cream ground) plus the source details: mint
  graph ink, radial-gradient year badge, lighter plateau top face,
  teal/copper page headers, pale formula panel, mint footer line.
- **`examples/fiche.typ`** — a one-page Arabic pedagogical sheet
  (fiche pédagogique) rebuilt with the package: `fabox` panels (coloured
  titles on tinted grounds), `numbox` square badges for the numbered
  lines, `spine` tabs for the side labels (النشاط 1, أمثلة تطبيقية),
  Euclidean longhand divisions, arrows and the reminder star
  (`rendus/exemple-fiche.pdf`).
- **`fabox` fix** — `title-rule-weight: auto` fell back to the *title's
  text weight* (a string such as `"bold"`) instead of the frame weight,
  crashing any box that set `title-weight` together with `rule-between`.
- New example `examples/covers-duo.typ`: all eight styles set twice —
  once in Arabic, once in French — with fresh subjects and wordings
  (sixteen covers, compiled to `rendus/exemple-covers-duo.pdf`). It bleeds to the paper edge whatever the margins, and
  every anchored element mirrors under RTL.
- **`src/meter.typ`** — `meter` / `difficulty`: a tiny inline instrument
  for an exercise's difficulty, in four styles — `gauge` (speedometer:
  coloured zones, ticks, needle), `thermo`, `battery` (charge ramps the
  other way: empty is the alarm) and `bars`; green-amber-red ramp,
  mirrored under RTL.
- **`src/ornament.typ`** — 19 motifs drawn with `curve` / `polygon`
  (khatam `star8`, `rosette`, `medallion`, zellij `tile` / `knot`,
  `palmette`, `finial`, `scroll`, `wisp`, `flourish`, `wedge`, `notch`,
  `merlon`, …), no image assets. Motif API: `motifs`, `ornament`,
  `glyph-motif` (any font glyph), `content-motif`, `image-motif` (any SVG,
  recoloured black \u2192 ink / white \u2192 paper), `tint`, `turned`,
  `make-palette` / `default-palette` / `ornament-palette`.
- **`src/ornate.typ`** — `ornatebox`: a frame built by repeating motifs
  along concentric rules — sides (`edge-*`: count, gap, shift, mask, band,
  alternate, pack, fit, turn), corners (logical keys, `(bottom-end: \u2026)`,
  flipped for RTL), centre pieces, a title sash with nine cap shapes
  (`flat`, `point`, `notch`, `arch`, `round`, `ogee`, `swoosh`, `step`,
  `bevel`) or a course of zellij tiles with a paper pennant, flank / end
  motifs, and a khatam badge with label. Presets `khatambox`, `zellijbox`,
  `arabesquebox`, `mihrabbox`, `mosaicbox`, `fleuronbox`; `ornate-pages`
  draws a frame on every page; `sash-shape` and `khatam-badge` are public.
- **`src/flagbox.typ`** — `flagbox`, after *tcolorbox*'s flag style and
  improved: rod with finials, three-stop gradient banner, gloss line,
  stitched hem, soft shadow, three tails (`drape` / `point` / `swallow`),
  numbered badge, `end-motif`, `flag-align` (start / center / end), full
  RTL, breakable body.
- New manual chapter (`manual-ornate.typ`, included after the gallery),
  new examples (`examples/ornate.typ`, `examples/arabic-plates.typ`,
  `examples/image-motif.typ`, `examples/rtl-boxes.typ` for
  right-to-left documents, `examples/flow.typ` for multi-line
  marks, `tape-wide`, breakable boxes and the seated ribbon).
- `examples/assets/` carries three SVGs from *fancy-frames* (Daniel Ayala,
  MIT-0), used only to demonstrate `image-motif`; they can be deleted
  without breaking anything.
- No fonts are bundled: the Arabic examples prefer Amiri / Noto Naskh /
  Noto Kufi when installed and fall back to DejaVu otherwise.

## 0.1.0 — 2026-08-23

First public cut of **faboxyst**: a Typst-Universe package of *boxes only*,
in the spirit of LaTeX *tcolorbox*.

- `#show: faboxyst.with(theme: …)` is a theme show rule, not a document class.
- Public commands: `#fabox`, `#fabox-sign`, `#fabox-note`.
- **No fonts are bundled.** Optional faces (xkcd, Bevan, Comic Neue, Tajawal,
  Lalezar) are used when installed; otherwise DejaVu.
- Social-network posts live in the separate package **socialyst**.
- **`sashbox` / `ruban`** — folded ribbon banners (`flat` / `arch` / `hang`),
  with `incline` for the bow and `rough` for a closed sloppy-box outline.
- **`ticket` / `ticketbox`** — stub coupon, leading half-disc, trailing hole.
  Both features flip in RTL. Arabic-Indic / Persian digits become Western 0–9.
- Textbook plates: icon, crest, ribbon, helix, swoosh, circuit, key, ring,
  punch, planner, file, stub, stack, callout, tape, chalk, marker, screw.
- Universe-style English manual (`manual.typ` / `manual.pdf`).
