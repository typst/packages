#import "defaults.typ": merge, validate-config

// Shared cover page — a composable layout plus ready-to-use title-page styles.

/// Built-in cover palettes as a dictionary keyed by palette name:
/// `neutral`, `slate`, `soft-jade`, `soft-slate`, `warm-editorial`, `plum`, and
/// `soft-rose`.
///
/// Each value contains `bg-paper`, `brand-primary`, `brand-accent`, `text-main`,
/// and `text-muted`. Covers keep tinted paper in every palette except neutral.
/// Accents are grayscale, jade, slate, warm brown, plum, and rose. The accent is
/// used for cover rules and accents.
#let cover-themes = (
  neutral: (
    bg-paper: rgb("#FFFFFF"),
    brand-primary: black,
    brand-accent: black,
    text-main: black,
    text-muted: black,
  ),
  slate: (
    bg-paper: rgb("#f8fafc"),
    brand-primary: rgb("#1d293d"),
    brand-accent: rgb("#0f172b"),
    text-main: rgb("#020618"),
    text-muted: rgb("#90a1b9"),
  ),
  soft-jade: (
    bg-paper: rgb("#FBFAF7"),
    brand-primary: rgb("#355D50"),
    brand-accent: rgb("#B8C9BE"),
    text-main: rgb("#282D29"),
    text-muted: rgb("#59665F"),
  ),
  soft-slate: (
    bg-paper: rgb("#FBFAF7"),
    brand-primary: rgb("#344B55"),
    brand-accent: rgb("#BCC9CC"),
    text-main: rgb("#282B2C"),
    text-muted: rgb("#59636A"),
  ),
  warm-editorial: (
    bg-paper: rgb("#FBF8F2"),
    brand-primary: rgb("#654A3B"),
    brand-accent: rgb("#D8C4B3"),
    text-main: rgb("#2F2A26"),
    text-muted: rgb("#665F58"),
  ),
  plum: (
    bg-paper: rgb("#FBF8FB"),
    brand-primary: rgb("#674666"),
    brand-accent: rgb("#D3C3D4"),
    text-main: rgb("#302A31"),
    text-muted: rgb("#685F69"),
  ),
  soft-rose: (
    bg-paper: rgb("#FCF8F8"),
    brand-primary: rgb("#713C4A"),
    brand-accent: rgb("#D8BEC4"),
    text-main: rgb("#302A2C"),
    text-muted: rgb("#6B5D61"),
  ),
)

/// Baseline values consumed by `cover-page()` before theme and user overrides.
///
/// The cover starts on A4 with 2.5cm margins, Libertinus Serif at 11pt, and the
/// neutral black-on-white palette. Cover `config` is merged on top of these
/// values after the selected theme; only page paper/margins, text font/size, and
/// the five cover colors are consumed by the renderer.
#let cover-defaults = (
  page: (
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
  ),
  typography: (
    font: "Libertinus Serif",
    size: 11pt,
  ),
  colors: cover-themes.neutral,
)

