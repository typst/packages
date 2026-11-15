// DFG 53.01 (Sachbeihilfe) — shared Satz class with form-specific defaults.
#import "../class.typ": document-class
#import "../defaults.typ": defaults as root-defaults, merge
#import "defaults.typ": defaults as dfg-defaults
#import "../proposal/citations.typ": proposal-publications
#import "layout.typ": proposal-headings, proposal-title

/// Begin the separately counted second part of a DFG project description.
///
/// Place this call exactly once inside `doc`, immediately before the level-one
/// heading for section 4. It inserts a page break and resets the displayed page
/// number to 1 for sections 4–5. Heading numbering continues from section 3;
/// the DFG running header and page-limit check switch to the fixed eight-page
/// supplement allowance. The `dfg-proposal` wrapper checks both parts when
/// `check-pages` is enabled.
///
/// ```typst
/// #show: dfg-proposal.with(doc: [
///   = 1 Starting point
///   ...
///   = 3 Project plan
///   ...
///   #dfg-supplement()
///   = 4 Research data
///   ...
///   = 5 Ethics
/// ])
/// ```
///
/// - arguments: none
/// -> content: page break and metadata marker used by `dfg-proposal`
#let dfg-supplement() = {
  pagebreak()
  counter(page).update(1)
  [#metadata("supplement") <satz-dfg-supplement>]
}

/// Render the publications bibliography without adding another heading.
///
/// Place it under the ordinary level-one publications heading. With
/// `proposal-citations`, omit `source` and this delegates to
/// `proposal-publications()`, preserving highlighted entries.
///
/// - source (str, none): bibliography path; `none` uses `proposal-citations`
/// - size (length): bibliography text size, at least 9pt; defaults to 9pt
/// - style (str): CSL style for a direct `bibliography()` call; defaults to `"apa"`
/// - ..args: one positional bibliography path or native `bibliography` options
#let dfg-publications(source: none, size: 9pt, style: "apa", ..args) = {
  assert(size >= 9pt, message: "DFG publications must be at least 9pt.")
  set text(size: size)
  let positional = args.pos()
  assert(positional.len() <= 1, message: "Provide one bibliography source.")
  let chosen = if positional.len() == 1 { positional.first() } else { source }
  if chosen == none {
    assert(args.named().len() == 0, message: "Set CSL options on proposal-citations, not dfg-publications.")
    proposal-publications(size: size, max-highlight: 10)
  } else {
    bibliography(chosen, title: none, style: style, ..args.named())
  }
}

