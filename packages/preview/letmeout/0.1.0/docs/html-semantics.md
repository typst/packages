# HTML feature mapping

The goal is to carry layout intent into the web platform. The package uses
selectable content, CSS sizing, normal document flow, and decorative vector
strokes. It does not measure a PDF page or turn document content into a picture.
All mappings below apply only to HTML. Paged exports retain the native elements.

This is the field reference for the overridden `grid`, `line`, and `align`
functions, the native grid subelements they adapt, and the native `page` and
`pagebreak` APIs interpreted by `#show: letmeout`. Native argument validation
and defaults still apply. The generated comments on the three wrapper functions
also include Typst's parameter types, defaults, and an HTML note for every
parameter. The main import preserves native set/show selectors; the `letmeout-extras.grid-*` aliases
refer to the native grid subelements.

## Grid

| Native feature | HTML interpretation |
| --- | --- |
| `columns` count / scalar / array | CSS column tracks; an empty definition means one automatic column. |
| `rows` count / scalar / array | CSS row tracks, repeating the final definition to fit placed cells. |
| `auto` tracks | Browser intrinsic sizing. |
| Fractional tracks | `minmax(0, Nfr)`; available width is shared without forcing the intrinsic minimum width of long content. |
| Absolute, font-relative, percentage, mixed lengths | CSS `pt`, `em`, `%`, and `calc(...)`, preserving responsive sizing. |
| `gutter`, `column-gutter`, `row-gutter` | Uniform lengths use CSS gaps. Varying, automatic, or fractional gutters become explicit tracks between content tracks. Axis-specific settings take precedence. The last gutter repeats. |
| Children | Flow into logical cells in row-major order. Empty slots become styled cells. Nested supported layouts remain HTML. |
| `inset` | Cell padding; scalar or side dictionary, including `x`, `y`, and `rest` shorthands. |
| `align` | Text and CSS container alignment, independently on both axes. |
| `fill` | CSS backgrounds for solid colors and supported gradients. `none` is transparent. |
| `stroke` | Decorative vector edges painted by CSS; supports side dictionaries, thickness, caps, dashes, phase, and supported gradients. |
| Styling arrays / functions | Arrays cycle by column; callbacks receive the logical `(x, y)` coordinates. Empty arrays use the property's default. |
| Cell `x`, `y` | Explicit CSS placement after resolving occupied cells. A single fixed coordinate finds the first available position on its other axis. Overlaps are errors. |
| Cell `colspan`, `rowspan` | CSS track spans, including intervening gutters. |
| Cell `inset`, `align`, `fill`, `stroke` | Overrides of grid-wide styling, including partial side/axis overrides. Unspecified values inherit. Explicit `none` removes paint/strokes. |
| Cell `breakable` | CSS `break-inside: auto` or `avoid`, for print/fragmentation. `auto` follows whether its rows contain an intrinsic track. This is a browser hint, not a pagination engine. |
| `grid.hline`, `grid.vline` | Grid-positioned vector separators, including partial ranges and automatic indices. They can cross gutters. |
| Line `position` | Chooses the edge before or after its logical row/column. Start/end follow RTL; left/right remain physical. |
| Stroke precedence | Explicit separators override cell edges; cell edges override grid defaults. Later separators replace earlier ones. An explicit `none` erases the affected edge. Equal-priority cell edges use the thicker stroke. |
| `grid.header`, `grid.footer` | Ordered layout cells with group metadata, rendered once in the continuous document. These are generic layout groups, not semantic HTML table sections. |
| Header/footer `repeat`, header `level` | Preserved as `data-grid-repeat` and `data-grid-level`. There are no page boundaries on a screen, so repetition and hierarchical page-header replacement do not run. They are available to host CSS/scripts as metadata. |

The DOM is sorted by logical row and column, so reading order follows visual
placement. A grid does not acquire ARIA table/grid roles: Typst grids also carry
no table semantics. Use a table for tabular data. Header/footer repetition during
browser printing is not implemented; CSS Grid has no equivalent of repeating
`thead`/`tfoot` groups. Sticky positioning is left to the host site rather than
being imposed on every document header.

Native `set std.grid(...)` and set rules on its subelements supply defaults.
Adapters replace native layout show transformations within their local HTML
scope. Arbitrary custom show transformations of grid/line/align/cell elements
are not composed with the adapters; style the emitted classes or their body
content instead. The wrapper functions themselves cannot be used as native
set/show selectors; see the naming limitation in reference.md.

### Grid fields and shared styling

