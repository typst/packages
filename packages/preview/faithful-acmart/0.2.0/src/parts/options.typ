// Resolve document options into the active format configuration.

#import "../formats/acmsmall.typ": acmsmall
#import "../formats/manuscript.typ": manuscript
#import "../formats/acmlarge.typ": acmlarge
#import "../formats/acmtog.typ": acmtog
#import "../formats/sigconf.typ": sigconf
#import "../formats/sigplan.typ": sigplan
#import "../formats/acmengage.typ": acmengage
#import "../formats/sigchi-a.typ": sigchia
#import "../formats/acmcp.typ": acmcp
#import "strings.typ": resolve-language
#import "metadata.typ": resolve-conference
#import "colors.typ": acm-orange, acm-purple

#let formats = (
  manuscript: manuscript,
  acmsmall: acmsmall,
  acmlarge: acmlarge,
  acmtog: acmtog,
  sigconf: sigconf,
  siggraph: sigconf,
  sigchi: sigconf,
  sigplan: sigplan,
  acmengage: acmengage,
  "sigchi-a": sigchia,
  acmcp: acmcp,
)

#let acmcp-article-types = (
  "Research": (nr: 0, color: cmyk(100%, 10%, 0%, 10%)),
  "Review": (nr: 1, color: acm-orange),
  "Discussion": (nr: 2, color: cmyk(20%, 0%, 100%, 19%)),
  "Invited": (nr: 3, color: acm-purple),
  "Position": (nr: 4, color: cmyk(0%, 90%, 86%, 0%)),
)

#let resolve-options(data) = {
  let format = data.format
  let font-size = data.font-size
  let print-acm-reference = data.print-acm-reference
  let nonacm = data.nonacm
  let author-draft = data.author-draft
  let timestamp = data.timestamp
  let review = data.review
  let print-folios = data.print-folios
  let bib-backend = data.bib-backend
  let article-type = data.article-type

  assert(
    format in formats,
    message: "faithful-acmart: unknown format: " + format,
  )
  let cfg = if font-size == auto {
    (formats.at(format))()
  } else {
    (formats.at(format))(font-size: font-size)
  }

  assert(
    data.draft == false,
    message: "faithful-acmart: option `draft` has no effect in this Typst port, so it is "
      + "rejected rather than silently ignored. In acmart `draft` only marks "
      + "overfull lines with a rule (acmart.dtx:2865); Typst has no equivalent "
      + "and instead reports overflow as compiler warnings. Remove `draft` to "
      + "compile.",
  )

  // \acmConference changes the bibstrip flags independently of the format family (acmart.dtx, \acmConference).
  let conference = resolve-conference(cfg, data.conference)
  let acmsmall-conference = cfg.name == "acmsmall" and conference != none
  let bibstrip-flags = (
    bibstrip: cfg.journal and conference == none,
    bibstrip-or-tog: cfg.journal and not acmsmall-conference,
  )

  let print-acm-reference = if print-acm-reference == auto {
    not nonacm and cfg.name != "acmcp"
  } else {
    print-acm-reference
  }

  // authordraft sets review directly, bypassing the review option hook that forces folios on.
  let timestamp = timestamp or author-draft
  let review = review or author-draft
  let print-folios = if print-folios == auto {
    cfg.journal and not acmsmall-conference
  } else {
    print-folios
  }
  let print-folios = print-folios or data.review

  // These options register hooks before amsart loads, letting its list dimensions win.
  // authordraft bypasses those hooks, so use the explicit review option here.
  let amsart-lists = data.review or nonacm

  let article = if cfg.name == "acmcp" {
    assert(article-type in acmcp-article-types,
      message: "faithful-acmart: Article Type must be Research, Review, Discussion, Invited, or Position")
    acmcp-article-types.at(article-type)
  }

  assert(type(data.fix-quirks) == bool,
    message: "faithful-acmart: `fix-quirks` must be a boolean; got " + repr(data.fix-quirks) + ".")

  let lang = resolve-language(data.language)
  let cfg = cfg + (strings: lang, lang: lang.code, bib-backend: bib-backend,
    fix-quirks: data.fix-quirks)
  let cfg = cfg + bibstrip-flags

  assert(bib-backend in ("typst", "bibtex", "biblatex"),
    message: "faithful-acmart: `bib-backend` must be \"typst\", \"bibtex\", or \"biblatex\".")
  assert(data.cite-style in ("numeric", "author-year"),
    message: "faithful-acmart: `cite-style` must be \"numeric\" or \"author-year\".")
  assert(type(data.acm-month) == int and data.acm-month >= 1 and data.acm-month <= 12,
    message: "faithful-acmart: `acm-month` must be an integer 1..12; got " + repr(data.acm-month) + ".")
  assert(type(data.authors-per-row) == int and data.authors-per-row >= 0,
    message: "faithful-acmart: `authors-per-row` must be a non-negative integer "
      + "(0 selects the automatic per-row default); got " + repr(data.authors-per-row) + ".")

  (
    cfg: cfg,
    lang: lang,
    print-acm-reference: print-acm-reference,
    timestamp: timestamp,
    review: review,
    print-folios: print-folios,
    amsart-lists: amsart-lists,
    article: article,
  )
}
