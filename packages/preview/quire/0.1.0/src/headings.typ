/// This module maps heading levels to structural roles (part, chapter, section, subsection) according to the
/// `top-level` option, and renders each role.
#import "@preview/num2words:0.2.0": num2words
#import "config.typ": _config, _rule, _ui
#import "i18n.typ": translate
#import "layout.typ": _recto-break

/// Whether the current position is in the appendix.
#let _in-appendix = state("quire-appendix", false)

/// Returns the structural role of a heading level (`"part"`, `"chapter"`, `"section"`, `"subsection"`), or `none`
/// for deeper levels.
///
/// -> str | none
#let _role(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The heading level.
  /// -> int
  level,
) = {
  let pair = cfg.levels.pairs().find(((_, l)) => l == level)
  if pair == none { none } else { pair.first() }
}

/// Builds the heading numbering. With parts, part headings are numbered with Roman numerals and are left out of the
/// numbers of their descendants, so that chapters are numbered continuously throughout the document.
///
/// -> str | function
#let _heading-numbering(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The numbering pattern of chapters (or sections, without chapters) and their descendants.
  /// -> str
  pattern,
) = if "part" in cfg.levels {
  (..nums) => {
    let nums = nums.pos()
    if nums.len() == 1 { numbering("I", ..nums) } else { numbering(pattern, ..nums.slice(1)) }
  }
} else {
  pattern
}

/// Gives each heading the localized name of its role as supplement (used in references and running heads).
///
/// -> content
#let _supplements(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// Whether the headings are in the appendix, where the top numbered division is named "Appendix".
  /// -> bool
  appendix: false,
  /// The content to apply the supplements to.
  /// -> content
  body,
) = {
  let appendix-level = cfg.levels.at("chapter", default: cfg.levels.section)

  // Deeper headings are named like subsections.
  set heading(supplement: translate("subsection"))

  // Show-set rules cannot be created in a loop directly, so each one wraps the body built so far.
  for (role, level) in cfg.levels {
    let name = if appendix and level == appendix-level { "appendix" } else { role }
    body = {
      show heading.where(level: level): set heading(supplement: translate(name))
      body
    }
  }

  body
}

/// Formats `number` within the current chapter and section, e.g. `2.3.1` for the first element in section 3 of
/// chapter 2. Trailing zero levels are dropped, so an element before the first section is numbered `2.1`. The
/// heading numbers are formatted with the numbering in effect (Arabic numerals or appendix letters). Requires
/// context.
///
/// -> str
#let _within-section(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The heading counter values at the element.
  /// -> array
  heads,
  /// The number of the element within its section.
  /// -> int
  number,
) = {
  let heads = heads.slice(0, calc.min(heads.len(), cfg.levels.section))
  while heads.len() > 0 and heads.last() == 0 {
    let _ = heads.pop()
  }

  let offset = if "part" in cfg.levels { 1 } else { 0 }
  if heads.len() <= offset {
    str(number)
  } else {
    numbering(heading.numbering, ..heads) + "." + str(number)
  }
}

/// Resets the counters of figures and equations, which are numbered within sections.
///
/// -> content
#let _reset-counters() = {
  for kind in (image, table, raw) {
    counter(figure.where(kind: kind)).update(0)
  }
  counter(math.equation).update(0)
}

