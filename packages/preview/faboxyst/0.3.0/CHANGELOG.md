# Changelog

## Unreleased — fabox material finishes

- Added `fabox(finish: "wet")`: translucent face wash, glossy dark rim, upper-left
  specular streaks and lower-right seam; kept independent from the existing drop shadow.
- Added `fabox(finish: "joint")`: raised sealing bead with cast shadow, inner groove
  and directional highlights.
- Added material tint, highlight/shadow colours and `finish-depth` controls, with
  monochrome print conversion; documented and covered both finishes in tests.
  The finish is intentionally unavailable with `sweep` or a folded corner.

## 0.3.0 — pure-Typst engine, nibart, page frames moved to nibframe

- **`parchemin` / `lettre`: right-to-left text is now right-aligned.** New
  `direction: auto` option; `auto` detects Arabic/Hebrew in the body, title or
  signature (a document set to `lang: "en"` no longer left-aligns Arabic
  content). `ltr` / `rtl` force it. Test: `tests/test-parchemin-rtl.typ`.
- **18 infographic functions** (all drawn with nibart pens: broad-nib outlines, soft shadows; `steps:`, `width`, `height`,
  `direction`, mirrored in RTL, print mode): cards in a row —
  `puzzle-tab-cards`, `folded-tab-cards`, `half-disc-tab-cards`,
  `u-backed-cards`, `circle-head-outline-cards`, `dashed-pill-cards`,
  `skewed-badge-cards`, `badge-timeline-cards`; stacks — `ring-linked-boxes`,
  `wire-linked-pills`, `brush-stroke-rows`, `twisted-ribbon-rows`,
  `bubble-tail-boxes`, `striped-poster-cards`; compound — `pencil-frame-flow`,
  `index-notebook`, `film-strip`, `chevron-slideshow-frame`
  (`src/infocards.typ`, `src/infostacks.typ`, shared helpers `src/infokit.typ`).
- **4 sketched frames** (nibart pens; charcoal, crayon and pencil use nibart's
  `pressure` for a grainy dry-media stroke): `vintage-frame` (ink; `window:` none / oval / rect /
  twin-oval / twin-rect, `inner: "bevel"` for the "THE END" panel),
  `charcoal-frame` (rect / ellipse), `crayon-frame`, `pencil-sketch-frame`
  (`src/sketchframes.typ`).
- **`looped-chevron-callout` redrawn after the reference picture.** The frame is
  now a flat broad band (no rounded caps, no highlight line) that loops round the
  panel: swallow-tail tail at the top left, slanted end on the left loop, two
  solid chevrons at that end; a single shadow — the whole drawing lowered to the
  right behind a white outline — replaces the old grey strokes; the emblem gets a
  shadow too. New `body-weight` (bold), `body-stretch` (75 %, condensed face when
  available) and `font`. The third colour of `chevron-colours` is now the shadow
  colour. Default `height` 4.9 cm (the picture's proportions).
- **`tornpage`: lighter shadow, outlined sheet.** The gradient shadow is much
  lighter; the sheet is now outlined (all four sides, torn edge included) with a
  black 0.4 pt line by default — `weight:` sets the thickness, `rule:` the colour.
- **`taped-curl-note`: no more clipped art** when `width` and `height` do not
  follow the artwork's proportions (the SVG is now stretched instead of cropped);
  the manual example was reduced to fit its cell.
- **`tapebox`: the tilted tape no longer touches the text.** The top padding now
  clears the lowest end of the tape (new `top-inset: auto`); a relative `width`
  now includes the tape ends, so the piece fits its line.
- **`competence-crayon`:** the manual example now shows four sections.
- **`four-feature-icon-cards`:** the titles and the icons are centred vertically
  (and horizontally) in their coloured shapes; `icon-offset-x/y` now nudge the
  icon only (they used to move the whole card).
- **Fonts.** The theme's heading stack no longer starts with `Bevan` (which made Typst
  warn "unknown font family: bevan" on machines without it): it now starts with Typst's
  standard `Libertinus Serif`.
- **`flagbox`: the title flag is seated on the frame again.** The box's inset was not applied
  to its content, so the rod floated one inset above the top rule and the body text touched the
  frame; the content is now offset by the inset and the rod sits astride the top rule.
- **`tornpage`: one shadow instead of three stacked copies.** A single lowered copy of the
  sheet filled with a grey gradient, darkest right under the torn edge and fading downwards.
- **`postit`: the lifted shadow is back inside the sheet.** The sheet now runs down to
  the bottom edge and the shadow is drawn over it, inside the silhouette; the new
  `shadow-inside: false` restores the shadow hanging below the sheet.
  Documented in the manual (parameter table, signature and a two-note example) and in the README.
- **Theme-driven hand-drawn mode for `fabox`, `fabox-sign`, `fabox-note`, `example-header`.**
  `rough:` is now `auto` by default: such a box is hand-drawn as soon as the theme
  sets a `roughness` explicitly (`make-theme(roughness: r)`, `faboxyst.with(roughness: r)`,
  `theme: (roughness: r)`) and `r > 0`; `r = 0` stays crisp. The box's own `roughness` is
  multiplied by the theme's. Themes that merely carry a roughness (`bold`, `quiet`,
  `antique`, `print`) and the default theme keep crisp boxes, so existing documents are
  unchanged. A theme's `rough: true/false` and a box's `rough: true/false` still win.
  The manual described `rough` as a strength: it is a switch (`roughness` is the strength).
