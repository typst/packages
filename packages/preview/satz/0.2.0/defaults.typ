// Unified defaults for the satz document class.
// All config keys with their default values.
// Copy sections you want to change into your project's config.typ.

/// Complete shared defaults for document page layout and styling.
///
/// Pass this dictionary through a template's `config:` argument, usually as
/// `config: (typography: (...), page: (...))`. You only need to provide values
/// you want to change. Dictionaries merge recursively, so overriding one
/// nested value preserves its siblings; for example,
/// `config: (colors: (brand-primary: blue))` changes only that color. Arrays,
/// scalar values, and content replace the corresponding default value.
///
/// These are the shared baseline values. Named templates may override them,
/// add template-specific groups, or use only the settings that make sense for
/// their layout. A documented key is not necessarily consumed by every
/// template. Check a template's API section before assuming a key affects it.
///
/// ```typst
/// #show: custom.with(config: (
///   typography: (
///     font: "STIX Two Text",
///     math-font: "STIX Two Math",
///     size: 11pt,
///     line-spacing: 1.25,
///     paragraph-spacing: 0.8em,
///   ),
///   page: (paper: "a5", margin: (x: 18mm, y: 20mm)),
///   colors: (brand-primary: blue),
/// ))
/// ```
///
/// Every key below is nested under its group, for example
/// `typography.font` means `(typography: (font: ...))`.
///
/// **Page (`page`)**
/// - `paper` (paper name or custom size; `"a4"`): page format.
/// - `margin` (dictionary of edge lengths; 2.5cm on every edge): page margins.
///   Use `top`, `bottom`, `left`, and `right`; two-sided layouts may instead
///   derive inside/outside margins. `x` and `y` are shorthand for horizontal
///   and vertical margins.
/// - `binding` (`none`, `left`, or `right`; `none`): enables two-sided layout
///   and selects the binding edge where supported.
/// - `binding-correction` (length; `0pt`): extra space at the binding edge.
/// - `headers` (bool; `false`): enables the template's running header where
///   implemented.
/// - `columns` (positive integer; `1`): number of text columns where supported.
/// - `column-gutter` (length; `5mm`): gap between columns.
///
/// **Typography (`typography`)**
/// - `font` (font name; `"Libertinus Serif"`): body text typeface.
/// - `math-font` (font name or `auto`; `auto`): math typeface. `auto` leaves
///   math font selection to Typst.
/// - `mono-font` (font name or `auto`; `auto`): monospace typeface. `auto`
///   leaves raw text in Typst's native style.
/// - `size` (length; `11pt`): body text size.
/// - `line-spacing` (positive number or `none`; `none`): optional baseline to
///   baseline distance as a multiple of body size, for example `1.25`. Satz
///   uses the selected font's metrics to calculate leading. When set, it
///   overrides `leading`.
/// - `leading` (length; `0.65em`): Typst's gap between adjacent line boxes.
///   This is a direct length, not a baseline-distance multiplier.
/// - `list-spacing` (non-negative number; `0.5`): additional gap between list
///   items as a fraction of the calculated body baseline distance. Zero adds
///   no extra gap. The baseline follows `line-spacing` when set, or the
///   selected font metrics and `leading` otherwise.
/// - `paragraph-spacing` (length; `1.2em`): vertical gap between paragraphs.
/// - `first-line-indent` (bool; `false`): whether to indent the first line of
///   every paragraph. `true` uses one em (the current body font size, so 11pt
///   at an 11pt text size), including the first paragraph in a
///   document/container and paragraphs immediately after blocks such as
///   headings; `false` uses no indent. This horizontal measure is independent
///   of vertical `line-spacing` and `paragraph-spacing` and does not change
///   either setting.
/// - `hyphenate` (bool; `false`): automatic word hyphenation in body text.
/// - `justify` (bool; `true`): justify body paragraphs where supported.
///
/// **Headings (`headings`)**
/// - `numbering` (Typst numbering pattern/function or `none`; `"1.1"`):
///   numbering for native headings.
/// - `hyphenate` (bool; `false`): allow line breaks by hyphenation in headings.
/// - `h1-pagebreak` (bool; `false`): start level-one headings on a new page
///   where supported.
/// - `spacing` (`"koma"` or `"native"`; `"koma"`): `"koma"` derives heading
///   gaps from KOMA-style baseline skips and font metrics; `"native"` keeps
///   Typst's native spacing policy.
/// - `h1-size` … `h4-size` (lengths; `14pt`, `12pt`, `11pt`, `11pt`): text size
///   for heading levels one through four.
/// - `h1-above` … `h4-above` (`auto` or length; `auto`): gap before each level.
///   `auto` follows the selected spacing policy.
/// - `h1-below` … `h4-below` (`auto` or length; `auto`): gap after each level.
///   An explicit length overrides the template's automatic value.
///
/// **Journal (`journal`)**
/// - `header-below` (length; `1.5em`): gap after the full entry heading/date
///   block and before the notes.
/// - `running-gutter` (length; `1em`): gap between columns in a running header.
/// - `running-leading` (length; `0.35em`): line gap in a multi-line running
///   header.
/// - `running-header-size` (length; `9pt`): journal running-header text size.
/// - `date-size` (length; `10pt`): journal date text size.
/// - `keywords-size` (length; `9pt`): journal keyword text size.
/// Journal lists use the shared `typography.list-spacing` setting.
///
/// **Decorative text and lists (`decorative`)**
/// - `header-size` (length; `9pt`): running-header text size.
/// - `footer-size` (length; `10pt`): footer text size where implemented.
/// - `date-size` (length; `10pt`): date text size where implemented.
/// - `keywords-size` (length; `9pt`): keyword text size where implemented.
/// General list spacing uses `typography.list-spacing`. DFG templates also
/// accept the extension fields `list-indent`, `list-body-indent`,
/// `list-block-spacing`, and `list-spacing` in this group. These control DFG
/// geometry and a DFG-specific length override.
///
/// **Page number (`page-footer`)**
/// - `format` (Typst numbering pattern/function; `"1"`): page-number format.
/// - `size` (length; `10pt`): page-number text size.
/// - `weight` (Typst font weight; `"regular"`): page-number text weight.
///
/// **Line numbers (`line-numbers`)**
/// - `enabled` (bool; `false`): show line numbers in templates that support
///   draft line numbering.
/// - `format` (Typst numbering pattern; `"1"`): line-number format.
/// - `scope` (`"document"` or `"page"`; `"document"`): keep numbering
///   continuous across pages or restart on each page.
/// - `size` (length; `8pt`): line-number text size.
/// - `color` (color; `#64748B`): line-number color.
/// - `clearance` (`auto` or length; `auto`): gap between numbers and body text.
///
/// **Links (`links`)**
/// - `color` (color; `#0563C1`): color of internal references.
/// - `url-color` (color; `#0563C1`): color of external URLs.
///
/// **Tables (`tables`)**
/// - `stroke` (length; `0.5pt`): default rule thickness for shared table
///   helpers.
/// - `inset` (length or dictionary; `(x: 8pt, y: 4pt)`): cell padding. A
///   dictionary can set horizontal and vertical padding independently.
/// - `font-size` (length; `10pt`): text size in shared styled tables.
/// - `caption-position` (`top` or `bottom`; `top`): caption location in the
///   scientific-table show rule.
/// - `caption-gap` (length; `6pt`): space between a table caption and table.