/// Renders an epigraph: a short rule, the quotation in muted italics and its attribution.
///
/// -> content
#let _epigraph(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The quotation.
  /// -> content
  quote,
  /// The attribution.
  /// -> none | content
  attribution,
) = {
  _rule(cfg, length: 15%, thickness: 0.5pt)

  block(spacing: 2.5em, width: 60%, {
    set par(justify: false, leading: 0.8em, first-line-indent: 0pt)
    text(style: "italic", fill: cfg.colors.muted, quote)
    if attribution != none {
      linebreak()
      _ui(cfg, tracking: 0pt)[--- #attribution]
    }
  })
}

/// Renders the label, number and title shared by part and chapter headings.
///
/// -> content
#let _division-title(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The heading element.
  /// -> content
  it,
) = {
  if it.numbering != none {
    // Chapters spell their number out in the label ("Chapter one"), except in the appendix, where they are lettered.
    let label = if _role(cfg, it.level) == "chapter" and not _in-appendix.get() {
      let number = counter(heading).get().at(it.level - 1)
      [#it.supplement #num2words(number, fallback: "en")]
    } else {
      it.supplement
    }
    _ui(cfg, size: 10 / 12 * 1em, upper(label))
    v(1.25em, weak: true)
    text(size: 5em, counter(heading).display(it.numbering))
    v(25 / 12 * 1em, weak: true)
  }
  block(width: 60%, text(size: 2em, it.body))
}

/// Renders a part heading on a page of its own.
///
/// -> content
#let _render-part(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The heading element.
  /// -> content
  it,
  /// An optional epigraph shown below the title.
  /// -> none | content
  epigraph: none,
  /// The attribution of the epigraph.
  /// -> none | content
  attribution: none,
) = {
  _recto-break(cfg)

  v(1fr)
  block(below: 2.5em, _division-title(cfg, it))
  if epigraph != none {
    _epigraph(cfg, epigraph, attribution)
  }
  v(1fr)

  // Keep chapter numbers running across parts: the heading counter has just been reset below this part, so restore
  // the number of chapters seen so far. This must come after the part number is displayed. In the appendix,
  // chapters are lettered within each part instead.
  context if not _in-appendix.get() {
    let chapters = counter(heading.where(level: cfg.levels.chapter)).get().last()
    counter(heading).update((..nums) => (nums.pos().first(), chapters))
  }

  _recto-break(cfg, weak: false)
}

/// Renders a chapter heading, either at the top of the page followed by the text, or vertically centered on an
/// opening page of its own.
///
/// -> content
#let _render-chapter(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The heading element.
  /// -> content
  it,
  /// Whether to render a chapter opening page.
  /// -> bool
  opening: false,
  /// An optional epigraph shown below the title.
  /// -> none | content
  epigraph: none,
  /// The attribution of the epigraph.
  /// -> none | content
  attribution: none,
) = {
  _recto-break(cfg)
  _reset-counters()

  if opening {
    v(1fr)
    block(below: 2.5em, _division-title(cfg, it))
    if epigraph != none {
      _epigraph(cfg, epigraph, attribution)
    }
    v(1fr)
    pagebreak(weak: true)
  } else {
    block(below: 2.5em, _division-title(cfg, it))
    if epigraph != none {
      _epigraph(cfg, epigraph, attribution)
    }
  }
}

/// Renders a section heading: the section sign and number above the title.
///
/// -> content
#let _render-section(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The heading element.
  /// -> content
  it,
) = {
  _reset-counters()

  block(above: 25 / 12 * 1em, below: 20 / 12 * 1em, {
    if it.numbering != none {
      _ui(cfg, size: 1.5em, [#sym.section #counter(heading).display(it.numbering)])
      v(1em, weak: true)
    }
    text(size: 5 / 3 * 1em, it.body)
  })
}

/// Renders a subsection or deeper heading: the number and the title on the same line.
///
/// -> content
#let _render-minor(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The heading element.
  /// -> content
  it,
  /// The size of the title.
  /// -> length
  size,
) = block(above: 20 / 12 * 1em, below: 1.25em, {
  if it.numbering != none {
    _ui(cfg, size: 0.9 * size, counter(heading).display(it.numbering))
    h(2 / 3 * 1em)
  }
  text(size: size, it.body)
})

/// Renders a heading according to its role.
///
/// -> content
#let _render-heading(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The heading element.
  /// -> content
  it,
) = {
  let role = _role(cfg, it.level)
  if role == "part" {
    _render-part(cfg, it)
  } else if role == "chapter" {
    _render-chapter(cfg, it)
  } else if role == "section" {
    _render-section(cfg, it)
  } else if role == "subsection" {
    _render-minor(cfg, it, 1.25em)
  } else {
    _render-minor(cfg, it, 13 / 12 * 1em)
  }
}

