/// This module defines the template function.
#import "config.typ": _config, _resolve-config
#import "text.typ": _text-setup
#import "layout.typ": _layout-setup, _recto-break
#import "headings.typ": _headings-setup
#import "figures.typ": _figures-setup
#import "theorems.typ": _theorems-setup
#import "code.typ": _code-setup
#import "bibliography.typ": _bibliography-setup
#import "links.typ": _links-setup
#import "front/meta.typ": _abstracts, _authors, _plain
#import "front/title.typ": _title-block, _title-page
#import "front/preliminaries.typ": _abstract, _acknowledgments, _dedication-page, _outline

/// The template function, applied with a show rule at the beginning of the document.
///
/// The structure of the document is set by `top-level`, which gives the role of level-1 headings: with `"part"`,
/// `=` is a part, `==` a chapter and `===` a section; with `"chapter"`, `=` is a chapter; with `"section"`, `=` is
/// a section. Books and reports get a title page and preliminary pages (dedication, colophon, acknowledgments,
/// abstracts, contents) numbered in Roman numerals; articles get a title block at the top of the first page,
/// followed by the abstracts.
///
/// ```typ
/// #import "@preview/quire:0.1.0": *
///
/// #show: quire.with(
///   title: [On Bookbinding],
///   authors: "Jane Doe",
///   lang: "en",
///   top-level: "chapter",
///   output: "print",
/// )
/// ```
///
/// -> content
#let quire(
  /// The title of the document.
  /// -> content
  title: none,
  /// The subtitle of the document.
  /// -> none | content
  subtitle: none,
  /// The authors: a name, a dictionary with a `name` and optionally an `affiliation` and an `email`, or an array
  /// of those.
  /// -> str | content | dictionary | array
  authors: (),
  /// The date of the document. With `auto`, the current date. Dates are shown as "month year"; month names are
  /// always in English until Typst localizes them, so pass content to localize the date.
  /// -> auto | none | datetime | content
  date: auto,
  /// The version of the document.
  /// -> none | str | content
  version: none,
  /// A short description of the document, for the PDF metadata.
  /// -> none | str
  description: none,
  /// Keywords, for the PDF metadata and the abstracts.
  /// -> array
  keywords: (),
  /// The language of the document, as an ISO 639-1 code. The template is localized in English (`"en"`), Spanish
  /// (`"es"`) and Catalan (`"ca"`). With `auto`, the language set before the template applies.
  /// -> auto | str
  lang: auto,
  /// The region of the document, as an ISO 3166-1 alpha-2 code.
  /// -> auto | none | str
  region: auto,
  /// The role of level-1 headings: `"part"`, `"chapter"` or `"section"`.
  /// -> str
  top-level: "chapter",
  /// The output medium. `"print"` uses a wider inner margin, starts parts and chapters on a recto page (inserting
  /// blank pages as needed) and adds footnotes to links made with `href`. `"digital"` uses symmetric margins,
  /// never inserts blank pages and colors external links.
  /// -> str
  output: "digital",
  /// The paper size.
  /// -> str
  paper: "a4",
  /// The size of the body text. All other sizes are relative to it.
  /// -> length
  font-size: 12pt,
  /// Whether to render a full title page with preliminary pages. With `auto`, this is the case unless `top-level`
  /// is `"section"`; otherwise, a title block opens the first page.
  /// -> auto | bool
  title-page: auto,
  /// A short line above the title, e.g. the kind of document: `[Master's thesis · 2026]`.
  /// -> none | content
  kicker: none,
  /// The institution, shown at the top of the title. An array gives several lines (e.g. university, faculty,
  /// department), the first one emphasized.
  /// -> none | content | array
  institution: none,
  /// A logo shown next to the institution on the title page, e.g. `image("logo.svg")`.
  /// -> none | content
  logo: none,
  /// Further information shown with the authors on the title page, as `(label, value)` pairs, e.g.
  /// `(([Supervisor], [John Smith]), ([Defense], [June 2026]))`.
  /// -> array
  info: (),
  /// A dedication, centered on its own page. Requires a title page.
  /// -> none | content
  dedication: none,
  /// The license or copyright notice, shown in the default colophon.
  /// -> none | content
  license: none,
  /// The colophon, at the bottom of the dedication page: with `auto`, the title, copyright, license, typesetting
  /// details, version and date. Requires a title page.
  /// -> auto | none | content
  colophon: auto,
  /// The acknowledgments, as an unnumbered division before the abstract. Requires a title page.
  /// -> none | content
  acknowledgments: none,
  /// The abstract: its body, a dictionary with a `body` and optionally a `lang` and `keywords`, or an array of such
  /// dictionaries for abstracts in several languages. Abstracts without their own keywords use `keywords`.
  /// -> none | content | dictionary | array
  abstract: none,
  /// The table of contents: a boolean, or its depth. With `auto`, it is shown with a title page and hidden
  /// otherwise.
  /// -> auto | bool | int
  outline: auto,
  /// Font overrides, merged with the defaults. Keys are `serif`, `serif-small`, `sans`, `math` and `mono`; values
  /// are a family name, a fallback list of family names, or a dictionary of `text` arguments with an optional
  /// `scale` (an optical size factor). For instance, `(serif: "Libertinus Serif", sans: (font: "Inter", scale:
  /// 0.85))`.
  /// -> dictionary
  fonts: (:),
  /// Color overrides, merged with the defaults. Keys are `text`, `muted`, `link`, `rule` and `highlight`.
  /// -> dictionary
  colors: (:),
  /// How strong emphasis is rendered: `"smallcaps"` (the default, since EB Garamond has no bold weight) or
  /// `"bold"`.
  /// -> str
  strong: "smallcaps",
  /// The document.
  /// -> content
  body,
) = {
  let cfg = _resolve-config(
    top-level: top-level,
    output: output,
    fonts: fonts,
    colors: colors,
    strong: strong,
    title: title,
  )

  let title-page = if title-page == auto { top-level != "section" } else { title-page }
  assert(type(title-page) == bool, message: "quire: title-page must be auto or a boolean")
  if not title-page {
    assert(
      dedication == none and acknowledgments == none and colophon in (auto, none),
      message: "quire: dedication, acknowledgments and colophon require a title page",
    )
  }

  let outline = if outline == auto { title-page } else { outline }
  assert(type(outline) in (bool, int), message: "quire: outline must be auto, a boolean or an integer")

  let meta = (
    title: title,
    subtitle: subtitle,
    authors: _authors(authors),
    date: if date == auto { datetime.today() } else { date },
    version: version,
    kicker: kicker,
    institution: institution,
    logo: logo,
    info: info,
    dedication: dedication,
    license: license,
    colophon: colophon,
  )

  set document(
    title: title,
    author: meta.authors.map(a => _plain(a.name)),
    description: description,
    keywords: keywords,
    // A date given as content cannot be stored in the PDF metadata, so it is left out.
    date: if type(meta.date) == datetime { meta.date } else { none },
  )
  set text(lang: lang) if lang != auto
  set text(region: region) if region != auto

  _config.update(cfg)

  show: _text-setup.with(cfg, size: font-size)
  show: _layout-setup.with(cfg, paper: paper)
  show: _headings-setup.with(cfg)
  show: _figures-setup.with(cfg)
  show: _theorems-setup.with(cfg)
  show: _code-setup.with(cfg)
  show: _bibliography-setup.with(cfg)
  show: _links-setup.with(cfg)

  let abstracts = _abstracts(abstract, keywords)
  let depth = if type(outline) == int { outline } else { auto }

  if title-page {
    {
      set page(numbering: "i")

      _title-page(cfg, meta)
      _dedication-page(cfg, meta)
      if acknowledgments != none {
        _acknowledgments(cfg, acknowledgments)
      }
      for abstract in abstracts {
        _abstract(cfg, abstract)
      }
      if outline != false {
        _outline(cfg, depth: depth)
      }

      // Start the main matter on a recto, numbered from 1.
      _recto-break(cfg)
    }

    set page(numbering: "1")
    counter(page).update(1)
    body
  } else {
    set page(numbering: "1")

    _title-block(cfg, meta)
    for abstract in abstracts {
      _abstract(cfg, abstract, inline: true)
    }
    if outline != false {
      _outline(cfg, depth: depth)
    }

    body
  }
}