- **Roughness / sketch fixes.** `hand: "sketch"` now follows `roughness` (the
  wobble amplitude is multiplied by it) in the scrapbook family (`torn-note`,
  `ruled-sheet`, `stamp-card`, `grid-note`, `index-card`, `deckle-tag`, `notepad`,
  `lesson-card`, `lesson-table`) and in the marks/boxes of `fancy` (`mark`,
  `sloppy-box`, `ticket`, …); the pure-Typst `sketch` decoration wobbles
  about twice as visibly as in the first 0.3.0 build (shorter, stronger noise knots)
  and no longer looks straight at `roughness: 1`. `rough: true, hand: "roughjs"`
  on a hairline ruling no longer fails with "unknown variable: rough-points".
- **`twisted-ribbon-rows` redrawn** after the reference: the white numbered tab
  and the coloured band are joined by a bow-tie neck (Bézier twist, never a point),
  with a soft shadow on the white lobe, a smooth bell-shaped lower curve and a
  tail tapering to a hairline. New `twist` (neck width, 70 %) and `depth` (raised
  rim, 0.06 cm) parameters; the rim is a translucent bevel drawn on the coloured lobe only.
- `puzzle-tab-cards` has `letters:`; `half-disc-tab-cards` and `twisted-ribbon-rows`
  have `caption:`; `index-notebook` tabs accept `label:` per step.
- Package **thumbnail** refreshed (the 0.3.0 infographics and sketched frames) and
  shown at the top of the README; the manual PDFs (EN/FR) now ship in `docs/`.
- Adjustable thickness: `charcoal-frame` and `crayon-frame` take `band` (cm; defaults 0.5
  and 0.8) and `weight` (stroke multiplier, 100 %); `film-strip` takes `band` (film thickness)
  and a lighter `film` grey; `pencil-frame-flow` has slimmer pencils and `scalex` / `scaley`
  (default 150 % / 100 %) to stretch the labels; `puzzle-tab-cards` text flows round the round
  letter tab; `striped-poster-cards` stripes are drawn as plain rectangles (continuous).
- Manual chapters "Infographic cards, stacks and compound frames" and "Sketched
  frames" added to `docs/_data.typ`.
- **No more WebAssembly.** `sketch.wasm`, `elliptical_pen_envelope.wasm` and
  their MPL-2.0 notice are removed. The sketch engine is now pure Typst
  (`src/sketchcore.typ`, same call sites as before) and the antique register
  (`src/antique.typ`, `vintage: true`, `engraved-*`, `plate-page`,
  `patent-page`) draws its broad-nib strokes with the **nibart** package
  (`@preview/nibart:0.3.0`; `@local/nibart:0.3.0` in the local edition). The
  manifest licence is `MIT AND LPPL-1.3c AND MIT-0 AND CC-BY-SA-4.0`.
- **Page frames moved to nibframe.** `ornate-pages`, `rosette-pages`,
  `volute-pages`, `plank-pages`, `torn-pages` and `coil-pages` are removed
  outright (no wrapper, no dependency on nibframe). Use nibframe's styles
  `dedication`, `classic`/`label`, `plank`, `torn` and `coil` instead.
  `plate-page`, `patent-page` and `bound-page` (spiral binding) stay: they are
  page layouts. Older entries below that mention the `*-pages` functions are
  historical.
- **New manual** (`docs/`): bilingual (English/French), organised by family,
  with the full parameter table of every function and a live example beside
  its code. Build with `python3 docs/build-manual.py both` (chapter by
  chapter; needs `pypdf`). The former root-level `manual*.typ` files are gone.
  Every render is shrunk to fit its cell (`fit` in the data), and Arabic
  examples run in an Arabic context (`lang: "ar"`): faboxyst reads the text
  direction from the text settings, never from the content.
- **Fixes in 0.3.0.**
  - `alternating-line-block-process` redrawn after the reference slide: outline
    cards whose outline steps down into a block arrow (head at the bottom for
    odd cards, at the top for even ones), icon inside the head, justified body.
  - `double-frame`: new `stroke-colour-2` (colour of the second pass).
  - `taped-curl-note`: new `tape-angle`. `sb-underline`: defaults `span: 1.0`,
    `shift: 0.0`. `deckle-tag`: more room above the tape.
  - `flag-ribbon`: `vintage: true` uses a fine default pen.
  - `khatambox`, `mihrabbox`, `zellijbox` ribbons: the left cap of the sash was
    drawn from the wrong point, which broke arch and point caps; the three are
    now symmetric. Titles that wrap make the band taller.
  - `crestbox` (octagonal title plate), `ribbonbox` (rounded stroked tab),
    `speech-bubble` / `joined-bubbles` (tail never wider than half the bubble).

## Local addition — Quad Step Cards (approved)

- Added and exported `quad-step-card`, one portrait card with a white rounded
  panel, upper dark icon medallion and accent halo, and lower numbered
  medallion. Supports custom icons, accent colors, Arabic RTL and grayscale
  print; callers compose separate cards themselves.
- Added color, Arabic RTL, monochrome print, and focused regression examples.
  Visual review approved; the ZIP remains unchanged.

## Local addition — Text Box Displays (approved)

- Added and exported `text-box-display-card`, one vertical card with an
  overlapping icon tile, colored body, and faceted footer/banner. Supports
  custom icons, accent colors, Arabic RTL text, and grayscale print. The source
  four-card slide is not bundled; callers arrange separate cards themselves.
- Added color, Arabic RTL, print, and focused regression examples. The top
  shoulder folds were corrected to be exact mirror images after review.
  Visual review approved; the ZIP remains unchanged.

## Local addition — Stacked Banners Diagram (approved)

