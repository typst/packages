// Public package API and document-wide style setup.

#import "formats/_base.typ": tp
#import "parts/colors.typ": acm-orange, acm-purple
#import "parts/spacing.typ": comp, tex-skip
#import "parts/headings.typ": render-heading, _in-heading, _body-since-heading, noindentparagraph as _noindentparagraph
#import "parts/frontmatter.typ": make-title, make-title-head, make-title-body, make-footnotes, make-acmcp-cover, make-received
#import "parts/metadata.typ": resolve-metadata
#import "parts/options.typ": resolve-options
#import "parts/page-chrome.typ": make-page-chrome
#import "parts/body.typ": apply-body, sidebar, marginfigure, margintable, fulltextwidth
#import "parts/tables.typ": tabular, toprule, midrule, bottomrule
#import "parts/theorems.typ": cfg-state, anon-state, thm-counter, thm-figure-kind, thm-ref
#import "parts/theorems.typ": theorem, lemma, corollary, proposition, conjecture, definition, example, remark, proof, acks
#import "parts/acmref.typ": bbl-cite, bbl-nocite, bbl-fullcite, bbl-citet, bbl-citealt, bbl-citeyear, bbl-citeyearpar, bbl-citeauthor, bbl-shortcite, bbl-bibliography, cite-style-state, tex-render-state
#import "parts/tex.typ": tex-to-content as default-tex-render, latex-logo, tex-logo, bibtex-logo

#let _cite-label(k) = if type(k) == label { k } else { label(k) }

#let _cite-forms = (
  "normal": bbl-cite,
  "prose": bbl-citet,
  "author": bbl-citeauthor,
  "year": bbl-citeyear,
  "full": bbl-fullcite,
)

// Grouped citations need one call: separate ref show rules cannot merge adjacent citations.
#let cite(..args) = context {
  let cfg = cfg-state.get()
  let keys = args.pos()
  let named = args.named()
  if cfg == none or cfg.bib-backend == "typst" {
    keys.map(k => std.cite(_cite-label(k), ..named)).join()
  } else {
    let ks = keys.map(str)
    for k in named.keys() {
      assert(k in ("supplement", "form"), message:
        "faithful-acmart: `cite` has no `" + k + "` argument on the `" + cfg.bib-backend
        + "` backend"
        + if k == "style" { "; the citation style follows acmart's `cite-style` option" } else { "" })
    }
    let form = named.at("form", default: "normal")
    let supp = named.at("supplement", default: none)
    if form == none {
      assert(supp == none,
        message: "faithful-acmart: `cite` with `form: none` typesets nothing, so it takes no `supplement`")
      bbl-nocite(..ks)
    } else {
      assert(form in _cite-forms, message:
        "faithful-acmart: `cite` does not support `form: " + repr(form) + "`; supported forms are "
        + _cite-forms.keys().map(repr).join(", ") + " and `none`")
      assert(not (form == "full" and supp != none), message:
        "faithful-acmart: `cite` with `form: \"full\"` prints the whole reference, so it takes no `supplement`")
      if form == "full" { bbl-fullcite(..ks) } else { (_cite-forms.at(form))(..ks, supplement: supp) }
    }
  }
}

#let _cite-variant(bbl-fn, native-form) = (key, supplement: none) => context {
  let cfg = cfg-state.get()
  if cfg == none or cfg.bib-backend == "typst" {
    std.cite(_cite-label(key), form: native-form, supplement: supplement)
  } else {
    bbl-fn(str(key), supplement: supplement)
  }
}
#let cite-text = _cite-variant(bbl-citet, "prose")
#let cite-year = _cite-variant(bbl-citeyear, "year")
#let cite-author = _cite-variant(bbl-citeauthor, "author")
#let cite-alt = _cite-variant(bbl-citealt, "prose")
#let cite-yearpar = _cite-variant(bbl-citeyearpar, "year")
#let short-cite = _cite-variant(bbl-shortcite, "normal")
#let acknowledgments = acks

#let anon(body, substitute: "ANONYMIZED") = context {
  if anon-state.get() { text(fill: acm-orange, substitute) } else { body }
}