/// Build an optional cover page, either from custom content or title fields.
///
/// This is a component, not a document template: place it before `report`, or
/// anywhere else a cover is wanted. It has no implicit connection to another
/// template's `config` or `theme`; pass those values explicitly when the cover
/// should share the document appearance.
///
/// Appearance precedence is cover defaults, then the selected cover `theme`,
/// then `config`. `config` may contain normal shared Satz settings, but the
/// cover consumes only `page.paper`, `page.margin`, `typography.font`,
/// `typography.size`, and `colors.bg-paper`, `brand-primary`, `brand-accent`,
/// `text-main`, and `text-muted`. Other valid shared settings are accepted and
/// ignored. Known config groups are validated for misspelled keys.
///
/// The default `classic` layout preserves the slot-based cover. Set `layout` to
/// `"research"` or `"minimal"` and provide `title` to use a ready-made title page.
/// The generated title sizes are intentionally part of each preset.
///
/// ```typst
/// #let theme = "soft-jade"
/// #let shared = (typography: (font: "EB Garamond"),)
/// #cover-page(layout: "research", title: [Field notes], theme: theme, config: shared)
/// #show: report.with(theme: theme, config: shared)
/// = Introduction
/// ```
///
/// - config (dictionary): partial nested overrides merged after cover defaults and
///   selected theme colors. Hover the exported `defaults` dictionary (`satz.defaults`
///   with a namespace import) for the shared config schema and baseline values.
///   Cover layouts use `page.paper`, `page.margin`, `typography.font`,
///   `typography.size`, and `colors.bg-paper`, `brand-primary`, `brand-accent`,
///   `text-main`, and `text-muted`; other shared keys are accepted and ignored.
///   See the [configuration reference](/satz/reference/configuration/) for
///   effective cover values and the fields each layout consumes.
#let cover-page(
  config: (:),
  logos: none,
  body: none,
  footer: none,
  footer-left: none,
  layout: "classic",
  theme: "neutral",
  title: none,
  subtitle: none,
  author: none,
  date: none,
  keywords: none,
  supervisors: none,
) = {
  assert(type(config) == dictionary, message: "Cover config must be a dictionary.")
  let _ = validate-config(config)
  assert(type(layout) == str, message: "Cover layout must be a string: classic, research or minimal.")
  assert(type(theme) == str, message: "Cover theme must be a string naming a built-in cover palette.")
  if not ("classic", "research", "minimal").contains(layout) {
    panic("Unknown cover layout '" + layout + "'. Use classic, research, or minimal.")
  }

  let theme-colors = cover-themes.at(theme, default: none)
  if theme-colors == none {
    panic("Unknown cover theme '" + theme + "'. See cover-themes for available themes.")
  }

  let user-colors = config.at("colors", default: (:))
  let colors = (: ..theme-colors, ..user-colors)
  let c = merge(cover-defaults, (: ..config, colors: colors))

  if body == none and title == none {
    panic("Pass either body: [...] or title: \"...\" to cover-page().")
  }
  if body == none and layout == "classic" {
    panic("The generated title-page layouts are research and minimal. For classic, pass body: [...] or choose layout: \"research\" / \"minimal\".")
  }

  let cover-body = if body != none {
    body
  } else if layout == "research" {
    [
      #block(width: 100%)[
        #v(4.5cm)
        #grid(
          columns: (3pt, 1fr),
          column-gutter: 0.7cm,
          align: horizon,
          rect(width: 3pt, height: 4.5cm, fill: c.colors.brand-primary),
          block(width: 100%)[
            #text(size: 18pt, weight: "bold", fill: c.colors.brand-primary)[#title]
            #if subtitle != none [
              #v(0.3cm)
              #text(size: 13pt, style: "italic", fill: c.colors.text-muted)[#subtitle]
            ]
          ],
        )
        #v(1.1cm)
        #if author != none [#text(size: 13pt, weight: "medium", fill: c.colors.text-main)[#author]]
        #if date != none or keywords != none [
          #v(0.35cm)
          #text(size: 9pt, fill: c.colors.text-muted)[
            #if date != none [#date]
            #if date != none and keywords != none [  ·  ]
            #if keywords != none [#keywords]
          ]
        ]
      ]
    ]
  } else {
    [
      #v(8cm)
      #text(size: 25pt, weight: "bold", fill: c.colors.brand-primary)[#title]
      #if subtitle != none [
        #v(0.3cm)
        #text(size: 13pt, style: "italic", fill: c.colors.text-muted)[#subtitle]
      ]
      #if author != none [
        #v(1.2cm)
        #text(size: 13pt, fill: c.colors.text-main)[#author]
      ]
    ]
  }

  page(
    paper: c.page.paper,
    fill: c.colors.bg-paper,
    margin: c.page.margin,
    header: none,
    footer: none,
  )[
    #set text(font: c.typography.font, size: c.typography.size, fill: c.colors.text-main)

    // Logos stay in their original colors and keep their top-left position.
    #if logos != none {
      place(top + left)[#logos]
    }

    #align(if layout == "research" { left } else { center })[#cover-body]

    #if footer != none {
      place(bottom + center)[#footer]
    } else if date != none and layout == "minimal" {
      place(bottom + center)[#text(size: 9pt, fill: c.colors.text-muted)[#date]]
    }

    #if footer-left != none {
      place(bottom + left, dy: -1.5cm)[#footer-left]
    } else if supervisors != none {
      place(bottom + left, dy: -1.5cm)[
        #text(size: 9pt, fill: c.colors.text-muted)[
          *Supervisors:* \
          #supervisors.join("\n")
        ]
      ]
    }
  ]
}

