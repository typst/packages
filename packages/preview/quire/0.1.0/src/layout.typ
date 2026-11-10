/// This module configures the page geometry, running heads, folios and paragraph settings.
#import "@preview/hydra:0.6.3": hydra
#import "config.typ": _rule, _ui

/// Page margins: symmetric for digital output, with a wider inner margin for print.
#let _margins = (
  digital: 2.5cm,
  print: (inside: 3cm, outside: 2.5cm, top: 2.5cm, bottom: 2.5cm),
)

/// Whether the current page is a blank page inserted to make the next page a recto.
#let _blank = state("quire-blank-page", false)

/// Label of the metadata marking the page of the article title block, where no running head is shown.
#let _title-marker = <quire-title-block>

/// Breaks the page. In print output, the next page is forced to be a recto (odd page), and any page inserted for
/// that purpose is marked as blank so that it carries no running head nor folio.
///
/// -> content
#let _recto-break(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// Whether the break is skipped when the current page is already empty.
  /// -> bool
  weak: true,
) = if cfg.output == "print" {
  _blank.update(true)
  pagebreak(to: "odd", weak: weak)
  _blank.update(false)
} else {
  pagebreak(weak: weak)
}

/// Classifies the current page: `"blank"` (inserted before a recto), `"part"` (a part page), `"opening"` (a chapter
/// opening or the title block of an article) or `"normal"`.
///
/// -> str
#let _page-kind(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
) = {
  let page = here().page()
  let on-page = it => it.location().page() == page

  if _blank.get() {
    return "blank"
  }

  if "part" in cfg.levels and query(heading.where(level: cfg.levels.part)).any(on-page) {
    return "part"
  }

  let opening = if "chapter" in cfg.levels {
    query(heading.where(level: cfg.levels.chapter)).any(on-page)
  } else {
    query(_title-marker).any(on-page)
  }

  if opening { "opening" } else { "normal" }
}

/// Hydra display function rendering a running-head mark as "Supplement number. Title" (or just "Title" when
/// unnumbered).
///
/// -> content
#let _mark-with-supplement(_, candidate) = {
  if candidate.numbering == none {
    upper(candidate.body)
  } else {
    let number = numbering(candidate.numbering, ..counter(heading).at(candidate.location()))
    upper[#candidate.supplement #number. #candidate.body]
  }
}

/// Hydra display function rendering a running-head mark as "number  Title" (or just "Title" when unnumbered).
///
/// -> content
#let _mark-with-number(_, candidate) = {
  if candidate.numbering == none {
    upper(candidate.body)
  } else {
    let number = numbering(candidate.numbering, ..counter(heading).at(candidate.location()))
    upper[#number #h(0.5em) #candidate.body]
  }
}

/// Renders a running head: two pieces of text separated by flexible space and followed by a rule.
///
/// -> content
#let _running-head(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// Left-aligned content.
  /// -> content
  left,
  /// Right-aligned content.
  /// -> content
  right,
) = _ui(cfg, size: 10 / 12 * 1em, left + h(1fr) + right) + _rule(cfg, thickness: 0.3pt)

/// The page header: the running head on normal pages, nothing on blank, part and opening pages.
///
/// -> content
#let _header(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
) = context {
  if _page-kind(cfg) != "normal" {
    return
  }

  let levels = cfg.levels
  let print = cfg.output == "print"
  let folio = counter(page).display()

  if print and calc.even(here().page()) {
    // Verso: folio and the major division (chapter, or the document title in articles).
    let mark = if "chapter" in levels {
      hydra(levels.chapter, display: _mark-with-supplement, book: true)
    } else {
      upper(cfg.title)
    }
    _running-head(cfg, folio, mark)
  } else {
    // Recto (or any page in digital output): the current section and the folio.
    _running-head(cfg, hydra(levels.section, display: _mark-with-number, book: print), folio)
  }
}

/// The page footer: a centered folio on opening pages, nothing elsewhere.
///
/// -> content
#let _footer(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
) = context {
  if _page-kind(cfg) == "opening" {
    align(center, _ui(cfg, size: 10 / 12 * 1em, counter(page).display()))
  }
}

/// Applies the page and paragraph settings.
///
/// -> content
#let _layout-setup(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The paper size.
  /// -> str
  paper: "a4",
  /// The content to apply the settings to.
  /// -> content
  body,
) = {
  set page(
    paper: paper,
    margin: _margins.at(cfg.output),
    header: _header(cfg),
    footer: _footer(cfg),
  )

  set par(
    justify: true,
    leading: 0.65em,
    spacing: 1.2em,
    first-line-indent: 1.25em,
  )

  show math.equation.where(block: true): set block(spacing: 1.2em)

  set list(indent: 1.25em)
  set enum(indent: 1.25em)
  show list: set block(spacing: 1.2em)
  show enum: set block(spacing: 1.2em)

  body
}