// Without \maketitle, LaTeX indents an opening paragraph; Typst normally leaves it flush.
#let _body-starts-with-paragraph(body) = {
  if body.func() == text { return true }
  if not body.has("children") { return false }
  for c in body.children {
    let n = repr(c.func())
    if n in ("space", "parbreak", "pagebreak", "metadata", "state", "counter", "update") { continue }
    return c.func() == text
  }
  false
}

// The grant ID and URL are production metadata; acmart displays only the sponsor name.
#let grantsponsor(id, name, url) = name

#let grantnum(id, num, url: none) = if url == none { num } else { [#num (#link(url)[#url])] }

#let noindentparagraph(body) = context { _noindentparagraph(cfg-state.get(), body) }

// amsart's \part uses its paragraph font but is a display heading (amsart.cls, \part).
#let part(body) = context {
  let cfg = cfg-state.get()
  let f = cfg.sec-fonts.paragraph
  block(above: tex-skip(cfg, 10 * tp), below: tex-skip(cfg, 4 * tp), sticky: true,
    text(font: cfg.fonts.at(f.family), weight: f.weight, style: f.style,
      size: cfg.size.at(f.size), body))
}

#let _acm-bibliography(path, title: [References]) = context {
  let cfg = cfg-state.get()
  if cfg == none {
    bbl-bibliography(path, title: title)
  } else {
    bbl-bibliography(
      path,
      title: title,
      size: cfg.size.footnotesize,
      leading: comp(cfg, sz: "footnotesize"),
      format: if cfg.bib-backend == "biblatex" { "biblatex" } else { "bst" },
    )
  }
}

// Native bibliography input is validated before show rules run, so the custom parsers require a replacement function.
#let bibliography(title: auto, full: false, style: auto, ..args) = {
  // Validate before entering context so this error precedes any lazy citation lookup.
  assert(args.pos().len() == 1,
    message: "faithful-acmart: `bibliography` takes a single path or an array of paths, like "
      + "Typst's built-in — for several files pass an array: "
      + "bibliography((\"/a.bib\", \"/b.bib\")). Got " + repr(args.pos().len())
      + " positional argument(s).")
  context {
    let cfg = cfg-state.get()
    let backend = if cfg == none { "typst" } else { cfg.bib-backend }
    if backend == "typst" {
      // Forward arguments intact to preserve the caller's path origin and inherited title setting.
      let extra = if style == auto { (:) } else { (style: style) }
      std.bibliography(..args, title: title, full: full, ..extra)
    } else {
      assert(args.named().len() == 0,
        message: "faithful-acmart: with bib-backend " + repr(backend) + ", `bibliography` accepts "
          + "only `title`; got unexpected named argument(s) " + repr(args.named().keys()) + ".")
      assert(not full,
        message: "faithful-acmart: `full` (list every entry) is not supported with bib-backend "
          + repr(backend) + "; cite the entries you want listed.")
      assert(style == auto,
        message: "faithful-acmart: the reference style is fixed by the acmart `format`; the "
          + "`style` argument is not accepted with bib-backend " + repr(backend) + ".")
      // Indexing a path loses its source location in Typst.
      // Keep a single path inside arguments through read(); array paths must be project-absolute.
      let title = if title == auto { cfg.strings.references } else { title }
      let path = args.pos().first()
      if type(path) == str {
        _acm-bibliography(args, title: title)
      } else {
        for p in path {
          assert(type(p) != str or p.starts-with("/"),
            message: "faithful-acmart: with bib-backend " + repr(backend) + ", a bibliography of "
              + "multiple files must use project-absolute paths (start with \"/\"); a "
              + "single file may be relative. Got " + repr(p) + ".")
        }
        _acm-bibliography(path, title: title)
      }
    }
  }
}

