#import "parser/ast.typ"

/// Render a principal number.
///
/// - Letters should be rendered in italics.
/// - Numbers should be rendered as is.
/// -> content
#let principal(
  /// The principal number to render.
  ///
  /// Handled AST tags:
  /// - number
  /// - letter
  ///
  /// -> dictionary
  n
) = if n.tag == "number" {
  [#n.value]
} else if n.tag == "letter" {
  math.italic(n.value)
} else {
  panic("don't know how to render this principal number", n)
}

/// Render an azimuthal orbital number.
///
/// - Letters should be rendered upright.
/// - Numbers should be rendered surrounded by square brackets (`[]`).
/// - Fractions should be rendered horizontal, surrounded by square brackets (`[]`).
///
/// -> content
#let azimuth(
  /// The azimuthal orbital number to render.
  ///
  /// Handled AST tags:
  /// - letter
  /// - number
  /// - fraction
  ///
  /// -> dictionary
  l
) = if l.tag == "letter" {
  math.upright(l.value)
} else if l.tag == "number" {
  [$[#l.value]$]
} else if l.tag == "fraction" {
  // NOTE: Math mode is needed here to get the bracket scaling to work properly.
  [$[frac(
    #[#l.numerator],
    #[#l.denominator],
    style: "horizontal",
  )]$]
} else {
  panic("don't know how to render this azimuth", l)
}

/// Render an orbital.
///
/// - Fractional subscripts are put in ```typ sscript``` for better aesthetics.
///
/// -> content
#let orbital(
  /// The orbital to render.
  ///
  /// Handled AST tags: orbital
  ///
  /// -> dictionary
  orb,
  /// Whether to display an occupation number that is one.
  /// -> bool
  display-single-occupation
) = {
  assert(orb.tag == "orbital")

  principal(orb.principal)

  math.attach(
    azimuth(orb.azimuth),
    tr: if
      (display-single-occupation and orb.occupation.value == 1) or
      orb.occupation.value > 1 or
      orb.occupation.value < 0
    {
      [#orb.occupation.value]
    },
    br: if orb.subscript == none {
      none
    } else if orb.subscript.tag == "number" {
      [#orb.subscript.value]
    } else if orb.subscript.tag == "fraction" {
      [$sscript(orb.subscript.numerator / orb.subscript.denominator)$]
    } else {
      panic(
        "don't know how to render this orbital subscript",
        orb.subscript,
      )
    }
  )
}

/// Render the character of a term symbol.
///
/// - Letters should be rendered upright.
/// - Numbers should be rendered surrounded by square brackets.
/// - Fractions should be rendered surrounded by square brackets.
///
/// -> content
#let character(
  /// The character to render.
  ///
  /// Handled AST tags:
  /// - letter
  /// - number
  /// - fraction
  ///
  /// -> dictionary
  c
) = if c.tag == "letter" {
  math.upright(c.value)
} else if c.tag == "number" {
  [$[#c.value]$]
} else if c.tag == "fraction" {
  [$[#c.numerator / #c.denominator]$]
}

/// Render a term symbol.
/// -> content
#let term-symbol(
  /// The term symbol to render.
  ///
  /// Handled AST tags: term
  ///
  /// -> dictionary
  term,
  /// The content to use to indicate an odd parity term symbol.
  /// -> str | symbol | content
  parity-marker
) = {
  assert(term.tag == "term")

  math.attach(
    character(term.character),
    tl: str(term.multiplicity.value),
    tr: if term.pi == ast.parity.odd {
      parity-marker
    },
    br: if term.J == none {
      none
    } else if term.J.tag == "number" {
      [#term.J.value]
    } else if term.J.tag == "fraction" {
      [$#term.J.numerator / #term.J.denominator$]
    } else {
      panic("don't know how to render term J", term.J)
    },
  )
}


/// Render a full state.
/// -> content
#let state(
  /// The state to render.
  ///
  /// Handled AST tags: state
  ///
  /// -> dictionary
  st,
  /// The content to use to indicate an odd parity term symbol.
  /// -> str | symbol | content
  parity-marker,
  /// Whether to display an occupation number that is one.
  /// -> bool
  display-single-occupation,
) = {
  assert(st.tag == "state")

  if st.element != none {
    [$[#math.upright(st.element.value)] #math.thick$]
  }

  st.configuration.map(
    part => {
      if part.tag == "orbital" {
        orbital(part, display-single-occupation)
      } else if part.tag == "term" {
        [$(#term-symbol(part, parity-marker))$]
      }
    }
  ).join(math.thin)

  if st.term != none {
    [#math.thick #term-symbol(st.term, parity-marker)]
  }
}
