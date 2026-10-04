//converter.typ
#let _get(property, ..qnts) = { qnts.pos().map(q => q.at(property)) }

#let multiply-unit(..units) = {
  units = units.pos()

  let result = ()
  for (name, exp) in units {
    let found = result.position(((n, e)) => n == name)
    if found == none {
      result.push((name, exp))
    } else {
      result.at(found).at(1) += exp
    }
  }
  result.filter(((n, e)) => e != 0)
}

#let invert-unit(..units) = { units.pos().map(((n, e)) => (n, -e)) }

#let operate-unit(..units, func: it => it) = { units.pos().map(((n, e)) => (n, func(e))) }

#let power-unit(..units, n) = operate-unit(..units, func: e => n * e)

#let root-unit(..units, n) = operate-unit(..units, func: e => e / n)

// significant number determination categorized by operations
#let mul-signify(..qnts) = {
  let values = _get("value", ..qnts)
  let figures = _get("figures", ..qnts) 
  if values.any(v => v == 0) {
    return 0
  } else {
    calc.min(..figures)
  }
}

#let add-signify(..qnts) = {
  qnts = qnts.pos().filter(q => q.value != 0)
  let places = _get("places", ..qnts)
  calc.min(..places)
}

#let exp-signify(exp) = {
  if exp.value == 0 { return 1 }
  if exp.places == 0 { return exp.figures } else { exp.places }
}

// Root-sum-square (quadrature) combination of numeric error terms.
// Each term should already be the full contribution (∂f/∂xi · σxi),
// not just σxi.
#let rss(..terms) = calc.sqrt(terms.pos().map(t => t * t).sum())

// Builds `sqrt((term1)^2 + (term2)^2 + ...)` as typeset content, given
// the content for each contribution. Mirrors `rss` but for display.
#let rss-method(..terms) = {
  let terms = terms.pos()
  $sqrt(#terms.map(t => $(#t)^2$).join($+$))$
}