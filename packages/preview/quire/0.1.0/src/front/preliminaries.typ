/// This module renders the preliminary pages: dedication and colophon, acknowledgments, abstracts and contents.
#import "../config.typ": _family, _family-name, _rule, _scale, _ui
#import "../i18n.typ": translate
#import "../layout.typ": _recto-break
#import "../headings.typ": _role
#import "meta.typ": _date

/// The heading level of front-matter divisions: chapters, or sections without chapters.
///
/// -> int
#let _front-level(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
) = cfg.levels.at("chapter", default: cfg.levels.section)

/// An unnumbered front-matter heading, shown in the outline.
///
/// -> content
#let _front-heading(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The title.
  /// -> content
  title,
) = heading(level: _front-level(cfg), numbering: none, outlined: true, title)

/// Builds the default colophon: title, copyright line, license, typesetting details, and version and date.
///
/// -> content
#let _default-colophon(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The document metadata.
  /// -> dictionary
  meta,
) = {
  meta.title
  parbreak()

  set text(fill: cfg.colors.muted)

  let year = if type(meta.date) == datetime { meta.date.display("[year]") }
  let names = meta.authors.map(a => a.name).join(", ")
  ([#sym.copyright], year, names).filter(it => it != none).join(" ")
  parbreak()

  if meta.license != none {
    meta.license
    parbreak()
  }

  let fonts = ("serif", "sans", "math", "mono").map(key => _family-name(cfg, key)).dedup()
  let fonts = if fonts.len() > 1 { fonts.slice(0, -1).join(", ") + [ #translate("conjunction") ] + fonts.last() } else {
    fonts.first()
  }
  [#translate("typeset-with") Typst #sys.version #translate("in-fonts") #fonts.]
  parbreak()

  (meta.version, _date(meta.date)).filter(it => it != none).join[ · ]
}

/// Renders the page holding the dedication (centered, in italics) and the colophon (at the bottom). Nothing is
/// rendered when both are absent.
///
/// -> content
#let _dedication-page(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The document metadata.
  /// -> dictionary
  meta,
) = {
  let colophon = if meta.colophon == auto { _default-colophon(cfg, meta) } else { meta.colophon }
  if meta.dedication == none and colophon == none {
    return
  }

  _recto-break(cfg)

  set page(margin: 2.5cm, header: none, footer: none)
  set par(justify: false, leading: 0.8em, first-line-indent: 0pt)

  align(center, block(spacing: 1fr, width: 50%, text(size: 15 / 12 * 1em, style: "italic", meta.dedication)))

  if colophon != none {
    block(width: 70%, text(.._family(cfg, "sans"), size: 11 / 12 * 1em * _scale(cfg, "sans"), colophon))
  }
}

/// Renders the acknowledgments as an unnumbered front-matter division.
///
/// -> content
#let _acknowledgments(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The acknowledgments.
  /// -> content
  body,
) = {
  _front-heading(cfg, translate("acknowledgments"))
  text(size: 11 / 12 * 1em, body)
}

/// Renders the keywords line of an abstract.
///
/// -> content
#let _keywords(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The keywords.
  /// -> array
  keywords,
) = grid(
  columns: (auto, 1fr),
  column-gutter: 25 / 12 * 1em,
  _ui(cfg, size: 10 / 12 * 1em, fill: cfg.colors.text, upper(translate("keywords"))), keywords.join[ · ],
)

/// Renders an abstract, either as a front-matter division (books and reports) or inline below the title block
/// (articles).
///
/// -> content
#let _abstract(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The normalized abstract.
  /// -> dictionary
  abstract,
  /// Whether to render the abstract inline.
  /// -> bool
  inline: false,
) = {
  set text(lang: abstract.lang) if abstract.lang != none
  set par(first-line-indent: 0pt)

  if inline {
    block(below: 2em, pad(x: 2em, {
      set text(size: 11 / 12 * 1em)
      block(below: 1em, _ui(cfg, size: 10 / 11 * 1em, fill: cfg.colors.text, upper(translate("abstract"))))
      abstract.body
      if abstract.keywords.len() > 0 {
        block(above: 1.25em, _keywords(cfg, abstract.keywords))
      }
    }))
  } else {
    // Resolve the title in the language of the abstract, so that the outline shows it in that language too.
    _front-heading(cfg, translate("abstract", lang: if abstract.lang == none { auto } else { abstract.lang }))
    abstract.body
    if abstract.keywords.len() > 0 {
      block(above: 25 / 12 * 1em, _rule(cfg, thickness: 0.5pt))
      block(above: 1em, _keywords(cfg, abstract.keywords))
    }
  }
}

/// Renders a major outline entry (chapters, or sections without chapters): a rule above, then the number, title and
/// page. The first entry gets a stronger rule.
///
/// -> content
#let _major-entry(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The outline entry.
  /// -> content
  entry,
  /// Whether this is the first entry of the outline.
  /// -> bool
  first,
) = {
  if first { line(length: 100%, stroke: 0.6pt + cfg.colors.text) } else { _rule(cfg) }

  let prefix = if entry.element.numbering == none { sym.dash.em } else { entry.prefix() }
  block(above: 10 / 12 * 1em, below: 10 / 12 * 1em, entry.indented(
    _ui(cfg, fill: cfg.colors.text, prefix),
    entry.body() + h(1fr) + _ui(cfg, fill: cfg.colors.text, entry.page()),
    gap: 20 / 12 * 1em,
  ))
}

/// Renders a minor outline entry (sections, or subsections without chapters) in a muted style.
///
/// -> content
#let _minor-entry(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The outline entry.
  /// -> content
  entry,
) = {
  set text(size: 11 / 12 * 1em)
  let prefix = if entry.element.numbering == none { [] } else { entry.prefix() }
  block(above: 0.5em, below: 0.5em, entry.indented(
    _ui(cfg, prefix),
    text(fill: cfg.colors.muted, entry.body()) + h(1fr) + _ui(cfg, entry.page()),
    gap: 15 / 12 * 1em,
  ))
}

/// Renders a part outline entry: the part label and title in the interface style, between generous spacing.
///
/// -> content
#let _part-entry(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The outline entry.
  /// -> content
  entry,
) = {
  let label = if entry.element.numbering == none { none } else [#entry.element.supplement #entry.prefix()]
  block(above: 2em, below: 1em, _ui(cfg, fill: cfg.colors.text, upper({
    if label != none { label + h(1em) }
    entry.body()
    h(1fr)
    entry.page()
  })))
}

/// Renders the outline: a front-matter division in books and reports, or an inline section in articles.
///
/// -> content
#let _outline(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The depth of the outline. `auto` lists divisions down to sections (or subsections, without chapters).
  /// -> auto | int
  depth: auto,
) = {
  let major = _front-level(cfg)
  let depth = if depth == auto { major + 1 } else { depth }

  show outline: set heading(outlined: true, numbering: none, offset: major - 1)

  show outline.entry: entry => link(entry.element.location(), {
    if _role(cfg, entry.level) == "part" {
      _part-entry(cfg, entry)
    } else if entry.level == major {
      let first = query(heading.where(outlined: true)).find(h => h.level <= depth)
      _major-entry(cfg, entry, first != none and first.location() == entry.element.location())
    } else if entry.level == major + 1 {
      _minor-entry(cfg, entry)
    } else {
      entry
    }
  })

  outline(title: translate("contents"), depth: depth)
}