`columns` accepts a count, a single track size, or an array. A count creates
automatic tracks; an empty array becomes one automatic column. `rows` accepts
the same forms; an empty array produces automatic rows as needed. Explicit rows
remain even when empty. Extra rows repeat the final row definition. Percentages
retain CSS sizing rules; a percentage row height needs a definite browser
block size to behave like a fixed height.

`gutter` supplies both axes; `column-gutter` and `row-gutter` override their
respective axis. Gutter arrays repeat their last entry, rather than cycling;
an empty array means zero. A single fixed/relative length uses a CSS gap.
Multiple entries, `auto`, and fractions use interleaved tracks, so spanning
cells also span the intervening gutters.

Each of `inset`, `align`, `fill`, and `stroke` accepts a uniform value, an array
cycling by column (`x % array.len()`), or a function called with zero-based
`(x, y)`. For spanning cells those are the top-left logical coordinates.
Unoccupied slots become cells and receive these styles too. Empty arrays use
zero padding, no explicit alignment, transparent fill, or no stroke, respectively.
`children` are placed row by row, respecting explicit cell coordinates, spans,
and group boundaries; the emitted DOM is sorted by logical row and column.

### `grid.cell` / `letmeout-extras.grid-cell`

| Field | HTML behavior |
| --- | --- |
| `body` | Selectable content in the cell's inner block; nested supported layouts remain HTML. |
| `x` | Zero-based logical column. `auto` searches for a free column; with an explicit `y`, searches that row from the first column. Logical columns run from the start side of the text direction. |
| `y` | Zero-based row. `auto` searches for a free row; with an explicit `x`, searches that column from the first row. When both coordinates are automatic, placement follows the row-major cursor. |
| `colspan` | Number of logical columns occupied, including any intervening gutter tracks in the CSS span. Must be positive and fit the grid. |
| `rowspan` | Number of logical rows occupied, including intervening gutters. Must be positive; creates additional rows when needed. Overlapping occupied slots are errors. |
| `inset` | CSS padding. `auto` inherits the grid inset. A length replaces all sides; a dictionary replaces named sides, using `top`/`right`/`bottom`/`left` before `x`/`y` before `rest`. Unspecified or automatic sides inherit. Use `0pt` to remove padding. |
| `align` | Overrides cell text/container alignment. `auto` inherits the grid value; a single-axis override keeps the grid's other axis. Horizontal physical/logical and vertical alignment behave as in `align` below. |
| `fill` | CSS background. `auto` inherits the grid fill; `none` removes it; a color or supported gradient replaces it. |
| `stroke` | Cell edge strokes. `auto` inherits grid strokes; `none` erases all cell edges. Side dictionaries override individual sides; omitted sides and automatic stroke fields inherit. See the shared stroke reference below. |
| `breakable` | `true` emits `break-inside: auto`; `false` emits `break-inside: avoid`. `auto` permits breaks if any spanned row has an `auto` track, otherwise avoids them. A browser fragmentation hint; no effect on continuous screen flow. |

Native set rules on `std.grid.cell` supply defaults before explicit fields are
folded in. Cell show-set rules can style the body using its resolved `x`/`y`.

### `grid.hline` / `letmeout-extras.grid-hline`

| Field | HTML behavior |
| --- | --- |
| `y` | Zero-based row edge index. `auto` uses the row after the last fully automatically placed cell, or zero before any such cell. An explicit index can reach the grid's final edge. |
| `start` | Zero-based starting column, inclusive; defaults to zero. |
| `end` | Ending column, exclusive; `none` extends to the final column. The range must be nonempty and within the grid. Crosses intervening gutters. |
| `stroke` | Decorative stroke overriding cell/grid edges along the range. `none` erases those edges. Later separators replace earlier ones on shared segments. All shared stroke fields below apply. |
| `position` | `top` selects the edge before row `y`; `bottom` selects the edge after that row. With a gutter these are different edges. `bottom` requires an existing row. |

### `grid.vline` / `letmeout-extras.grid-vline`

| Field | HTML behavior |
| --- | --- |
| `x` | Zero-based logical column edge index. `auto` uses the column after the last fully automatically placed cell, or zero before any such cell. An explicit index can reach the grid's final edge. |
| `start` | Zero-based starting row, inclusive; defaults to zero. |
| `end` | Ending row, exclusive; `none` extends to the final row. The range must be nonempty and within the grid. Crosses intervening gutters. |
| `stroke` | Same stroke fields and edge-erasing/precedence behavior as `grid.hline`. |
| `position` | `start`/`end` select the logical edge before/after column `x` and follow text direction; `left`/`right` stay physical. Selecting the edge after a column requires an existing column. |