/// **Figures (`figures`)**
/// - `placement` (`auto`, `none`, or vertical alignment; `none`): native
///   placement policy for figures, including tables represented as figures.
///   `none` keeps them in source order; `auto` lets Typst place them at a
///   suitable page edge. Templates may override this baseline.
///
/// **Callouts (`callouts`)**
/// - `inset` (length; `9pt`): inner padding.
/// - `radius` (length; `3pt`): corner radius.
/// - `stroke` (length; `0.8pt`): border thickness.
/// - `title-below` (length; `1em`): gap below a callout title.
/// - `paragraph-spacing` (length; `1em`): gap between callout paragraphs.
/// - `list-spacing` (length; `1.2em`): gap between callout list items.
///
/// **Captions (`captions`)**
/// - `size` (length; `10pt`): caption text size.
/// - `weight` (Typst font weight; `"regular"`): caption text weight.
/// - `alignment` (Typst alignment; `left`): caption alignment when not hanging.
/// - `label-weight` (Typst font weight; `"regular"`): weight of the caption
///   label, independently of the rest of the caption.
/// - `hanging` (boolean; `true`): put the label in its own column so wrapped
///   lines align with the caption text. Set to `false` for inline labels.
///
/// **Contents (`toc`)**
/// - `depth` (`none` or non-negative integer; `none`): included heading depth.
///   In report/thesis documents, `0` disables the automatic contents.
/// - `title` (content or `none`; `[Table of Contents]`): title above the list;
///   `none` omits it.
/// - `indent` (`auto` or length; `auto`): indentation of nested entries.
/// - `entry-size` (length; `10pt`): entry text size.
/// - `leading` (length; `0.65em`): line gap in wrapped entries.
/// - `entry-above` (length; `0.65em`): gap between ordinary entries.
/// - `main-entry-above` (length; `1.25em`): extra gap before main-section
///   entries.
/// - `title-below` (length; `1.5em`): gap between title and first entry.
/// - `below` (length; `2em`): gap after the contents.
///
/// **List of Figures (`lof`) and List of Tables (`lot`)**
/// Both groups use the same fields and meanings as `toc`, with these defaults:
/// `depth: none` (automatic depth), `title: [List of Figures]` or
/// `[List of Tables]`, `indent: auto`, `entry-size: 10pt`, `leading: 0.65em`,
/// `entry-above: 0.85em`, `title-below: 1.5em`, and `below: 2em`.
/// - `compact` (bool; `false`): when true, show only the figure/table label
///   and page number, omitting caption text.
///
/// **Bibliography (`bibliography`)**
/// - `style` (CSL style name; `"apa"`): citation style where bibliography
///   support is enabled.
///
/// **Colors (`colors`)**
/// - `bg-paper` (color; `white`): page or paper background.
/// - `bg-subtle` (color; `white`): subtle surface/background color.
/// - `brand-primary` (color; `black`): primary brand and heading accent.
/// - `brand-accent` (color; `black`): secondary accent.
/// - `text-main` (color; `black`): primary body text.
/// - `text-muted` (color; `black`): secondary or muted text.
///
/// Some templates add validated settings not present in this baseline,
/// including `page.header-ascent`, `headings.h1-number-size`, and
/// `decorative.list-indent`, `decorative.list-body-indent`, `decorative.list-spacing`,
/// and `decorative.list-block-spacing`. Consult the relevant template's API and
/// the configuration reference before using template-specific keys.
///
/// With `math-font: auto`, Typst selects its default math font. The Typst CLI
/// embeds New Computer Modern Math, so users do not need to install it.
/// Template defaults may differ from this shared baseline.
///
/// For details about which templates consume each key and for template-specific
/// overrides, see the versioned configuration reference.
///
#let defaults = (
  page: (
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    binding: none,
    binding-correction: 0pt,
    headers: false,
    columns: 1,
    column-gutter: 5mm,
  ),
  typography: (
    font: "Libertinus Serif",
    math-font: auto,
    mono-font: auto,
    size: 11pt,
    // Optional baseline-to-baseline multiple of the body font size.
    // When set, this is translated to Typst leading using the selected font's metrics.
    line-spacing: none,
    // Backward-compatible Typst gap between adjacent line boxes.
    leading: 0.65em,
    list-spacing: 0.5,
    paragraph-spacing: 1.2em,
    first-line-indent: false,
    hyphenate: false,
    justify: true,
  ),
  headings: (
    numbering: "1.1",
    hyphenate: false,
    h1-pagebreak: false,
    // auto translates KOMA baseline skips using the actual body/heading fonts.
    // Explicit lengths remain Typst block gaps. "native" opts out of translation.
    spacing: "koma",
    h1-size: 14pt, h1-above: auto, h1-below: auto,
    h2-size: 12pt, h2-above: auto, h2-below: auto,
    h3-size: 11pt, h3-above: auto, h3-below: auto,
    h4-size: 11pt, h4-above: auto, h4-below: auto,
  ),
  journal: (
    // One gap between the complete entry heading/date block and the notes.
    header-below: 1.5em,
    running-gutter: 1em,
    running-leading: 0.35em,
    running-header-size: 9pt,
    date-size: 10pt,
    keywords-size: 9pt,
  ),
  decorative: (
    header-size: 9pt,
    footer-size: 10pt,
    date-size: 10pt,
    keywords-size: 9pt,
  ),
  page-footer: (
    format: "1",
    size: 10pt,
    weight: "regular",
  ),
  // Enable for manuscripts sent for review or preprint drafts.
  line-numbers: (
    enabled: false,
    format: "1",
    scope: "document",
    size: 8pt,
    color: rgb("#64748b"),
    clearance: auto,
  ),
  links: (
    color: rgb("#0563C1"),
    url-color: rgb("#0563C1"),
  ),
  tables: (
    stroke: 0.5pt,
    inset: (x: 8pt, y: 4pt),
    font-size: 10pt,
    caption-position: top,
    caption-gap: 6pt,
  ),
  figures: (placement: none),
  callouts: (
    inset: 9pt,
    radius: 3pt,
    stroke: 0.8pt,
    title-below: 1em,
    paragraph-spacing: 1em,
    list-spacing: 1.2em,
  ),
  captions: (
    size: 10pt,
    weight: "regular",
    alignment: left,
    label-weight: "regular",
    hanging: true,
  ),
  toc: (
    // Set depth: 0 to disable. none includes all outlined heading levels.
    depth: none,
    // Title shown above the table of contents. Set to none to omit.
    title: [Table of Contents],
    // Indent per heading level (e.g. 1em for sub-sections)
    indent: auto,
    // Entry text size, spacing between rows, and extra space before each main section
    entry-size: 10pt,
    leading: 0.65em,
    entry-above: 0.65em,
    main-entry-above: 1.25em,
    // Space between the title and first entry; space after the ToC before body content
    title-below: 1.5em,
    below: 2em,
  ),
  lof: (
    // Set depth: 0 to disable. none = auto.
    depth: none,
    // Title shown above the list of figures. Set to none to omit.
    title: [List of Figures],
    // Indent per level
    indent: auto,
    entry-size: 10pt,
    leading: 0.65em,
    entry-above: 0.85em,
    title-below: 1.5em,
    // Spacing below the list
    below: 2em,
    // When true, LoF shows only "Figure N .... page", no caption text.
    // Set to true for long captions where the full text clutters the list.
    compact: false,
  ),
  lot: (
    depth: none,
    title: [List of Tables],
    indent: auto,
    entry-size: 10pt,
    leading: 0.65em,
    entry-above: 0.85em,
    title-below: 1.5em,
    below: 2em,
    // Same as lof.compact, but for tables.
    compact: false,
  ),
  bibliography: (
    style: "apa",
  ),
  colors: (
    bg-paper: white,
    bg-subtle: white,
    brand-primary: black,
    brand-accent: black,
    text-main: black,
    text-muted: black,
  ),
)