- Added and exported `stacked-banner-row`, one reusable horizontal banner row
  with an icon block, folded divider, title and body copy, and a lower accent
  stripe. Supports RTL mirroring, custom icons, configurable colors, and
  monochrome print; callers compose separate rows themselves.
- Added a four-page review set and focused regression test. Adapted from the
  supplied PresentationGO reference; the four-row diagram and full slide are
  not included. Visual review approved; the ZIP remains unchanged.

## Local addition — Vertical Chevron List Item (approved)

- Added and exported `vertical-chevron-list-item`, one horizontal row with a
  downward numbered-chevron badge, title, body, and soft-shadowed panel. Badge
  placement mirrors in RTL; monochrome print is supported. The full four-row
  source slide is not bundled.
- Added LTR, reversed-side, Arabic RTL, print examples, and a regression test.
  Visual review approved and synchronized to the local package.

## Local addition — Three-Color Infographic Card Stack (approved)

- Added and exported the standalone `three-color-infographic-card` and reusable
  `three-color-infographic-stack`: overlapping panels under a continuous pale
  shared ribbon with top/bottom overhang. The helper composes panels only, not
  a complete slide. Arabic RTL and grayscale print are supported; print draws
  separator rules only between cards.
- Added individual, stack, RTL, print examples and a focused regression test.
  Attribution: “Designed by Alvaro_cabrera / Freepik”; no source artwork is bundled.
  Visual review approved and synchronized to the local package.

## Local addition — Neumorphic Text Panel (approved)

- Added and exported `neumorphic-text-panel`, a single portrait card with a
  raised top medallion, soft double relief, neutral/accent finishes, RTL copy,
  and monochrome print. Added review examples and a focused test. Visual review
  approved and synchronized to the local package.

## Local addition — Horizontal Chevron Block (style approved)

- Added and exported `horizontal-chevron-block`, one standalone horizontal
  segment with an icon cap, pastel text field, and layered chevron divider. It
  supports either cap side, automatic RTL mirroring, and monochrome print.
- Added LTR, reversed-cap, Arabic RTL, print examples, and a focused regression
  test. Adapted from the supplied PresentationGO preview; no full four-row slide
  is bundled. Visual review approved and synchronized to the local package.


## Local addition — Wavy Infographic Box (style 53; approved)

- Added and exported `wavy-infographic-box`, one colorful text card with an
  S-curved inset shoulder, a wavy interlocking edge, layered shadow, and round
  icon medallion. The title/body, palette, size, icon, and direction are
  configurable; Arabic RTL mirrors the silhouette and badge, while print uses
  grayscale outlines and icon work.
- Added color LTR, dark Arabic RTL, grayscale LTR/RTL, a four-page review set,
  and a focused regression test. Adapted from PresentationGO's Infographic Text
  Boxes; this is one card, not the source's four-box row. Visual review approved.

## Local addition — Product Feature Callout (style 52; approved)

- Added and exported `feature-callout-box`, one rounded square feature tile with
  an adjustable triangular pointer, centered icon, caption above or below,
  configurable colors, dimensions, and soft layered shadow. Direction-aware
  captions support genuine Arabic RTL; print mode switches the tile, icon, and
  shadow to grayscale.
- Added color LTR, dark Arabic RTL, grayscale LTR/RTL, a four-page review set,
  and a focused regression test. Adapted from SlideUplift's Product Features
  Callout; this is one reusable tile and its caption, not the source's five-box
  layout. Visual review approved.

## Local addition — Folding Card Box (style 51; approved)

- Added and exported `folding-card-box`, one open card with a split numbered
  front face and two unfolded leaves: title and icon/body. Proportions, copy,
  color, icon, and dimensions are configurable. RTL mirrors all three columns;
  print preserves the separate panes and fold seams in grayscale.
- Added light LTR, dark Arabic RTL, print LTR/RTL, a four-page review set, and a
  focused test. Adapted from SlideModel's Folding Cards preview; only one open
  card is drawn, not the three-card row or animated slide sequence. Visual review
  approved.

## Local addition — Folded Banner Info Box (style 50; approved)

- Added and exported `folded-banner-info-box`, one reusable information card
  with a pill-shaped overhanging title banner, layered fold tab, offset gray
  body panel, number, icon slot, and measured copy. It mirrors the banner,
  number, icon/body columns, and text direction in RTL; print uses grayscale.
- Added light LTR, dark Arabic RTL, LTR/RTL print previews, a four-page review
  set, and a focused regression test. Adapted from PresentationGO's Four-Step
  Boxes; only one representative card is included, not the source's 2×2 grid.
  Visual review approved.

## Local addition — Perspective Panels (2026-09-28; approved)

- Added and exported `perspective-panels`, a reusable row of overlapping, curved
  panels with layered depth, offset shadows, five distinct line-icon defaults,
  title/body content, and numbered badges. Panel count comes from the data;
  individual widths, positive spacing or negative overlap, center recess, palette,
  height, depth, and perspective are configurable. RTL mirrors panel order and
  text direction, demonstrated with Arabic copy and numerals; print retains the
  layered geometry in grayscale.
- Refined after the first review with closer source-like overlaps, icon variety,
  more pronounced perspective, recessed center panels, and clearer title contrast.
  Added three- and four-panel color examples, Arabic RTL and grayscale print
  previews, a four-page review set, and focused tests for one through four panels.
  Adapted from PresentationGO's 5-Option Perspective Panels; this is the panel-row
  component, not the full slide. Visual review approved.

## Local addition — Interlocked Abstract Textbox (2026-09-28; approved)

- Added and exported `interlocked-abstract-textbox`, one dark editable-style
  panel with a curved interlock edge, diagonal title banner, icon area, and body.
  RTL mirrors the interlock/banner; print keeps the geometry in grayscale.