#let acmart(
  format: "manuscript",
  title: none,
  subtitle: none,
  title-note: none,
  subtitle-note: none,
  authors: (),
  abstract: none,
  ccs: none,
  keywords: none,
  teaser: none,
  received: none,
  badges: none,
  // Translations are keyed by language, e.g. (french: (title: [...], abstract: [...])).
  language: none,
  translations: (:),
  journal: none,
  acm-volume: 1,
  acm-number: 1,
  acm-article: none,
  acm-year: datetime.today().year(),
  acm-month: datetime.today().month(),
  doi: "10.1145/nnnnnnn.nnnnnnn",
  conference: auto,
  booktitle: none,
  isbn: "978-x-xxxx-xxxx-x/YYYY/MM",
  code-data-link: none,
  contributions: none,
  acmcp-logo: none,
  // Ordered (label, value) pairs for the acmengage metadata block.
  engage-metadata: (),
  copyright: "acmlicensed",
  copyright-year: none,
  cc-type: "by",
  cc-version: "4.0",
  print-acm-reference: auto,
  print-ccs: true,
  print-folios: auto,
  bib-backend: "bibtex",
  cite-style: "numeric",
  tex-render: auto,
  short-title: auto,
  short-authors: auto,
  review: false,
  screen: false,
  anonymous: false,
  nonacm: false,
  author-version: false,
  timestamp: false,
  author-draft: false,
  submission-id: none,
  start-page: none,
  thanks: none,
  // auto derives the contact block from authors; none suppresses it; content replaces it.
  authors-addresses: auto,
  editors: (),
  // balance, pbalance, natbib, and acmthm are accepted for compatibility but have no effect.
  balance: true,
  pbalance: false,
  natbib: true,
  authors-per-row: 0,
  article-type: "Research",
  acmthm: true,
  url-break-on-hyphens: true,
  fix-quirks: false,
  draft: false,
  font-size: auto,
  body,
) = {
  let options = resolve-options((
    format: format,
    font-size: font-size,
    draft: draft,
    print-acm-reference: print-acm-reference,
    nonacm: nonacm,
    author-draft: author-draft,
    timestamp: timestamp,
    review: review,
    print-folios: print-folios,
    conference: conference,
    language: language,
    bib-backend: bib-backend,
    cite-style: cite-style,
    acm-month: acm-month,
    article-type: article-type,
    authors-per-row: authors-per-row,
    fix-quirks: fix-quirks,
  ))
  let cfg = options.cfg
  let print-acm-reference = options.print-acm-reference
  let timestamp = options.timestamp
  let review = options.review
  let print-folios = options.print-folios

  cite-style-state.update(cite-style)
  // Reset the renderer even at auto so a previous acmart scope cannot leak its callback.
  tex-render-state.update(_ => if tex-render == auto { default-tex-render } else { tex-render })

  let metadata = resolve-metadata(cfg, options.lang, (
    title: title,
    subtitle: subtitle,
    title-note: title-note,
    subtitle-note: subtitle-note,
    authors: authors,
    abstract: abstract,
    ccs: ccs,
    keywords: keywords,
    translations: translations,
    teaser: teaser,
    journal: journal,
    acm-volume: acm-volume,
    acm-number: acm-number,
    acm-article: acm-article,
    acm-year: acm-year,
    acm-month: acm-month,
    doi: doi,
    conference: conference,
    booktitle: booktitle,
    isbn: isbn,
    code-data-link: code-data-link,
    contributions: contributions,
    acmcp-logo: acmcp-logo,
    engage-metadata: engage-metadata,
    authors-per-row: authors-per-row,
    copyright: copyright,
    copyright-year: copyright-year,
    cc-type: cc-type,
    cc-version: cc-version,
    print-acm-reference: print-acm-reference,
    print-ccs: print-ccs,
    nonacm: nonacm,
    author-version: author-version,
    author-draft: author-draft,
    anonymous: anonymous,
    submission-id: submission-id,
    start-page: start-page,
    thanks: thanks,
    authors-addresses: authors-addresses,
    editors: editors,
  ))
  let meta = metadata.meta
  let screen = screen or metadata.force-screen
  set document(title: title, author: metadata.document.authors,
    keywords: metadata.document.keywords)

  let chrome = make-page-chrome(cfg, meta, (
    print-folios: print-folios,
    timestamp: timestamp,
    review: review,
    short-title: short-title,
    short-authors: short-authors,
    badges: badges,
    article-type: article-type,
    article: options.article,
  ))

  set page(
    width: cfg.paper.width,
    height: cfg.paper.height,
    margin: cfg.margin,
    columns: cfg.columns,
    // fancyhdr's strut depth hangs below the header baseline (\strutbox).
    header-ascent: cfg.head.sep + 0.3 * (if cfg.name == "manuscript" { cfg.bls.normalsize } else { cfg.bls.footnotesize }),
    // \footskip measures to the first footer baseline, including for multiline footers.
    footer-descent: cfg.foot.skip - cfg.size.footnotesize,
    header: chrome.header,
    footer: chrome.footer,
    background: chrome.background,
  )
  // Keep this set rule outside a conditional so it applies to the document body.
  set columns(gutter: cfg.columnsep)

  // Fix the line-box height so spacing.typ can reproduce baseline distances independently of font metrics.
  set text(
    font: cfg.fonts.body,
    size: cfg.font-size,
    top-edge: 1em,
    bottom-edge: 0pt,
    lang: cfg.lang,
    costs: (widow: 10000%, orphan: 10000%),
  )
  show math.equation: set text(font: cfg.fonts.math)

  set par(
    leading: comp(cfg),
    first-line-indent: cfg.parindent,
    spacing: tex-skip(cfg, cfg.parskip),
    justify: true,
  )

  set heading(numbering: cfg.heading-numbering)
  show heading: it => {
    if it.level == 1 and it.numbering != none { thm-counter.update(0) }
    render-heading(it, cfg)
  }
  // Exclude heading paragraphs from the adjacency state used by the heading renderer.
  show par: it => { context { if not _in-heading.get() { _body-since-heading.update(true) } }; it }

  let acm-dark-blue = cmyk(100%, 58%, 0%, 21%)
  let colorize = (it, body) => {
    let dest = it.dest
    // \urlstyle applies to URL text; \href display text keeps its surrounding font.
    let is-url-text = (type(dest) == str and not dest.starts-with("mailto:")
      and it.body.has("text") and it.body.text == dest)
    let body = if cfg.urlstyle-sans and is-url-text { text(font: cfg.fonts.sans, body) } else { body }
    if screen {
      text(fill: if type(dest) == str { acm-dark-blue } else { acm-purple }, body)
    } else { body }
  }
  show link: it => if url-break-on-hyphens {
    colorize(it, it)
  } else {
    // Restyle the existing element; constructing a new link would recurse through this rule.
    colorize(it, { show "-": "\u{2011}"; it })
  }

  // An unresolved ref is a bibliography key; document labels retain their element references.
  show ref: it => if it.element != none and it.element.func() == figure and it.element.kind == thm-figure-kind {
    thm-ref(it)
  } else if bib-backend != "typst" and it.element == none {
    bbl-cite(str(it.target), supplement: if it.supplement == auto { none } else { it.supplement })
  } else { it }

  let amsart-lists = options.amsart-lists
  cfg-state.update(cfg + (amsart-lists: amsart-lists))
  anon-state.update(anonymous)
  if start-page != none {
    assert(type(start-page) == int and start-page >= 1,
      message: "faithful-acmart: option `start-page` must be a positive integer, got " + repr(start-page))
    counter(page).update(start-page)
  }

  apply-body(cfg, amsart-lists: amsart-lists, {
    if meta.title != none {
      make-footnotes(cfg, meta)
      if cfg.columns > 1 {
        // An explicit full-width block prevents the title float from shrinking to the author grid.
        place(top, scope: "parent", float: true,
          clearance: tex-skip(cfg, if teaser != none { cfg.medskip } else { cfg.bigskip }),
          block(width: 100%, spacing: 0pt, make-title-head(cfg, meta)))
        make-title-body(cfg, meta)
      } else {
        make-title(cfg, meta)
      }
    } else if _body-starts-with-paragraph(body) {
      // Keep the indent in the opening paragraph; an empty paragraph would add leading.
      h(cfg.parindent)
    }

    if cfg.name == "acmcp" {
      make-acmcp-cover(cfg, meta, options.article.color, body)
    } else {
      body
    }

    if received != none { make-received(cfg, received) }
  })
}