Separators add no cells and do not move the placement cursor. Automatic
separator indices refer to the last cell whose **both** coordinates were
automatic, rather than the most recent explicitly or partially placed cell.
With zero gutters adjoining edges collapse. Explicit separators take priority
over explicit cell strokes, which take priority over grid defaults. Among cell
edges of equal priority the thicker wins (later cells win equal thickness).

### `grid.header` / `letmeout-extras.grid-header` and `grid.footer` / `letmeout-extras.grid-footer`

| Element / field | HTML behavior |
| --- | --- |
| Both: `children` | Cells and separators are flattened into the grid at their group position; boundaries advance the placement cursor to a fresh row. Cells get `data-grid-group="header"` or `"footer"`. No semantic table section or sticky behavior is added. |
| Both: `repeat` | Recorded on cells as `data-grid-repeat`. Content renders once; neither screen flow nor browser printing repeats the group. |
| Header: `level` | Recorded on cells as `data-grid-level`. No hierarchical replacement happens without page boundaries. Footer/body cells use level zero. |

Native set rules on headers, footers, and separators supply their defaults.

## Align

| Native feature | HTML interpretation |
| --- | --- |
| `left`, `center`, `right` | Physical text alignment and CSS `justify-items`. |
| `start`, `end` | Logical alignment with an explicit `dir` and language on the wrapper. |
| `top`, `horizon`, `bottom` | CSS `align-content: start / center / end`. |
| Combined axes | Both mappings apply to the same block container. |
| A single axis | The specified axis changes; unspecified axes fold with the native outer alignment default. |
| Nested alignment | Nested containers allow the group position and its inner text alignment to differ. |
| Default / native set rules | Resolved from `std.align` by the HTML show adapter. |
| Paragraph boundaries | A block element, matching the function's block-level intent. |
| Vertical page space | No artificial page or viewport height. Alignment has a visible vertical effect when an enclosing layout supplies free space. |

The wrappers preserve the browser's content flow and links. They do not
automatically center the entire document in the viewport.

## Line

| Native feature | HTML interpretation |
| --- | --- |
| `start` | Physical `(x, y)` offset into a container spanning the available inline width. |
| `end` | Explicit endpoint; takes precedence over `length` and `angle`. |
| `length` | A responsive length, defaulting to the native 30pt. |
| `angle` | Clockwise geometric direction, including vertical and reversed lines. |
| Relative coordinates | Percentages on **both axes** use the container's inline width. This gives a stable geometric reference in an intrinsically tall web document. It deliberately does not use page height or viewport height. |
| Absolute / `em` / mixed coordinates | CSS lengths and arithmetic, retaining their responsive components. |
| `stroke.paint` | CSS solid or gradient paint through an SVG mask. |
| `stroke.thickness` | The geometric stroke width, resolved with the current font size. |
| `stroke.cap` | SVG butt, round, or square caps; the mask allows a half-stroke outside each endpoint. |
| `stroke.dash` | Native named patterns, arbitrary arrays, `dot`, and dictionary `array`/`phase`. |
| `stroke.join`, `miter-limit` | Retained in the SVG mask. A straight segment has no corner for these to change. |
| Set rules | Resolved from `std.line`. |

A line is a decorative block in normal HTML flow, hidden from assistive
technology. It is not automatically an `hr`: a geometric stroke does not imply
a thematic break. Positive vertical extent reserves space in the flow; negative
coordinates can overflow its box. The line itself follows physical coordinates,
independent of text direction.

### Shared stroke fields

These fields apply to `line.stroke`, grid/cell strokes, and separator strokes.
For grid/cell strokes, an outer dictionary may select `top`, `right`, `bottom`,
`left`, `x`, `y`, and `rest`; explicit sides beat axis shorthands, which beat
`rest`. These are physical sides, including in RTL. Each side accepts a stroke
value or a dictionary of the fields below. A cell's unspecified/automatic
fields inherit its grid stroke; otherwise automatic fields resolve to black,
`1pt`, butt caps, miter joins, no dash, and miter limit 4.