/// Create a research notebook cover with title and optional metadata.
///
/// Render a research title page with a title, optional metadata, and logos. A following
/// document does not inherit this cover's theme or config; pass matching values
/// to both calls if they should share an appearance.
///
/// ```typst
/// #research-cover(
///   title: [Field notes],
///   author: [Alex Example],
///   date: "2026",
///   theme: "soft-jade",
/// )
/// ```
///
/// - title (content, str): required title; use `box(...)` to keep a word
///   together
/// - subtitle (content, str, none): optional line beneath the title
/// - author (content, str, none): optional author line
/// - date (content, str, none): optional date in the title block
/// - keywords (content, str, none): optional keywords in the title block
/// - supervisors (array of str, none): optional bottom-left names
/// - logos (content, none): optional content at the top left
/// - body (content, none): optional custom cover body; replaces generated fields
/// - footer (content, none): optional bottom-center content
/// - footer-left (content, none): optional bottom-left content; replaces
///   `supervisors`
/// - theme (str): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`
/// - config (dictionary): partial nested overrides merged after cover defaults and
///   selected theme colors. Hover the exported `defaults` dictionary (`satz.defaults`
///   with a namespace import) for the shared config schema and baseline values.
///   Cover layouts use `page.paper`, `page.margin`, `typography.font`,
///   `typography.size`, and the documented cover color fields; other shared keys are
///   accepted and ignored. See the [configuration reference](/satz/reference/configuration/)
///   for effective cover values and the fields each layout consumes.
#let research-cover = cover-page.with(layout: "research")

/// Create a spare, centered title page for reports, notes, and short documents.
///
/// Render a minimal centered title page. The required title is centered;
/// optional subtitle and author appear below it. The date is placed at the
/// bottom unless a custom `footer` replaces it. A following document does not
/// inherit this cover's theme or config; pass matching values to both calls if
/// they should share an appearance.
///
/// ```typst
/// #minimal-cover(
///   title: [Project notes],
///   subtitle: [A short working document],
///   date: "2026",
/// )
/// ```
///
/// - title (content, str): required cover title
/// - subtitle, author (content, str, none): optional lines beneath the title
/// - date (content, str, none): optional bottom date unless `footer` is supplied
/// - logos (content, none): optional content at top left
/// - body (content, none): optional custom body; replaces generated fields
/// - footer (content, none): optional bottom-center content; replaces the date
/// - footer-left (content, none): optional bottom-left content
/// - supervisors (array of str, none): optional names at bottom left; replaced
///   by `footer-left` when that is supplied
/// - keywords (content, str, none): accepted but not displayed by this layout
/// - theme (str): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`
/// - config (dictionary): partial nested overrides merged after cover defaults and
///   selected theme colors. Hover the exported `defaults` dictionary (`satz.defaults`
///   with a namespace import) for the shared config schema and baseline values.
///   Cover layouts use `page.paper`, `page.margin`, `typography.font`,
///   `typography.size`, and the documented cover color fields; other shared keys are
///   accepted and ignored. See the [configuration reference](/satz/reference/configuration/)
///   for effective cover values and the fields each layout consumes.
#let minimal-cover = cover-page.with(layout: "minimal")