- Added color LTR, dark RTL, print LTR/RTL, a four-page review, and a focused
  regression test. Adapted from PresentationGO's Interlocked Abstract Textboxes;
  only one box is drawn, not the five-box row.

## Local addition — Paper Note box (2026-09-28; approved)

- Added and exported `paper-note-box`, one colored front sheet with a rotated
  offset backing, paperclip detail, heading, and body copy. RTL mirrors the clip
  and sheet tilt; print switches the paper layers and clip to grayscale.
- Added color LTR, dark RTL, print LTR/RTL, a four-page review, and a focused
  regression test. Adapted from PresentationGO's Paper Notes; only one note is
  drawn, not the four-note cluster.

## Local addition — Stacked Summary Card box (2026-09-28; approved)

- Added and exported `stacked-summary-card-box`, one horizontal content card
  with a colored edge bar, heading, and supporting copy. RTL mirrors the bar
  and aligns text appropriately; print uses a grayscale bar and dark text.
- Added color LTR, dark RTL, print LTR/RTL, a four-page review, and a focused
  regression test. Adapted from PresentationGO's Stacked Summary Cards; only
  one card is drawn, not the five-card stack.

## Local addition — Serpentine Process box (2026-09-28; approved)

- Added and exported `serpentine-process-box`, one interlocking node with a
  rounded connector profile, serpentine loop, icon medallion, title, and copy.
  RTL reverses the loop's progress markers; grayscale print preserves the shape.
- Added color LTR, dark RTL, print LTR/RTL, a four-page review, and a focused
  regression test. Adapted from PresentationGO's Boxes & Serpentine Process;
  the source's five-node row is not reproduced.

## Local addition — Corner Ribbon Process box (2026-09-28; approved)

- Added and exported `corner-ribbon-process-box`, one outlined card with layered
  diagonal corner ribbons, a side number tab, circular icon medallion, title rule,
  lower corner wave, and progress dots. It mirrors in RTL and retains its detail
  in grayscale print.
- Added focused LTR, dark RTL, print LTR/RTL, and regression examples. Adapted
  from PresentationGO's 4-Step Corner Ribbon Process; only one card is drawn.

## Local addition — Continuous Block Process box (2026-09-28; approved)

- Added and exported `continuous-block-process-box`, one tall card with a
  colored percentage window, a through-arrow segment, title, body copy, and a
  compact bar-chart icon. Height adapts to copy; RTL mirrors the arrow and text;
  grayscale print retains the structural detail.
- Added focused LTR, dark RTL, grayscale print, and regression examples. Adapted
  from PresentationGO's Continuous Block Process; only one card is shown, not
  the source's three-card sequence.

## Local addition — Text Box Process box (2026-09-27; review pending)

- Added and exported `text-box-process-box`, a single arrow-header card with a
  raised number badge, separate folded fins, a skewed gradient depth shadow,
  justified copy, and measured content height. RTL mirrors the geometry; print
  retains the layered details in grayscale.
- Added focused LTR, dark RTL, grayscale print, and regression examples. Adapted
  from PresentationGO's Text Box Process; the three-card slide is not reproduced.
  Awaiting visual approval.

## Local addition — folder text box (2026-09-27)

- Added and exported `folder-text-box`, one editable-style folder card with
  the original raised tab contour, top-left number, and S-curved icon inset.
- Added light LTR, dark RTL, grayscale print LTR/RTL examples, a four-page
  review and a focused test. Adapted from PresentationGO's Folder Text Boxes;
  only one reusable box is drawn, not the three-card row or slide copy.

## Local addition — folder text block (2026-09-27)

- Added and exported `folder-text-block`, a single reusable card following
  the source PPTX proportions and its curved folder-shoulder contour, accent
  lip, title field and two-tone lower split.
- Added light LTR, dark RTL and grayscale print LTR/RTL examples, a four-page
  visual review, and a focused regression test. Adapted from PresentationGO's
  Folder Text Blocks; the source's four-card grid is not included.

## Local addition — folder step box (2026-09-27)

- Added and exported `folder-step-box`, a single layered folder silhouette
  behind a contrasting stepped content panel. It supports mirrored RTL, a
  number/icon header, dark-background colors, and grayscale print mode.
- Added navy/white/black clipboard SVGs, light LTR, dark RTL, and print LTR/RTL
  examples, plus a focused test. Adapted from PresentationGO's Folder Step Trio;
  the source's three-box layout is not included.


## Local addition — pocket card box (2026-09-27)

- Added and exported `pocket-card-box`, a single rounded card with a raised
  colored tab and circular pocket lip; dark-page and grayscale print support
  are included.
- Added white/black bar icons, light LTR, dark RTL, and print LTR/RTL examples,
  plus a focused test. Adapted from PresentationGO's Pocket Card Process; only
  one box is included, not the source's four-card process row.


## Local addition — peak header box (2026-09-27)

- Added and exported `peak-header-box`, a rounded single card with a white
  header that dips to a central peak above the colored content panel. It
  supports RTL mirroring, optional numbers/icons, dark styling, and print mode.
- Added coral/teal/black chart icons, light LTR, dark RTL, and print LTR/RTL
  examples, plus a focused regression test. Adapted from PresentationGO's Peak
  Header Cards; only one box is included, not the source's connected sequence.


## Local addition — perspective text box (2026-09-27)

- Added and exported `perspective-text-box`, a single slanted text panel with a
  shaded depth edge. RTL mirrors the depth; dark and grayscale print options
  and configurable geometry, colors, and typography are included.