| Field | HTML behavior |
| --- | --- |
| `paint` | CSS background through an SVG stroke mask. Solid colors and supported gradients work; unsupported tilings and gradient geometry fail explicitly. Colors use the document's light/dark policy. |
| `thickness` | SVG stroke width and CSS stroke box thickness. Font-relative lengths resolve at the current Typst font size. |
| `cap` | SVG `stroke-linecap`: `"butt"`, `"round"`, or `"square"`. The mask allows half a stroke beyond each endpoint for projecting caps. |
| `join` | SVG `stroke-linejoin`. Retained, but these drawings are separate straight segments, so it does not produce corner joins between grid edges. |
| `miter-limit` | SVG `stroke-miterlimit`. No visible effect without a joined corner. |
| `dash` | Native named patterns are normalized by Typst. `none`/resolved `auto` is solid; an array or dictionary supplies a custom pattern. Maps to SVG `stroke-dasharray`. |
| `dash.array` | Alternating painted/gap lengths; lengths resolve at the current font size. A `"dot"` entry becomes one stroke thickness. |
| `dash.phase` | Pattern offset, mapped to SVG `stroke-dashoffset`, preserving the native resolved length. |

Grid `stroke: none` removes edges; cell or separator `stroke: none` can erase
lower-priority edges. `line` uses Typst's native stroke argument contract.

## Paint, CSS, and deliberate limits

Solid colors convert to sRGB. Linear, conic, and concentric radial gradients
become CSS gradients. Additional stops sampled in Typst's chosen interpolation
space approximate spaces the browser cannot represent; original stops and hard
transitions are retained. Browser gradient geometry follows CSS conventions.
Parent-relative gradients and off-center radial focal circles currently produce
an explicit diagnostic. Arbitrary Typst tilings also produce a diagnostic: their
layout-bearing content is not exposed as a reusable CSS image by Typst. Use a
host background image for that case. These limits apply equally to fills and
stroke paints; nothing is silently replaced with a solid color.

The generated CSS needs a browser with CSS Grid, container query length units,
CSS masks, and CSS math functions `hypot()` and `atan2()`. It does not require
JavaScript or a runtime library. Host styles can customize `.letmeout-grid`,
`.letmeout-grid-cell`, `.letmeout-align`, `.letmeout-line`, and
`.letmeout-stroke-paint`.