/// Validate keys in known shared configuration groups.
///
/// The validator checks that the input and each known group are dictionaries,
/// then rejects unknown keys in groups defined by defaults. Template-specific
/// and caller extension groups remain open, including unknown top-level group
/// names. It does not validate the value type or semantic range for individual
/// fields; consuming templates may perform additional validation.
///
/// - config (dictionary): nested config overrides to validate
/// -> dictionary: the same config dictionary, returned unchanged
#let validate-config(config) = {
  assert(type(config) == dictionary, message: "Satz config must be a dictionary.")
  for (group, values) in config {
    if group in defaults {
      assert(type(values) == dictionary,
        message: "Satz config group `" + group + "` must be a dictionary.")
      let allowed = if group == "page" {
        (..defaults.page.keys(), "header-ascent")
      } else if group == "headings" {
        (..defaults.headings.keys(), "h1-number-size")
      } else if group == "decorative" {
        (..defaults.decorative.keys(), "list-indent", "list-body-indent", "list-block-spacing", "list-spacing")
      } else {
        defaults.at(group).keys()
      }
      if group == "page" {
        allowed += ("inside", "outside", "x", "y")
      }
      for key in values.keys() {
        assert(key in allowed,
          message: "Unknown Satz config key `" + group + "." + key + "`. Check the configuration reference for supported keys.")
      }
    }
  }
  config
}