/// Applies the heading settings.
///
/// -> content
#let _headings-setup(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The content to apply the settings to.
  /// -> content
  body,
) = {
  set heading(numbering: _heading-numbering(cfg, "1.1"))
  show: _supplements.with(cfg)

  show heading: set par(justify: false, first-line-indent: 0pt)
  show heading: set text(weight: "medium")
  show heading: it => _render-heading(cfg, it)

  body
}

/// Inserts a heading of the given role, rendered by `render` instead of the default rule for its level.
///
/// -> content
#let _division(
  /// The structural role of the heading.
  /// -> str
  role,
  /// The function rendering the heading, given the configuration and the heading element.
  /// -> function
  render,
  /// The title.
  /// -> content
  title,
  /// Label attached to the heading.
  /// -> none | label
  label: none,
  /// Whether the heading is numbered.
  /// -> bool
  numbered: true,
  /// Whether the heading appears in the outline.
  /// -> bool
  outlined: true,
) = context {
  let cfg = _config.get()
  assert(role in cfg.levels, message: "quire: '" + role + "' is not available with top-level '" + cfg.top-level + "'")

  let level = cfg.levels.at(role)
  show heading.where(level: level): it => render(cfg, it)

  let numbering = if numbered { auto } else { none }
  let division = heading(level: level, outlined: outlined, ..if not numbered { (numbering: none) }, title)
  if label == none { division } else [#division#label]
}

/// Inserts a part heading on a page of its own, with an optional epigraph. A plain level-1 heading (`= Title`) is
/// equivalent when no epigraph is needed. Only available with `top-level: "part"`.
///
/// ```typ
/// #part(
///   [Foundations],
///   epigraph: [Begin at the beginning, and go on till you come to the end: then stop.],
///   attribution: [Lewis Carroll],
/// )
/// ```
///
/// -> content
#let part(
  /// The title of the part.
  /// -> content
  title,
  /// Label attached to the heading, to reference it.
  /// -> none | label
  label: none,
  /// Whether the part is numbered.
  /// -> bool
  numbered: true,
  /// An optional epigraph shown below the title.
  /// -> none | content
  epigraph: none,
  /// The attribution of the epigraph.
  /// -> none | content
  attribution: none,
) = _division(
  "part",
  _render-part.with(epigraph: epigraph, attribution: attribution),
  title,
  label: label,
  numbered: numbered,
)

/// Inserts a chapter heading. By default the chapter opens on a page of its own, with the title vertically centered
/// and an optional epigraph; with `opening: false` it behaves like a plain chapter heading followed by the epigraph.
/// Not available with `top-level: "section"`.
///
/// ```typ
/// #chapter(
///   [Introduction],
///   label: <intro>,
///   epigraph: [The beginning is the most important part of the work.],
///   attribution: [Plato],
/// )
/// ```
///
/// -> content
#let chapter(
  /// The title of the chapter.
  /// -> content
  title,
  /// Label attached to the heading, to reference it.
  /// -> none | label
  label: none,
  /// Whether the chapter is numbered.
  /// -> bool
  numbered: true,
  /// Whether the chapter opens on a page of its own.
  /// -> bool
  opening: true,
  /// An optional epigraph shown below the title.
  /// -> none | content
  epigraph: none,
  /// The attribution of the epigraph.
  /// -> none | content
  attribution: none,
) = _division(
  "chapter",
  _render-chapter.with(opening: opening, epigraph: epigraph, attribution: attribution),
  title,
  label: label,
  numbered: numbered,
)

/// Starts the appendices: chapters (or sections, without chapters) are numbered with letters from here on and named
/// "Appendix". Apply it with a show rule where the appendices begin.
///
/// ```typ
/// #show: appendix
/// = Supplementary proofs
/// ```
///
/// -> content
#let appendix(
  /// The appendices.
  /// -> content
  body,
) = context {
  let cfg = _config.get()

  _in-appendix.update(true)
  set heading(numbering: _heading-numbering(cfg, "A.1"))
  show: _supplements.with(cfg, appendix: true)

  if "part" in cfg.levels {
    counter(heading).update((..nums) => (nums.pos().at(0, default: 0), 0))
  } else {
    counter(heading).update(0)
  }

  body
}
