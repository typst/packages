#import "../class.typ": document-class
#import "../defaults.typ": defaults as root-defaults, merge
#import "defaults.typ": defaults as proposal-defaults

/// A general research or project proposal with an inline title and summary.
///
/// No funder-specific headings or page limits are imposed; write ordinary
/// markup. The running header shows the short title and current/total page
/// numbers from page 1.
///
/// ```example
/// #show: research-proposal.with(
///   title: [Example proposal],
///   applicants: [Alex Example],
///   institution: [Example University],
///   summary: [We propose a small example.],
/// )
/// = Objectives
/// #lorem(60)
/// ```
///
/// - title (content, str): proposal title; defaults to empty
/// - applicants (content, str): applicant line; defaults to empty
/// - institution (content, str): institution line; defaults to empty
/// - date (content, str, none): optional date printed verbatim
/// - summary (content, none): optional summary block
/// - short-title (content, str, none): running-header title; `none` reuses `title`
/// - language (str): `"english"` (default) or `"german"`; controls labels and
///   Typst language
/// - config (dictionary): recursively merged overrides, applied after the
///   general proposal preset. Explicit values replace preset values while
///   unspecified siblings retain their defaults. The proposal preset is A4,
///   25mm margins, 11pt Libertinus Serif, 0.7em paragraph spacing, numbered
///   `"1.1"` headings, no automatic contents/figure/table lists, black text and
///   links, and a black-on-white page. The running header uses the shared
///   `decorative.header-size` (9pt). Supported shared groups and fields are:
///   - `page`: `paper` (paper name or custom size; `"a4"`), `margin` (edge
///     dictionary; proposal default 25mm on every edge), `binding` (`none` or
///     `left`/`right`; default `none`), `binding-correction` (length; `0pt`),
///     `headers` (bool; `false`), `columns` (positive integer; `1`),
///     `column-gutter` (length; `5mm`).
///   - `typography`: `font` (name; `"Libertinus Serif"`), `math-font` and
///     `mono-font` (name or `auto`; `auto`), `size` (length; `11pt`),
///     `line-spacing` (positive baseline multiple or `none`; `none`),
///     `leading` (length; `0.65em`), `paragraph-spacing` (length; proposal
///     default `0.7em`), `first-line-indent` (bool; `false`), `hyphenate`
///     (bool; `false`), `justify` (bool; `true`).
///   - `typography.list-spacing` (non-negative number; `0.5`): additional gap
///     between document list items as a fraction of the calculated body
///     baseline distance. It follows `typography.line-spacing` when set, or
///     font metrics and `typography.leading` otherwise; `0` adds no extra gap.
///     Proposal templates do not use this setting for their own layout.
///   - `headings`: `numbering` (pattern/function or `none`; proposal default
///     `"1.1"`), `hyphenate` (`false`), `h1-pagebreak` (`false`), `spacing`
///     (`"koma"` or `"native"`; `"koma"`), and `h1-size` through `h4-size`
///     (14pt/12pt/11pt/11pt), `hN-above` and `hN-below` (length or `auto`;
///     `auto`).
///   - `journal`: `header-below` (1.5em), `running-gutter` (1em),
///     `running-leading` (0.35em), `running-header-size` (9pt), `date-size`
///     (10pt), and `keywords-size` (9pt); journal-only settings, unused here.
///   - `decorative`: `header-size` (9pt), `footer-size` (10pt), `date-size`
///     (10pt), and `keywords-size` (9pt). `header-size` styles running text.
///   - `page-footer`: `format` (numbering pattern/function; `"1"`), `size`
///     (10pt), `weight` (`"regular"`).
///   - `line-numbers`: `enabled` (`false`), `format` (`"1"`), `scope`
///     (`"document"` or `"page"`; `"document"`), `size` (8pt), `color`
///     (`#64748B`), `clearance` (length or `auto`; `auto`).
///   - `links`: `color` and `url-color` (colors; proposal defaults both black).
///   - `tables`: `stroke` (0.5pt), `inset` ((x: 8pt, y: 4pt)), `font-size`
///     (10pt), `caption-position` (`top` or `bottom`; `top`), `caption-gap`
///     (6pt).
///   - `callouts`: `inset` (9pt), `radius` (3pt), `stroke` (0.8pt),
///     `title-below` (1em), `paragraph-spacing` (1em), `list-spacing` (1.2em).
///   - `captions`: `size` (10pt), `weight` and `label-weight` (`"regular"`),
///     `alignment` (`left`), and `hanging` (`true`).
///   - `toc`, `lof`, `lot`: `depth` (proposal default `0`), `title` (content or
///     `none`), `indent` (`auto` or length; `auto`), `entry-size` (10pt),
///     `leading` (0.65em), `entry-above` (0.65em for toc; 0.85em for lof/lot),
///     `title-below` (1.5em), `below` (2em). `toc.main-entry-above` is 1.25em;
///     `lof.compact` and `lot.compact` default to false.
///   - `bibliography.style` (CSL name; `"apa"`).
///   - `colors`: `bg-paper`, `bg-subtle`, `brand-primary`, `brand-accent`,
///     `text-main`, `text-muted` (colors; proposal defaults white paper and
///     black text/primary accent).
/// - body (content): proposal sections
#let research-proposal(
  title: [], applicants: [], institution: [], date: none, summary: none,
  short-title: none, language: "english", config: (:), body,
) = {
  assert(language in ("english", "german"), message: "Proposal language must be english or german.")
  let de = language == "german"
  let c = merge(merge(root-defaults, proposal-defaults), config)
  let furniture = context {
    text(size: c.decorative.header-size)[
      #if short-title == none { title } else { short-title }
      #h(1fr)
      #if de [Seite] else [Page] #counter(page).display("1 / 1", both: true)
    ]
  }
  document-class(kind: "proposal", config: c, header: furniture)[
    #set text(lang: if de { "de" } else { "en" })
    #set page(numbering: none, footer: none)
    #align(left)[
      #text(size: 20pt, weight: "bold", title)
      #parbreak()
      #applicants
      #parbreak()
      #institution
      #if date != none { parbreak(); date }
    ]
    #v(1em)
    #if summary != none {
      block[
        #text(weight: "bold", if de [Zusammenfassung] else [Summary])
        #parbreak()
        #summary
      ]
    }
    #body
  ]
}