/// Recursively merge configuration dictionaries, giving `overrides` priority.
///
/// For each key in `overrides`, nested dictionaries are merged recursively when
/// both the existing value and the override are dictionaries. Keys present only
/// in `base` are retained; keys present only in `overrides` are added. When the
/// override is not a dictionary, or the base value is not a dictionary, the
/// override replaces the base value. This means arrays, strings, numbers,
/// booleans, colors, content, and `none` are replaced as whole values rather
/// than merged. The function returns new dictionaries and does not mutate either
/// input. It does not validate configuration keys or values.
///
/// For example, merging `defaults` with
/// `(colors: (brand-primary: blue), typography: (size: 12pt))` changes only
/// those two leaves. All other color and typography values stay in place.
///
/// ```typst
/// #let local = merge(defaults, (
///   colors: (brand-primary: blue),
///   typography: (size: 12pt),
/// ))
/// ```
///
/// Use this helper when an API intentionally accepts open-ended configuration.
/// For public document configuration, prefer the template API, which may also
/// validate known groups and keys.
///
/// - base (dictionary): starting values; keys not overridden are retained
/// - overrides (dictionary): values that replace or recursively update `base`
/// -> dictionary: a merged result; neither input is mutated
#let merge(base, overrides) = {
  let result = (:)
  for (k, v) in base {
    result.insert(k, v)
  }
  for (k, v) in overrides {
    if type(v) == dictionary and k in result and type(result.at(k)) == dictionary {
      result.insert(k, merge(result.at(k), v))
    } else {
      result.insert(k, v)
    }
  }
  result
}