- Added black/white target icons, light LTR, dark RTL, and print LTR/RTL examples,
  plus a focused test. Adapted from PresentationGO's Perspective Text Boxes;
  only the individual panel is included, not the source progression layout.


## Local addition — tabbed folder box (2026-09-27)

- Added and exported `tabbed-folder-box`, a single reusable folder-style panel
  with a raised colored tab/header, body surface, and footer strip. It mirrors in
  RTL, supports dark backgrounds, and switches to grayscale in print mode.
- Added white/black list-check icons, light LTR, dark RTL, and print LTR/RTL
  examples, plus a focused regression test. Adapted from PresentationGO's
  Tabbed Folder Grid; the source's six-box slide layout is not included.


## Local addition — frame accent block (2026-09-27)

- Added and exported `frame-accent-block`, a single feature component with an
  offset colored square, open outline frame, icon, title, and supporting copy.
  RTL mirrors the offset; dark and grayscale print treatments are supported.
- Added an original bulb icon, light LTR, dark RTL, and print LTR/RTL examples,
  plus a focused regression test. Adapted from PresentationGO's Frame Accent
  Blocks; only the individual block component is included.


## Local addition — text box tags (2026-09-27)

- Added and exported `text-box-tag`, a single notched text panel with a
  contrasting icon bay, mirrored reading direction, optional square corners,
  dark-background shadow tuning, and grayscale print treatment.
- Added an original star icon, light LTR, dark RTL, and print LTR/RTL examples,
  plus a focused regression test. Based on the individual tag component in
  PresentationGO's Text Boxes (Tags); no multi-tag slide layout is included.


## Local addition — L-shaped header box (2026-09-27)

- Added and exported `l-shaped-header-box`, a single reusable panel with an
  L-shaped colored heading band and overlapping circular icon badge. Header,
  title, body, dimensions, palette, RTL direction, dark appearance, and grayscale
  print mode are configurable.
- Added an original award icon SVG, light LTR and dark RTL examples, monochrome
  print LTR/RTL examples, and a focused regression test.


## Local addition — concentric tier cards (2026-09-27)

- Added and exported `concentric-tier-cards`: three nested rounded frames
  containing broad, focused, and core priority text/icon groups. Frame sizes,
  insets, colors, and typography are configurable; RTL mirrors the icon/text
  rows and print mode uses grayscale borders and a central panel.
- Added original globe, target, and diamond SVG icon assets, plus light LTR,
  dark RTL, and print LTR/RTL examples with a focused test. Compiled only this
  style in Universe and local.

## Local addition — six-step numbered card list (2026-09-27)

- Added and exported `six-step-numbered-card-list`, a responsive two-column
  grid of rounded white cards with subtle shadows, numbered circular badges,
  titles and supporting text. RTL reverses reading order and mirrors the badge;
  dark-slide and monochrome badge options are provided, with print-safe grayscale.
- Added light LTR, dark RTL, print LTR/RTL galleries, and a focused test.
  Compiled only this style in Universe and local.

## Local addition — four feature icon cards (2026-09-27)

- Added and exported `four-feature-icon-cards`, a customizable two-by-two grid
  of outlined feature panels with overlapping circular icon medallions, dotted
  accents, colored title bars, and body text. RTL mirrors each panel and reverses
  reading order; a dark-slide option and monochrome print mode are included.
- Added four sets of light/dark/print pictograms and LTR, dark RTL, and print
  LTR/RTL examples, plus a focused test. Compiled only this style in Universe
  and local.

## Local addition — hand-drawn speech bubbles (2026-09-27)

- Added and exported `hand-drawn-speech-bubbles`, with editable quote, angled
dialogue, and thought-cloud silhouettes; palette, dimensions and typography are
configurable. RTL mirrors bubble order and tails; `dark: true` supports dark
slides, while print mode uses monochrome faces, outlines and accents.
- Added light, dark RTL, and print LTR/RTL examples plus a focused test; compiled
only this style in Universe and local.

## Local addition — three-step highlight cards (2026-09-27)

- Added and exported `three-step-highlight-cards`: three rounded, accent-framed
  cards with numbered tabs, downward notches, icon wells and vertical dividers.
  Palette, grid spacing, card and tab sizes, icons and typography are configurable;
  RTL reverses card order and mirrors icon/text placement.
- Added LTR/RTL colour and print galleries with monochrome icon assets, compiled
  previews and a focused test. Compiled only this style in Universe and local.

## Local addition — double duo neumorphic (2026-09-27)

- Added and exported `double-duo-neumorphic`, with soft-shadow cards and
  alternating inset icon circles; `raised: true` and `icon-fill:` add a colored
  raised pad. Grid size and typography are configurable; RTL mirrors the icon
  pattern and card order.
- Added LTR/RTL color and print galleries, monochrome pictograms, compiled
  previews and a focused test. Compiled only this component's examples and
  test in Universe and local.

## Local addition — cube block list (2026-09-27)

- Added and exported `cube-block-list`, a grid of layered 3D blocks with a
  colored title face, offset front panel, side facet, and optional icon. Face
  sizes, depth, spacing, palette and typography are configurable; RTL mirrors
  the depth and reverses the visual sequence.
- Added LTR/RTL color and print galleries, monochrome pictogram counterparts,
  compiled previews and a focused test. Compiled only this component's examples
  and test in Universe and local.

## Local addition — cornered cards (2026-09-27)

- Added and exported `cornered-cards`, with bordered white cards, diagonal
  icon flaps at the upper leading corner, and numbered flaps at the lower
  trailing corner. Corner size/overhang, palette, grid and typography are
  configurable; RTL mirrors the corners and card order.
