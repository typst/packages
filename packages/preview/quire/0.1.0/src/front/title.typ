/// This module renders the title: a full title page for books and reports, or a title block at the top of the first
/// page for articles.
#import "../config.typ": _rule, _ui
#import "../i18n.typ": translate
#import "../layout.typ": _recto-break, _title-marker
#import "meta.typ": _date

/// Builds the rows of the information grid: the authors, then the user-provided rows.
///
/// -> array
#let _info-rows(
  /// The normalized authors.
  /// -> array
  authors,
  /// The user-provided rows, as `(label, value)` pairs.
  /// -> array
  info,
) = {
  let rows = ()
  if authors.len() > 0 {
    rows.push((translate(if authors.len() > 1 { "authors" } else { "author" }), authors.map(a => a.name).join(", ")))
  }
  for row in info {
    assert(
      type(row) == array and row.len() == 2,
      message: "quire: info rows must be (label, value) pairs, got " + repr(row),
    )
    rows.push(row)
  }
  rows
}

/// Renders the full title page.
///
/// -> content
#let _title-page(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The document metadata.
  /// -> dictionary
  meta,
) = {
  _recto-break(cfg)

  set page(margin: 2.5cm, header: none, footer: none)
  set par(justify: false, first-line-indent: 0pt)

  // Institution (first line emphasized) and logo.
  if meta.institution != none or meta.logo != none {
    let lines = if type(meta.institution) == array { meta.institution } else if meta.institution != none {
      (meta.institution,)
    } else { () }

    grid(
      columns: (1fr, auto),
      align: (left + horizon, right + horizon),
      _ui(cfg, size: 10 / 12 * 1em, {
        if lines.len() > 0 {
          text(fill: cfg.colors.text, weight: "regular", upper(lines.first()))
        }
        if lines.len() > 1 {
          linebreak()
          upper(lines.slice(1).join[ · ])
        }
      }),
      if meta.logo != none { box(height: 3em, meta.logo) },
    )
  }

  block(spacing: 1fr, {
    if meta.kicker != none {
      block(_ui(cfg, size: 10 / 12 * 1em, upper(meta.kicker)))
    }

    block(spacing: 20 / 12 * 1em, width: 60%, text(size: 26 / 12 * 1em, meta.title))

    if meta.subtitle != none {
      block(
        spacing: 1.25em,
        width: 55%,
        text(size: 14 / 12 * 1em, style: "italic", fill: cfg.colors.muted, meta.subtitle),
      )
    }

    let rows = _info-rows(meta.authors, meta.info)
    if rows.len() > 0 {
      block(spacing: 40 / 12 * 1em, width: 80%, grid(
        columns: 2,
        column-gutter: 1.25em,
        row-gutter: 1.25em,
        ..rows
          .map(((label, value)) => (_ui(cfg, size: 10 / 12 * 1em, fill: cfg.colors.text, upper(label)), value))
          .flatten(),
      ))
    }
  })

  _ui(cfg, size: 10 / 12 * 1em, upper(_date(meta.date)) + h(1fr) + meta.version)

  _recto-break(cfg)
}

/// Renders the title block of an article at the top of the first page.
///
/// -> content
#let _title-block(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The document metadata.
  /// -> dictionary
  meta,
) = {
  [#metadata(none) #_title-marker]

  set par(justify: false, first-line-indent: 0pt)

  if meta.institution != none {
    let lines = if type(meta.institution) == array { meta.institution } else { (meta.institution,) }
    block(_ui(cfg, size: 10 / 12 * 1em, upper(lines.join[ · ])))
  }

  if meta.kicker != none {
    block(_ui(cfg, size: 10 / 12 * 1em, upper(meta.kicker)))
  }

  block(above: 1.25em, below: 1em, text(size: 2em, meta.title))

  if meta.subtitle != none {
    block(below: 1.5em, text(size: 14 / 12 * 1em, style: "italic", fill: cfg.colors.muted, meta.subtitle))
  }

  if meta.authors.len() > 0 {
    block(above: 1.5em, grid(
      columns: calc.min(meta.authors.len(), 3) * (1fr,),
      row-gutter: 1em,
      ..meta.authors.map(author => {
        author.name
        for line in (author.affiliation, author.email) {
          if line != none {
            linebreak()
            _ui(cfg, size: 10 / 12 * 1em, line)
          }
        }
      }),
    ))
  }

  let details = meta.info.map(((label, value)) => (
    _ui(cfg, size: 10 / 12 * 1em, fill: cfg.colors.text, upper(label)) + h(0.5em) + value
  ))
  if meta.date != none {
    details.push(_ui(cfg, size: 10 / 12 * 1em, upper(_date(meta.date))))
  }
  if meta.version != none {
    details.push(_ui(cfg, size: 10 / 12 * 1em, meta.version))
  }
  if details.len() > 0 {
    block(above: 1.5em, details.join(h(0.75em) + text(fill: cfg.colors.muted)[·] + h(0.75em)))
  }

  block(above: 1.5em, below: 2em, _rule(cfg, thickness: 0.5pt))
}