/// Create a general research or project proposal with an inline title and
/// summary. This is the same layout as `research-proposal`, provided under a
/// project-oriented name.
///
/// - title (content, str): title; defaults to empty
/// - applicants (content, str): applicant line; defaults to empty
/// - institution (content, str): institution line; defaults to empty
/// - date (content, str, none): optional date printed verbatim
/// - summary (content, none): optional summary block
/// - short-title (content, str, none): running-header title; defaults to title
/// - language (str): `"english"` (default) or `"german"`; controls labels and
///   Typst language
/// - config (dictionary): recursively merged over the proposal preset. The
///   effective preset is A4, 25mm margins, 11pt Libertinus Serif, 0.7em
///   paragraph spacing, `"1.1"` heading numbering, no automatic contents or
///   figure/table lists, black text and links, white paper, and a 9pt running
///   header. It accepts `page.paper` (paper name/custom size, `"a4"`),
///   `page.margin` (edge lengths; 25mm each), `binding` (`none`, `left`,
///   `right`), `binding-correction` (0pt), `headers` (false), `columns` (1),
///   and `column-gutter` (5mm); `typography.font` (`"Libertinus Serif"`),
///   `math-font`/`mono-font` (`auto` or font name; `auto`), `size` (11pt),
///   `line-spacing` (positive baseline multiple or `none`; `none`), `leading`
///   (0.65em), `list-spacing` (non-negative number; `0.5`, extra list-item gap
///   as a fraction of calculated body baseline distance, following line-spacing
///   or font metrics plus leading; 0 adds no extra gap), `paragraph-spacing`
///   (0.7em), `first-line-indent` (false), `hyphenate` (false), and `justify`
///   (true); `headings.numbering`
///   (pattern/function or `none`; `"1.1"`), `hyphenate` (false),
///   `h1-pagebreak` (false), `spacing` (`"koma"` or `"native"`; `"koma"`),
///   and `h1`–`h4` size/above/below fields (14pt/12pt/11pt/11pt, `auto`,
///   `auto`). It also accepts `journal.header-below` (1.5em),
///   `running-gutter` (1em), `running-leading` (0.35em),
///   `running-header-size` (9pt), `date-size` (10pt), `keywords-size` (9pt);
///   `weight` (`"regular"`); `line-numbers.enabled` (false), `format` (`"1"`),
///   `scope` (`"document"` or `"page"`), `size` (8pt), `color` (`#64748B`),
///   `clearance` (auto or length); `links.color` and `url-color` (black in this
///   template); `tables.stroke` (0.5pt), `inset` (length or dictionary;
///   default `(x: 8pt, y: 4pt)`), `font-size` (10pt), `caption-position`
///   (`top` or `bottom`; `top`), `caption-gap` (6pt); `callouts.inset` (9pt),
///   `radius` (3pt), `stroke` (0.8pt), `title-below` (1em),
///   `weight`/`label-weight` (`"regular"`), `alignment` (`left` in proposals);
///   `toc`, `lof`, `lot` depth (0 in this template), title, indent (`auto`),
///   entry-size (10pt), leading (0.65em), entry-above (0.65em toc, 0.85em
///   figures/tables), title-below (1.5em), and below (2em); `toc` also has
///   `main-entry-above` (1.25em), while `lof`/`lot` have `compact` (false);
///   `bibliography.style` (`"apa"`); and colors `bg-paper`, `bg-subtle`,
///   `brand-primary`, `brand-accent`, `text-main`, `text-muted` (white paper,
///   black text and primary accent in this template). Unknown top-level groups
///   are retained as extensions. Known shared group keys are validated.
/// - body (content): proposal sections
/// -> content: proposal title block, running header, and supplied sections
#let project-proposal = research-proposal