- Added LTR/RTL color and print galleries, four monochrome pictograms, compiled
  previews, and a focused test. Compiled only this component's examples and
  test in Universe and local.

## Local addition — connected cards process (2026-09-27)

- Added and exported `connected-cards-process`, with thick colored rounded
  frames, inset white cards, and curved connector necks. Width, columns, spacing,
  connector shape, palette and typography are configurable; RTL reverses the
  visual sequence and print mode uses monochrome gray frames and links.
- Added LTR/RTL color and print galleries, pictogram assets, compiled previews,
  and a focused test. Compiled only this component's examples and test in
  Universe and local.

## Local addition — cards with corner sleeve (2026-09-26)

- Added and exported `cards-with-corner-sleeve`, a rounded card gallery with
  a colored diagonal corner flap, shadow, title, body and optional icon. Grid
  width, columns, spacing, flap size, colors and typography are configurable;
  RTL moves the sleeve to the opposite corner and reverses card order.
- Added LTR/RTL color and print galleries, monochrome icon variants, compiled
  previews and a focused regression test. Compiled only this component's
  examples and test in Universe and local.

## Local addition — capsule text boxes (2026-09-26)

- Added and exported `capsule-text-boxes`, a grid of floating cards with a gray
  numbered header, icon, custom curved seam, colored lower panel and subtle
  shadow. Grid width, columns, spacing, colors, seam and typography are
  configurable; RTL mirrors card order while both directions use the same seam sweep.
- Added LTR/RTL color and print galleries, monochrome icon variants, compiled
  PNG previews and a focused test. Compiled only this component's examples
  and test in Universe and local.

## Local addition — calendar list (2026-09-26)

- Added and exported `calendar-list`, a configurable grid of colored cards with
  title bands, twin binder tabs, U-shaped frames, centered icons and body text.
  Width, columns, spacing, colors and typography are adjustable; RTL reverses
  card order.
- Added LTR/RTL color and print examples, monochrome icon pairs, compiled PNG
  previews and a focused regression test. Compiled only this component's
  examples and test in Universe and local.

## Local addition — banners with circles (2026-09-26)

- Added and exported `banners-with-circles`, a width-adjustable gallery of
  colored horizontal banners with overlapping numbered circles, title, body
  and optional icon. Columns, inter-banner spacing, colors and typography are
  configurable; RTL mirrors the circle and text/icon zones.
- Added color and monochrome-print LTR/RTL examples, six monochrome icon pairs,
  compiled PNG previews, and a focused test for width, direction and print.
  Compiled only this component's examples and test in Universe and local.

## Local addition — alternating line block process (2026-09-26)

- Added and exported `alternating-line-block-process`, with tall rounded cards,
  alternating title tabs and open-outline arrow connectors. The connector line
  alternates between the upper and lower edges; per-step pictograms sit inside
  the arrowheads, and RTL reverses the flow and mirrors the connectors.
- Added configurable width, height, spacing, radius, colors and text sizes, plus
  optional `icon` and `print-icon` content. Print uses white cards, gray arrow
  lines and pictograms, light-gray title tabs, and black card outlines/text.
- Added LTR/RTL color and print examples and a focused regression test. Only
  this component's examples and test were compiled.

## Local addition — alternating block process (2026-09-26)

- Added and exported `alternating-block-process`, a horizontal sequence of
  alternating numbered color blocks with four filled, rounded chevron ribbons
  modeled on the supplied PowerPoint's custom vector paths and overlaid in
  front of the card faces. The inward background cutout follows the rounded
  card contour in the supplied PowerPoint. Print uses medium-gray ribbons,
  numbers and icons, white faces/knockouts, and black body text/outlines. Step
  data, number/color cycling, card size, spacing, text and direction are customizable.
- RTL reverses the process flow and mirrors the arrows and card details. A
  per-step `print-icon` allows monochrome image icons to be provided.
- Added LTR/RTL color and print galleries, vector icon assets, and a focused
  test compiled individually; no package-wide compilation was performed.

## Local addition — abstract textbox cards (2026-09-26)

- Added and exported `abstract-textbox`, inspired by the supplied slide image:
  a rounded colored face with a curved upper cutout, dark offset backing, an
  icon, title, body and trailing accent number.
- Added automatic numbering and four cycling face colors; width, height,
  backing color, text size and card colors are configurable. `backing-offset`
  accepts one length or independent `(x:, y:)` lengths. RTL mirrors the curved
  edge, backing offset, icon and number; print mode uses white faces, black text
  and rules. Added a dedicated print gallery with the matching LTR and RTL sets.
- Added a four-card example and individual PNG preview, plus the same four
  cards in RTL with Arabic text. Corrected the backing rectangle's upper-right
  corner curve and the database icon's white separator strokes; retained
  RTL/print regression coverage. Only this component's example/test sources
  were compiled.

## Local addition — folded PowerPoint-style banners (2026-09-26)

- Added and exported `folded-banner`: an adaptive, two-fold ribbon row with a
  numbered leading panel, shaded text band and optional caller-supplied icon.
  Numbers can count automatically or be supplied explicitly; the normal palette
  cycles through four reference colors.
- Mirrored panel geometry for RTL and added monochrome print styling without
  changing the banner's fold layout. Its optional shadow stays in place in
  grayscale; print-mode numbers and labels use black ink for legibility. Width,
  height, colors, typography, padding, fold proportions and shadow are
  configurable.
- Added a four-row example with included SVG icons, an RTL/print regression
  source, manual notes, and a compiled PNG preview.