The native parameter contracts were checked against Typst's documentation for
[grid](https://typst.app/docs/reference/layout/grid/),
[align](https://typst.app/docs/reference/layout/align/),
[line](https://typst.app/docs/reference/visualize/line/),
[stroke](https://typst.app/docs/reference/visualize/stroke/), and
[target](https://typst.app/docs/reference/foundations/target/).

## Page

Page support needs `#show: letmeout` at the top of the document. We recommend
`#show: page.with(...)` over `set page`. `letmeout-extras.page` is native `page` with a
note on each parameter in its doc comment; it passes on only the arguments
given, so its output is identical in every format. HTML is one
continuous document, so page settings become one block rather than a series of
sheets. Content never moves to another page, and the package adds no
screen-sized pages. A new block starts only where the page settings change:
at a `set page`, `page(...)[...]`, or `show: page.with(...)` with different
values. Each block has this structure:

```
section.letmeout-page                full width; fill
└ div.letmeout-page-sheet           centred; max-width = page width
  ├ div.letmeout-page-background    layer behind the content
  ├ header.letmeout-page-header     top margin, before the content
  ├ div.letmeout-page-body          the content
  ├ footer.letmeout-page-footer     bottom margin, after the content
  └ div.letmeout-page-foreground    layer above the content
```

| Native feature | HTML interpretation |
| --- | --- |
| `paper` | Supplies native width and height from the named paper size. Explicit dimensions override their corresponding paper dimension. The resolved width caps the sheet; the height also supplies the reference for vertical percentage margins. |
| `width` | Maximum width of the centred sheet. On narrower screens the sheet fills the available width. `auto` removes the cap. After `flipped`, the swapped dimension supplies this width. |
| `height` | Does not constrain the block's height; content determines it. Still used to resolve vertical percentage margins and automatic margins, and becomes the width when `flipped` is true. |
| `flipped` | Swaps width and height, so it changes the sheet width. |
| `margin` | Padding on the sheet, with Typst's defaults (2.5/21 of the shorter side), folding, `x`/`y`/`rest`, and ratios. With a fixed width, every margin is a fraction of the sheet width (`cqi`). It equals the declared length at full width and shrinks on narrower screens. |
| `binding` | There are no facing pages, so the first page's layout applies. `left` puts an `inside` margin on the left; `right` puts it on the right. `auto` chooses left for LTR and right for RTL. Physical `left`/`right` margins stay physical. |
| `fill` | Background of the full-width block. `auto` is transparent, so host colours and dark mode are not overridden; set a fill for a paper colour. |
| `header` | Content in a `<header>` before the body, once per block, bottom-aligned within the top margin. `none` removes it. `auto` uses page numbering only when `number-align` selects the top, otherwise no header. Explicit content replaces automatic numbering here. Taller content grows the margin. |
| `header-ascent` | Gap below header content, resolved relative to the top margin and emitted as bottom padding. Scales with the sheet width when it is fixed. |
| `footer` | Content in a `<footer>` after the body, once per block, top-aligned within the bottom margin. `none` removes it. `auto` uses page numbering unless `number-align` selects the top. Explicit content replaces automatic numbering here. Taller content grows the margin. |
| `footer-descent` | Gap above footer content, resolved relative to the bottom margin and emitted as top padding. Scales with the sheet width when it is fixed. |
| `numbering` | `none` disables automatic numbers. A pattern/function is passed to `counter(page).display`; patterns with multiple counting symbols and numbering functions request the total too. HTML has one page and blocks/breaks do not advance the counter. Explicit `counter(page).update` still works. |
| `number-align` | Horizontal component aligns automatic numbers. A vertical component of `top` chooses the automatic header; other values choose the footer. Does not reposition explicit header/footer content. |
| `background` | Content in an absolutely positioned layer behind the sheet's content, centred on both axes and clipped to the sheet. `none` omits it. Hidden from assistive technology and does not intercept clicks. |
| `foreground` | Same geometry as `background`, above the content. `none` omits it. Hidden from assistive technology and does not intercept clicks. |
| `columns` | CSS columns with the `columns.gutter` gap. Columns are at least `12em` wide, so they collapse on narrow screens. |
| `page(...)[...]` | Its own block with its own settings, inheriting the surrounding settings. Content before and after it forms separate blocks, each with its header and footer. |
| `bleed` | No screen layout effect; no trim box or bleed area is created. Fill already covers the full-width block. |
| `supplement` | No screen layout effect; the adapter does not create page references or render a supplement. |
| `body` | Selectable HTML inside the sheet's body, using its padding and optional CSS columns. A native page call gets its own block, inheriting surrounding settings. |

`margin` accepts a uniform length/ratio or a dictionary. `top` and `bottom`
override `y`; horizontal sides override `x`; `x`/`y` override `rest`. The
`inside`/`outside` pair selects binding-relative horizontal margins. Omitted
sides fold with inherited margins. `auto` sides use 2.5/21 of the shorter
nonautomatic paper dimension (210mm if both dimensions are automatic).
Horizontal percentages resolve against width and vertical percentages against
height; an automatic dimension leaves its percentage relative to sheet width.
For a fixed sheet width, resolved geometry becomes `cqi`, including absolute
lengths. With automatic width, absolute parts stay in points and percentage
parts use `cqi`. Font-relative lengths resolve at the current Typst font size.

### How `set page` is read

A set rule runs no code, and its styles cannot be inspected or separated from
other set rules, so the package cannot intercept it. Instead, `letmeout` places
an invisible probe under every style node, and the probe records the page
settings in effect there. Typst's introspection reads the probes back, and the
document is split only at style nodes whose page settings differ. Inline
styles such as `text(red)[...]` therefore stay inside their paragraph.

Two Typst rules shape the result:

- Page styles are not allowed inside an HTML element. A style node that
  changes the page settings therefore wraps its blocks instead of sitting
  inside one. A `set page` that repeats the current values exactly is not
  detected and fails with "page configuration is not allowed inside of
  containers"; remove the redundant rule.
- `set document` must come before any content. Set rules at the start of the
  document therefore stay outside all blocks, and `#show: letmeout` must come
  first.

A `context` hides its content from the probes. This happens when a show rule
after `#show: letmeout`, often a template, wraps the rest of the document in
`context`. Page settings inside one cannot become blocks, so HTML export shows
a `div.letmeout-error` card that stays at the top of the screen, followed by
the content without its page settings, instead of failing. Typst does not give
packages source lines, so the card quotes the start of the first affected
heading or paragraph instead; math is left out of the quote. Paged output is unchanged. To fix it, move
`#show: letmeout` below the template's show rule, or set the page before it.
Each `context` item is checked on the first layout pass, outside the blocks.
Contexts without page settings stay in their block, and inline ones stay in
their paragraph.

Typst prints "page set rule was ignored" for page styles in HTML export.
Packages cannot silence warnings, but the settings are applied.

A block sets `break-before: page` and `break-after: page`, so each block starts
on a new sheet when the HTML is printed.

## Target-specific settings

The target and color-scheme helpers below are exported through `letmeout-extras`. Use
`letmeout-extras.name` or explicitly import selected names with `#import letmeout-extras: name`.


`by-target(html:, paged:)` accepts either content branches or function
branches. Content is selected in a context block; functions produce a show rule
for `#show: by-target(html: body => { ...; body })`. A missing content branch is
empty; a missing function branch is identity. Mixed content/function branches
are rejected. `html-only(value)` and `paged-only(value)` supply a single branch. A native
`.with()` function can be passed directly, such as
`#show: html-only(page.with(width: auto))`. This keeps native wrapper semantics.
The previous `on-target` and `show-target` names remain compatibility aliases.

Page settings use native `set page` inside the target function. A context block
alone would hide those set rules from the document probes. The function form
therefore returns an invisible `metadata` marker holding the HTML rule and body,
followed by a context fallback. `#show: letmeout` runs in HTML, finds markers at
the document level (in sequences and style nodes), applies the HTML rule directly,
and drops the fallback. Page settings then become ordinary style nodes, and
blocks split as for `set page`. Markers nested inside other elements, or a
document without `#show: letmeout`, use the context fallback.

`by-color-scheme(light:, dark:)` selects content by color scheme. `light-only`
and `dark-only` supply a single branch. In HTML, the existing light/dark elements
and document color-scheme rules control visibility. Paged output returns only
the light branch. These helpers select content; `theme` controls scoped colors
and frame policy.

## Pagebreak

With `#show: letmeout`, a native `pagebreak` adds nothing on screen: the content
continues in the same block, with no gap, repeated header, or new page number.
A strong break renders an empty, hidden `div.letmeout-pagebreak` with
`break-before: page`, so a printer breaks there. `to: "odd"` / `"even"` become
`recto` / `verso`. Weak breaks, including the ones a `page` call adds around
its body, render nothing: a block already starts on a new printed sheet.

| Field | HTML behavior |
| --- | --- |
| `weak` | `true` emits nothing. `false` emits a hidden print-break element with no screen gap. Neither starts a new page block, repeats marginal content, nor advances the counter. |
| `to` | For a strong break, `none` emits `break-before: page`, `"odd"` emits `recto`, and `"even"` emits `verso`. A print hint interpreted by the browser, with no screen effect. Ignored for weak breaks. |

## Document and screen adapters

`letmeout` accepts these fields in `#show: letmeout.with(...)`. Its `body` is
the remainder of the scope, supplied automatically by the show rule.

| Field | HTML behavior |
| --- | --- |
| `body` | Resolves target-specific show rules, reads page settings, emits continuous page blocks, and applies font, color, MathML, and frame handling below. |
| `color-scheme` | Default `"light dark"` follows the reader. `"light"` or `"dark"` fixes the scheme. Sets CSS `color-scheme` and a `Canvas` background; `none` omits both and emits no dark visibility/frame rules. |
| `dark-colors` | Default `()`. Array of `(light-color, dark-color)` pairs replacing automatically derived dark variants through CSS custom properties. Applies to colors written by the adapters, including gradient stops; no recoloring of frame internals. Nested `letmeout-extras.theme` mappings inherit and override by color. |
| `dark-frames` | Default `"invert"` applies `invert(1) hue-rotate(180deg)` to framed SVG in dark mode. `none` preserves frame colors. The policy inherits through scoped themes. |
| `css` | Default empty string. Appended to the emitted document stylesheet as supplied; can style emitted classes or override document rules. |

The screen adapters also intercept the following native elements. They preserve
their other fields and let Typst's HTML exporter handle them:

| Native element / fields affected | HTML behavior |
| --- | --- |
| `text`: `size`, `weight`, `style`, `tracking` | CSS `font-size`, `font-weight`, `font-style`, and `letter-spacing`, from contextual native values. Initial settings go on the body; differing text gets spans. |
| `par`: `leading`, `spacing` | Measured text height plus leading supplies line height. Paragraph wrappers collapse their spacing with adjacent paragraphs, blocks, and grids; explicit block edges override automatic spacing. Text-box trimming excludes leading from the first/last line edges. Strong vertical space adds to the boundary gap. Half the leading goes above and below inline boxes; their own compact text height leaves `inset` unaffected. |
| `text`: `font` | The initial document font list becomes `body`'s `font-family`; differing text gets a span. Fonts must be installed in the browser environment or supplied through CSS `@font-face`; font files are not embedded. Font dictionaries contribute their `name`; other dictionary options are not converted into CSS font-selection rules. |
| `text`: `fill` | The initial fill becomes body text color. Differing solid colors get spans using the light/dark color conversion. Non-color local fills get no extra span or paint conversion from this adapter. |
| `math.equation`: `body`, `supplement` | Body text is exempt from the font/color spans to preserve native MathML. A local internal supplement marker controls this exemption; the equation's supplement for references, numbering, and other fields remain native. |
| `html.elem`: `tag`, `body` | For `script`, `style`, `title`, and `textarea`, body text uses the root text settings so the text adapter adds no spans. Tag, attributes, and native plain-text content are preserved. Other tags use native export. |
| `html.frame`: all fields | The native frame is retained inside a `letmeout-frame` element that preserves its inline/block position and contextual font size, so native `em` dimensions resolve correctly. SVGs shrink proportionally to fit their container, overriding the exporter's inline height. Frame rendering fields remain native; the surrounding dark-mode CSS filter follows the theme. |
| `image`: `width`, `height`, `fit` | The native `<img>` is kept inside a `letmeout-image` element (`display: contents`). Typst writes the pixel size as `width`/`height` attributes, which browsers treat as a CSS size, so a side left `auto` is reset to `auto` and follows the aspect ratio, as in PDF. With neither side set the image is scaled down to fit its container. A fixed height that is too wide for the screen shrinks inside its box (`object-fit: contain`). With both sides set, `fit` maps to `object-fit`: `"cover"` → `cover`, `"contain"` → `contain`, `"stretch"` → `fill`. |
| `place.flush`: no fields | Omitted in HTML: native page calls add this invisible flush, and continuous blocks already end their printed page. |
| `math.equation` (block), `raw` (block), `table`; `grid` with a fixed-width column; `rect`, `square`, `circle`, `ellipse`, `block` with a fixed width | Wrapped in a `div.letmeout-scroll` that scrolls sideways when the content is wider than the screen; the scrollbar only appears then. Neighbouring ones, with only spaces, breaks, or invisible elements between them, share one scroll area, so a run of wide equations has a single scrollbar. Grouping reads the arguments written at the call; a width from a set rule still gets a scroll area of its own. A scroll area inside another does not scroll on its own. Runs inside a `context`, such as a template's, are hidden from letmeout: each element there scrolls on its own unless `#show: letmeout` comes after the template. The area leaves room for strokes and outsets that reach past a shape (`--letmeout-bleed`). The outer margins of code blocks are removed so the spacing stays the same, and print shows the full width. |
| `box` with a fixed width | Wrapped in a `span.letmeout-scroll-inline` (`inline-flex`, so the box keeps its baseline) that is at most as wide as its line and scrolls sideways. |
| Page | The page itself never scrolls sideways: `body` and each page clip horizontal overflow (`overflow-x: clip`). |

The screen adapter also removes the browser's default body margin and adds dark
variants for Typst's default raw-code palette. A custom raw theme keeps its own
colors. These screen rules require `#show: letmeout`; the three layout wrappers
work without it. Paged bodies and native element arguments are passed through.

## More elements

With `#show: letmeout`, show rules adapt these native elements in HTML. Inside
`html.frame` and in paged output they stay native. Each adapter keeps Typst's
native HTML, including the "was ignored" warning, for anything it cannot
express; it never fails where Typst would not. Colors use the document's
light/dark policy.

### Shapes, boxes, and blocks

`rect`, `square`, `circle`, and `ellipse` become a `div` (class
`letmeout-<name>`); `box` a `span` with `display: inline-block` and `block` a
`div` (classes `letmeout-box`, `letmeout-block`). The content stays selectable
HTML. Paint sits in an absolutely positioned `span.letmeout-shape-paint` behind
it, so neither stroke nor outset changes the layout, as in Typst.

| Field | HTML behavior |
| --- | --- |
| `width`, `height` | CSS sizes, with the box including the inset. Shapes without content get Typst's default size (45×30pt, squares and circles 30pt). A shape with content and automatic width fits its content. Fractional box widths share the remaining paragraph width using flex weights, including boxes containing heading rules. Other fractional sizes are dropped. |
| `size`, `radius` (circle) | Become `width` and `height`; `square` and `circle` keep `aspect-ratio: 1` when a side is automatic. |
| `fill` | Background of the paint layer. Colors and supported gradients; other paints keep native output. |
| `stroke` | Centred on the outline. `auto` on shapes is 1pt black without a fill and none with one. Uniform dashed strokes use an SVG mask with the exact pattern; gradient strokes without dashes use a masked ring; other strokes use CSS borders per side, where dashes become `dashed` or `dotted`. |
| `radius` | Per-corner CSS `border-radius`. Ratios are relative to half the shorter side, through `cqmin` on the paint layer. |
| `inset` | Padding. Circles and ellipses add the margin of the inscribed rectangle, exactly for fixed sizes and approximately (`0.25em`) for automatic ones. |
| `outset` | Extends the paint layer without changing the layout. |
| `clip` | `overflow: clip` with the corner radii. |
| `block.breakable` | `false` emits `break-inside: avoid`. |
| `block.above`, `block.below` | Collapsing margins; `auto` uses the contextual paragraph spacing. Explicit edges override adjacent automatic spacing, including zero. Outside spacing is removed at the start/end of a containing flow. |
| `box.baseline` | A length shift becomes `vertical-align`; a ratio needs a length height. |
| `block.spacing` | Native shorthand for `above` and `below`; their resolved values supply the margins. |
| `block.sticky` | No effect. |

A `box` or `block` without fill, stroke, inset, size, clip, or spacing keeps
Typst's native `<span>` or `<div>`.

### Spacing and layout

| Element | HTML behavior |
| --- | --- |
| `h` | An empty `span.letmeout-h` with `margin-inline-start`; negative amounts work. Fractions stay native. |
| `v` | An empty `div.letmeout-v` with a height. A weak or negative amount becomes `margin-top`, which collapses with neighbouring margins like weak spacing. Fractions stay native. |
| `pad` | `div.letmeout-pad` with padding per side; negative sides become negative margins. |
| `hide` | `visibility: hidden` on a `span`, or a `div` for block content. The content keeps its space and is hidden from screen readers. |
| `move` | `position: relative` with `left: dx` and `top: dy`; ratios use the container. |
| `rotate`, `skew` | CSS `transform` around `origin`, on a block as wide as its content. `reflow` is not applied. |
| `scale` | CSS `scale(x, y)` around `origin`. With `reflow: true` and one positive factor, CSS `zoom` reflows the layout. Lengths need the content's size and stay native. |
| `stack` | A flex box: `ltr`/`rtl` are physical, also in RTL text, `ttb`/`btt` vertical. `spacing` goes between adjacent content; length and fraction children become fixed and growing spacers. |
| `columns` | `column-count` with `column-width: 12em` and the gutter as `column-gap`, so columns collapse on narrow screens. |
| `colbreak` | An empty `div` with `break-after: column`. |
| `place` | `float: true` keeps the content in the flow with `clearance` as margin, aligned horizontally. Otherwise `position: absolute` in the nearest positioned container: the page body, a shape, or a styled box or block. Without a vertical alignment the content stays at its height in the flow. `dx` and `dy` become `translate`. |
| `polygon`, `curve` | Native SVG in an `html.frame`, following the frame dark-mode policy. |

`layout` callbacks become native SVG frames, preserving their paged geometry, including third-party decorations and images. SVG frames shrink to fit their HTML container. Text inside these frames is SVG, not selectable HTML. `repeat` still needs Typst's region sizes and is not adapted.

### Text decorations

| Element | HTML behavior |
| --- | --- |
| `underline`, `overline`, `strike` | With a custom `stroke` or `offset`, a `span` with `text-decoration-color`, `-thickness`, `-style` (`dashed`/`dotted`), and `text-underline-offset`. Gradient paint and the defaults keep native output. `extent`, `evade`, and `background` have no effect. |
| `highlight` | A `mark` with the fill as background and the text color kept. Lengths in `radius` and `extent` become `border-radius` and `padding-inline`. `stroke`, `top-edge`, and `bottom-edge` have no effect. |

HTML links suppress the browser's default underline, preserving explicit Typst
underlining. Grids with fixed/fractional tracks and fixed/relative gutters use a
container query based on their minimum track width: fitting layouts allow ink
overflow, including SVG shadows, while oversized layouts remain scrollable.
Automatic tracks retain the scroll fallback because their minimum depends on
content.

Grid cell bodies use normal block flow, so sibling margins collapse and a tall
row does not distribute spare height between children. A sole explicit alignment
element retains stretching for vertical positioning. Mixed-style inline cell
runs retain paragraph leading when they wrap; padded inline content and boxes
use compact native text metrics. Grids carry the contextual paragraph spacing
outside their scroll wrappers. Text-only blocks read their own styled
text context: `ascender`/`cap-height`/`x-height` map to CSS `text`/`cap`/`ex`.
Both `baseline` and `descender` trim to CSS `alphabetic`; `descender` adds the
descent measured by Typst as bottom padding. This avoids WebKit trimming the
descenders despite accepting `text-box-edge: cap text`.
Other edges keep a measured line-height fallback. This removes browser text-box
space around stacked display blocks while retaining explicit block heights.
Paragraph and text-block containers carry the contextual font family, weight,
and style as well as size, so trimming uses the visible text's font metrics.
Browsers without `text-box-trim` use a normal line height for text blocks to
reserve space for the browser font's ascenders and descenders.
