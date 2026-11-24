#import "../class.typ": document-class
#import "../defaults.typ": defaults as root-defaults, merge
#import "defaults.typ": defaults as nwo-defaults
#import "profiles.typ": nwo-profile

/// Format the hierarchical section numbers used by supported NWO forms.
///
/// The form pattern alternates decimal and alphabetic parts: `form-number(2)`
/// returns `2`, `form-number(2, 1)` returns `2a.`,
/// `form-number(2, 1, 3)` returns `2a1.`, and a fourth part returns `2a1a.`.
/// The NWO template passes this function to `headings.numbering`; users do not
/// normally need to call it directly.
///
/// - ..parts (integers): nested section numbers; the NWO template supplies up
///   to four positive values
/// -> str: formatted NWO section number
#let form-number(..parts) = {
  let n = parts.pos()
  let result = str(n.first())
  if n.len() > 1 { result += numbering("a", n.at(1)) }
  if n.len() > 2 { result += str(n.at(2)) }
  if n.len() > 3 { result += numbering("a", n.at(3)) }
  result + if n.len() > 1 { "." } else { "" }
}

/// NWO Talent Programme application layout using an explicit checked profile.
///
/// Ordinary headings continue to work. There is no cover, contents, or page
/// counter reset. Pages have a stable current/total header from page 1. This is
/// a source-checked authoring aid, not universal submission certification.
///
/// ```example
/// #show: nwo-proposal.with(
///   scheme: "veni",
///   domain: "science",
///   stage: "pre",
///   applicant: [Alex Example],
///   title: [Example research idea],
/// )
/// = Key output
/// #nwo-text("key-output", "A short plain-text response.")
/// ```
///
/// - scheme (str): `"veni"` (default), `"vidi"`, or `"vici"`
/// - domain (str): `"science"` (default), `"ssh"`, `"aes"`, or `"zonmw"`
/// - stage (str): `"pre"` (default) or `"full"`. In 2026, only Vici full
///   proposals are represented; other full-proposal forms fail explicitly
/// - year (int): source-checked form year; must be 2026
/// - applicant (content, str): applicant block; defaults to empty
/// - title (content, str): proposal title; defaults to empty
/// - config (dictionary): partial nested overrides; nested dictionaries merge recursively.
///   Template defaults: Only source-checked 2026 profiles; A4 with `25mm` margins; Arial, 9.5pt pre-proposal or 10pt Vici full form; no contents/lists; black text/links. Form profile controls remaining typography and page budget.
///   NWO supports page.header-ascent. Profile typography varies with the selected scheme and stage; explicit config overrides profile values.
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
/// - body (content): the application sections
#let nwo-proposal(
  scheme: "veni", domain: "science", stage: "pre", year: 2026,
  applicant: [], title: [], config: (:), body,
) = {
  let profile = nwo-profile(scheme: scheme, domain: domain, stage: stage, year: year)
  let sized = (
    typography: (size: profile.size), tables: (font-size: profile.size),
    captions: (size: profile.size),
    headings: (numbering: form-number, h1-size: 14pt, h2-size: 12pt, h3-size: 11pt, h4-size: profile.size),
  )
  let c = merge(merge(merge(root-defaults, nwo-defaults), sized), config)
  let furniture = context {
    text(size: 8pt, fill: black)[
      NWO · #upper(scheme) #year · #if stage == "pre" [Pre-proposal] else [Full proposal]
      #h(1fr) Page #here().page() / #counter(page).final().first()
    ]
  }
  document-class(kind: "proposal", config: c, header: furniture)[
    #set text(lang: "en")
    #set page(numbering: none, footer: none)
    #show heading: set heading(bookmarked: false)
    #state("satz-nwo-profile").update(profile)
    #counter("satz-nwo-output").update(0)
    #state("satz-nwo-page-height").update(297mm - c.page.margin.top - c.page.margin.bottom)
    #align(left)[
      #text(size: 16pt, weight: "bold", fill: c.colors.brand-primary)[NWO Talent Programme – #upper(scheme)]
      #parbreak()
      #text(weight: "bold")[Grant application #if stage == "pre" [pre-proposal] else [full proposal] form #year]
      #parbreak()
      #profile.domain-name
      #if applicant != [] { parbreak(); applicant }
      #if title != [] { parbreak(); strong(title) }
    ]
    #body
    #context {
      assert(query(<satz-nwo-key-output>).len() <= 10, message: "NWO allows at most ten key output items.")
    }
  ]
}