/// DFG form 53.01 project description, revision 09/26, in German or English.
///
/// Uses Arial 11pt, four numbered heading levels, and no contents or cover page.
/// `dfg-supplement()` starts the separately counted eight-page second part.
/// By default compilation fails when either part exceeds its allowance.
///
/// ```example
/// #show: dfg-proposal.with(
///   applicant: [Alex Example, Example University],
///   project: [A small example project],
///   doc: [
///     = 1 Starting point
///     ...
///     #dfg-supplement()
///     = 4 Project plan
///   ],
/// )
/// ```
///
/// - doc (content): numbered project description including headings 1–5
/// - applicant (content): applicant and institution block; defaults to empty
/// - project (content): project title block; defaults to empty
/// - language (str): `"english"` (default) or `"german"`
/// - max-pages (int): first-part page limit; defaults to 17. Sections 1–3 use
///   this limit; sections 4–5 always use the eight-page supplement limit
/// - form-date (str): displayed DFG form date; defaults to `"09/26"`
/// - check-pages (bool): fail compilation on an overlength draft when true
///   (default); set false for a working draft
/// - config (dictionary): partial nested overrides; nested dictionaries merge recursively.
///   Template defaults: DFG form 53.01 (09/26), A4, margins `(left: 25mm, right: 20mm, top: 25mm, bottom: 15mm)`; Arial `11pt`, form-specific leading, four-level numbering `"1.1.1.1"`; no contents/lists; black text/links; left captions.
///   The DFG preset also accepts page.header-ascent and decorative.list-indent, list-body-indent, list-spacing and list-block-spacing. Explicit config overrides the form preset.
///   The following values are the shared baseline; template defaults above override them.
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
#let dfg-proposal(
  applicant: [], project: [], language: "english", max-pages: 17,
  form-date: "09/26", check-pages: true, config: (:), doc,
) = {
  assert(language in ("english", "german"), message: "DFG language must be english or german.")
  assert(type(max-pages) == int and max-pages > 0, message: "max-pages must be a positive integer.")
  assert(type(form-date) == str, message: "DFG form-date must be a string such as `09/26`.")
  assert(type(check-pages) == bool, message: "DFG check-pages must be true or false.")
  let de = language == "german"
  let c = merge(merge(root-defaults, dfg-defaults), config)
  let furniture = context {
    let parts = query(<satz-dfg-supplement>)
    let supplementary = parts.len() > 0 and here().page() >= parts.first().location().page()
    let limit = if supplementary { 8 } else { max-pages }
    // Headers are placed before counter updates in the body. Compute the part
    // page from physical locations so the reset page itself cannot show "2".
    let part-page = if supplementary { here().page() - parts.first().location().page() + 1 } else { here().page() }
    text(size: c.decorative.header-size, weight: "regular")[#if de [DFG-Vordruck] else [DFG form] 53.01 – #form-date #h(1fr) #if de [Seite] else [page] #part-page #if de [von max.] else [of max.] #limit]
  }
  document-class(kind: "proposal", config: c, header: furniture)[
    #set text(lang: if de { "de" } else { "en" }, top-edge: 1467 / 2048 * 1em, bottom-edge: 0pt)
    #set page(numbering: none, footer: none, header-ascent: c.page.header-ascent)
    #set list(indent: c.decorative.list-indent, body-indent: c.decorative.list-body-indent, spacing: c.decorative.list-spacing)
    #set enum(indent: c.decorative.list-indent, body-indent: c.decorative.list-body-indent, spacing: c.decorative.list-spacing)
    #show list: set block(above: c.decorative.list-block-spacing, below: c.decorative.list-block-spacing)
    #show enum: set block(above: c.decorative.list-block-spacing, below: c.decorative.list-block-spacing)
    #show link: it => text(fill: c.links.color, it)
    #v(11 * 72 / 72.27 * 1pt - 1467 / 2048 * 11pt)
    #proposal-title(c,
      if de [Beschreibung des Vorhabens – Projektanträge] else [Project Description – Project Proposals],
      applicant, project,
      if de [Beschreibung des Vorhabens] else [Project Description],
    )
    #proposal-headings(c, doc)
    #metadata("end") <satz-dfg-end>
    #context {
      let parts = query(<satz-dfg-supplement>)
      assert(parts.len() <= 1, message: "Use dfg-supplement() only once.")
      let last = query(<satz-dfg-end>).first().location().page()
      let first-pages = if parts.len() == 0 { last } else { parts.first().location().page() - 1 }
      let extra-pages = last - first-pages
      if check-pages {
        let sections = query(heading.where(level: 1)).filter(h => h.numbering != none)
        if sections.len() >= 4 {
          assert(parts.len() == 1, message: "Insert dfg-supplement() immediately before section 4.")
          let boundary = parts.first().location().position()
          let section-four = sections.at(3).location().position()
          assert(boundary.page == section-four.page and boundary.y <= section-four.y,
            message: "Insert dfg-supplement() immediately before section 4.")
        }
        assert(first-pages <= max-pages, message: "DFG sections 1–3 exceed " + str(max-pages) + " pages (" + str(first-pages) + ").")
        assert(extra-pages <= 8, message: "DFG sections 4–5 exceed 8 pages (" + str(extra-pages) + ").")
      }
    }
  ]
}