## Documentation refresh and RTL audit (2026-09-26)

- Reworked `README.md` to distinguish the online 0.1.0 baseline from this
  0.3.0 source tree and summarize the intervening feature families.
- Added manual chapters for RTL alignment, print mode, sticky-note variants and
  the numbered header; refreshed the manifest metadata and local build notes.
- Audited `examples/rtl-boxes.typ`: logical text alignment, ticket/banner
  placement and forced LTR/RTL examples render as intended. Added clearance
  above the overhanging flag ribbon so it no longer collides with the section
  heading in the showcase.

## Local additions — monochrome print theme and RTL coverage (2026-09-26)

- Added `themes.print`, the `theme: "print"` spelling on `faboxyst`, and the
  scoped `print-group[...]` helper. Normal styles remain the default and are
  unchanged when print mode is inactive.
- Matched Blockst's monochrome print semantics: white primary surfaces and
  black borders/lettering; colored accents are neutralized. Shadow paints are
  converted from their source colors to gray without replacing their source
  tone, opacity, geometry or offset; no universal pale-gray shadow is applied.
- Wired the mode through the core content boxes and the stationery,
  numbered-header, sticky-note, callout, notebook, ornamental, teaching-card,
  scrapbook, fabox sign/note, full-page book covers, frieze bands and spread
  boxes. `book-cover` uses a consistent ink-friendly title-card layout only in
  print mode; its illustrated styles remain unchanged normally. Geometries and
  RTL mirroring remain active.
- Kept enabled drop shadows as grayscale layers. Joined the sticky-note's top
  semicircle to the frame as one continuous outline for both `postit` variants.
- Added RTL and broad print-mode regression sources: `tests/test-print-rtl.typ`,
  `tests/test-print-cover.typ`, `tests/test-print-all.typ`, and
  `tests/test-print-group.typ`; added `examples/print-mode.typ`.

## Local additions — butterfly shadow controls and garnet banner (2026-09-26)

- Added `postit-butterfly` alongside the existing simple `postit`, preserving
  the original version unchanged.
- The new variant uses faboxyst's native `shadow: "large"` lifted geometry.
  Its butterfly-shaped shadow sits inside the paper, shifted upward by its
  visible height + `2pt`. Bottom inset remains zero.
- Added a horizontal lifted-shadow gradient derived from the paper fill:
  default center `fill.darken(20%)`, endpoints `fill.darken(5%)`. To keep this
  color visible through the native translucent layers, only gradient paint
  opacity is boosted; the native silhouette and relative layer falloff remain.
  Both darkening percentages remain configurable.
- The earlier `55%` / `15%` trial read too olive against the yellow paper, so
  the defaults return to the requested, more hue-faithful values.
- Mixed a subtle rust-red tint (`#C64A2B`, `12%`) into the yellow shadow base
  to warm the gradient; the tint color and mix amount are configurable. Added
  direct `shadow-gradient-in` (center stop) and `shadow-gradient-out` (edge
  stops) color overrides.
- Lowered the center of the top circular sector by `0.03cm` by default; the
  circular arc and rounded frame now share one continuous outline, with no
  separate circle stroke or masking seam.
- Added the independent `garnet-box` style based on the reference image's
  rounded garnet banner, without copying its overall layout. It uses the
  standard postit's native `large` shadow, vertically mirrored into a centered
  downward bowl about 50% of banner width by default, with a softened profile,
  its center dropped slightly and tips meeting the lower edge—not the butterfly
  placement. Its paint combines a bright upper center with darker horizontal
  ends while leaving the native silhouette intact. The rounded face uses the
  native `shadow: "creuse"` inset rim. Its width now fits the content by default;
  configurable `width` and `inset` controls are available. Made RTL content
  explicitly right-aligned in both sticky-note variants and the garnet box.
- Added independent `numbered-header-box`: a square-cornered content panel
  with one fused outline around a rounded title band and a narrow trapezoid
  straddling the band 5% from the leading edge. Its wide base is on top; the
  centered circular badge supports automatic or explicit numbering. A small
  upper-left offset makes the tab read as a parallelogram. Width and inset
  adapt to content by default and remain configurable.
- The default paper-colored rule is omitted beneath the translucent shadow to
  avoid a pale stripe; custom rule colors remain visible above it.
- Exported the added components from `lib.typ`, with standalone examples and tests.

## Local patch to 0.3.0 — simple sticky note (2026-09-26)

- Added only `postit` (alias `study-postit`): rounded paper, a centered top
  circular sector with a matching outline, and a paper-colored lower rule.
- Uses faboxyst’s native `shadow: "large"` lifted shadow, in dark
  yellow-orange (`#C07800`) by default. The bottom inset is zero and the
  shadow endpoints meet the lower paper edge.
- Line and shadow lengths default to 93% of the note width and are configurable
  independently. Added direction-aware LTR/RTL and content-adaptive sizing.

## 0.3.0 — 2026-09-20 (content sizing and mark controls)

Focused maintenance update for the content boxes and inline marks.

- **Content-adaptive boxes** — `plankbox` now uses `width: auto` and
  `height: auto` by default, measures its body, caps an automatic width at
  the available line width, and preserves explicit lengths, ratios and
  heights. `leading:` is available directly on `plankbox`;
  `vintage-pen: (a, b, angle)` is forwarded by the vintage branch.
- **Other content boxes** — the affected content-box families expose
  `width: auto`, `height: auto` and `leading: 0.5em` defaults where their
  geometry permits it. Page, cover, pictogram and intrinsic-size decoration
  primitives are intentionally not generalized.
