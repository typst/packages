// ─────────────────────────────────────────────────────────────────────────────
// Title / subtitle overflow detection + warning box (internal helper).
//
// A title that is too long wraps onto too many lines and breaks the cover
// layout. Rather than guess a character count — which can't account for differing
// glyph widths, smallcaps, or FR/EN/DE word lengths — we MEASURE the title.
//
// CONSISTENCY ACROSS DOCUMENT TYPES: a student usually reuses the same title for
// the thesis, report, poster, exec-summary, etc. If each cover counted lines at
// its OWN width/font, the same title could be flagged on the narrow thesis cover
// yet pass on the huge A1 poster — confusing. So the verdict is always measured
// against ONE reference cover: the **bachelor thesis**, the narrowest / strictest
// layout. A title that fits the thesis fits every other cover, so the warning is
// identical on every document. The box is still rendered in each cover's own
// layout; only the pass/fail decision is shared.
//
// The reference font is PINNED (not inherited) so the measurement is byte-identical
// regardless of which document's context runs it. Line budgets live in
// settings.typ. Paths here are relative to lib/.
// ─────────────────────────────────────────────────────────────────────────────

#import "settings.typ" as settings
#import "includes.typ" as inc
#import "i18n.typ": i18n
#import "fonts.typ": body-font

// ── Reference cover (the bachelor thesis) ───────────────────────────────────
// Width = thesis title wrap width: page 211mm − 12mm (page right margin) − 30mm −
// 12mm (pad left/right) = 157mm. Styles mirror the thesis title/subtitle renders
// (lib/pages/cover_bachelor.typ), with the font pinned to body-font.
#let _ref-width          = 157mm
#let _ref-title-style    = body => par(leading: 11pt, text(body, font: body-font, size: 24pt, weight: 660))
#let _ref-subtitle-style = body => par(leading: 11pt, text(body, font: body-font, size: 12pt))

// True when `body`, rendered through `style` and wrapped at `width`, occupies
// MORE than `max-lines` lines. MUST be called from within a `context` block (it
// uses measure()). The budget is a probe of exactly `max-lines` forced lines in
// the same styling, so there is no fragile height÷leading arithmetic.
#let exceeds-lines(style, body, width, max-lines) = {
  let probe  = range(max-lines).map(_ => [M]).join(linebreak())
  let budget = measure(style(probe), width: width).height
  let actual = measure(style(body),  width: width).height
  actual > budget + 0.5pt // epsilon absorbs float rounding at the boundary
}

// True when the title (resp. subtitle) would wrap beyond its line budget on the
// reference cover. MUST be called from within a `context` block.
#let title-too-long(title) = (
  title not in (none, "") and exceeds-lines(_ref-title-style, title, _ref-width, settings.max-title-lines)
)
#let subtitle-too-long(subtitle) = (
  subtitle not in (none, "") and exceeds-lines(_ref-subtitle-style, subtitle, _ref-width, settings.max-subtitle-lines)
)

// Builds the list of overflow issues (i18n'd content) for a document, empty when
// nothing overflows. The verdict is measured against the reference cover, so it is
// the same for every document type. lang defaults to the global-language state
// (set by project()); pass it explicitly for entry points that bypass project()
// and keep their own language (e.g. the poster).
//
// MUST be called from within a `context` block.
#let title-overflow-issues(title, subtitle: none, lang: auto) = {
  let lang = if lang == auto { inc.global-language.get() } else { lang }
  let issues = ()
  if title-too-long(title) { issues.push(i18n(lang, "title-too-long")) }
  if subtitle-too-long(subtitle) { issues.push(i18n(lang, "subtitle-too-long")) }
  issues
}

// Renders the red warning box (the bachelor completeness-box visual).
//   issues — list of content lines (one "— line" per entry)
//   header — bold red header line; defaults to the localised layout-warning header
//   width  — box width (covers differ; default fills the container)
//   font   — text font; when none, inherits the ambient font
//   scale  — multiplies every metric (sizes, inset, stroke, radius); >1 for the
//            A1 poster, where the A4-tuned default sizes would be illegibly small
//   lang   — language for the default header; auto = global state (see above)
#let overflow-warning-box(issues, header: none, width: 100%, font: none, scale: 1.0, lang: auto) = {
  context {
    let resolved-lang = if lang == auto { inc.global-language.get() } else { lang }
    let head = if header != none { header } else { i18n(resolved-lang, "layout-warning-header") }
    box(
      width: width,
      fill: rgb("#ffe3e3"),
      stroke: (2.5pt * scale) + rgb("#c1121f"),
      radius: 4pt * scale,
      inset: 10pt * scale,
      {
        set text(fill: rgb("#9d0208"))
        if font != none { set text(font: font) }
        text(weight: 900, size: 13pt * scale, head)
        v(4pt * scale)
        set text(size: 10pt * scale, weight: 500)
        for it in issues {
          block(below: 5pt * scale, [— #it])
        }
      },
    )
  }
}