- **`mark` fill** (`src/fancy.typ`) — `fill:` selects the interior paint for
  closed `fan` marks and for the bracket background; `fill: auto` derives a
  translucent paint from `colour`, while `fill: none` preserves the old look.
- **`mark` inset** (`src/fancy.typ`) — `inset:` adds actual horizontal and
  vertical room around the text for the hand-drawn mark kinds. Pass a length
  for both axes or `(x: ..., y: ...)` for independent values.
- **Examples and tests** — `examples/mark-fill-inset.typ`,
  `tests/test-mark-fill.typ` and `tests/test-mark-inset.typ` cover the new
  controls; the focused tests compile with Typst 0.15.1.

## 0.3.0 — 2026-09-19 (update 3)

The *antique* vintage effect: vintage scientific illustration — aged
paper, sepia ink, a Garamond serif, and strokes drawn by an elliptical nib,
so the line thickens and thins with the path like a steel engraving.

- **`themes.antique`** (`src/theme.typ`) — the vintage register as a theme:
  the sepia palette (ink `#272119`, paper `#F3EAD9`), the Garamond-first
  font stack, `roughness: 0.35`, thin `stroke-weight`. One show rule
  (`#show: faboxyst.with(theme: themes.antique)`) restyles every box of the
  package.
- **`plate-page` / `planche`, `patent-page` / `brevet`** (`src/antique.typ`)
  — the two full-page styles (plate and patent):
  a plate with smallcaps number, 17pt Garamond title and italic subtitle; a
  patent page with office name, number and date above a full-width rule.
  Both are show rules that set the page (A4 by default, overridable) and the
  typography for the rest of the document.
- **Engraving** (`src/antique.typ`, strokes computed by nibart) — public API: `nib-pen`, `nib-stroke`, `nib-polylines`,
  `nib-line-path`, `nib-rect-path`, `polyline-path` (canvas-level), plus
  `engraved` (the shorthand) and two page-level conveniences:
  `engraved-rule` / `regle-gravee` (a calligraphic line between two points,
  plain, dashed or with periodic pressure) and `engraved-frame` /
  `cadre-grave` (a double engraved rule around content, with filled diamond
  corner marks; one canvas, does not break).
- **The `vintage:` parameter — engraved strokes on every family** —
  every box, frame, meter, pictogram and cover now accepts
  `vintage: true` (and `vintage-pen: (a, b, angle)` to override the
  default nib, derived from the stroke width). Only the *strokes* are redrawn with the elliptical nib:
  fills, the native palette and the layout are untouched, so a box
  keeps its own colours while its outline gains the steel-engraving
  thick/thin of a real pen. Default `vintage: false` everywhere.
  Covered: `leconbox`, `pinbox`, `brushbox`, `matierebox`; all ten
  `meter` styles (gauge, battery, bars, dots, pie, speedo, cible,
  chrono, thermo, steps); the pictogram sheet (`competence-crayon`,
  `banner-tri`, `highway-sign`, `sale-poster`, …); `vintageframe`
  (all eight styles) and `vintagebox` (all six plaques);
  `book-cover` (all ten styles — a double engraved rule around the
  whole cover); and the ornate/fancy families (`ringbox`, `ogeebox`,
  `sashbox`, `flagbox`, `gelbox`, `parchemin`, `scrapbook`,
  `bound-page`, …) — 55+ families in total.
- **The engraved register** (`src/antique.typ`) — `antique-palette`,
  `antique-fonts`, `figure-caption` / `legende-figure`, `antique-label` /
  `etiquette-gravee` (canvas labels on a paper-backed disc),
  `antique-notes` / `antique-note` (smallcaps heading + body).
- **Examples** — `examples/antique.typ` (the plate: engraved frame, a fabox
  under `themes.antique`, a labelled engraving, rule variants) and
  `examples/patent.typ` (the patent page with fabox / tip / warning).
- **`bicolor-bignum`** (`src/pictos.typ`) — the `bicolor-title` chevron
  box with the *bignumber* two-tone technique (ported from the simpleslides
  package): the title straddles the chevron boundary, drawn twice and
  reassembled from two clipped halves, and each half wears **the colour of
  the opposite side** — by default the part of the text on the leading
  parallelogram is drawn in `colour-b` and the part on the trailing one in
  `colour-a` (override either half with `ink-a:` / `ink-b:`). The box
  mirrors in RTL (leading side on the right), so one call writes correct
  bicolour titles in both directions; `direction:` follows the document by
  default. The `seam:` parameter bends the boundary where the two colour
  regions meet — `slant` (the default, the original chevron edge), `wavy`,
  `s`, `arc`, `zigzag`, `step` — with `seam-amp:` for the amplitude; the
  same curve drives both the background split and the two-tone text clip,
  so every letter stays on a background it contrasts with.
- **Manual & showcase** — a new chapter in `manual.typ`
  (`manual-antique.typ`), the what's-new pages and the pictos showcase
  updated; the licence section and the attribution note added to the README.

Licence: everything is MIT (see the manifest for the third-party notices).

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
 package **socialyst**.
- **`sashbox` / `ruban`** — folded ribbon banners (`flat` / `arch` / `hang`),
  with `incline` for the bow and `rough` for a closed sloppy-box outline.
- **`ticket` / `ticketbox`** — stub coupon, leading half-disc, trailing hole.
  Both features flip in RTL. Arabic-Indic / Persian digits become Western 0–9.
- Textbook plates: icon, crest, ribbon, helix, swoosh, circuit, key, ring,
  punch, planner, file, stub, stack, callout, tape, chalk, marker, screw.
- Universe-style English manual (`manual.typ` / `manual.pdf`).
