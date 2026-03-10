#import "_util.typ"
#import "_draw.typ"

/// List of special values that `automath-value` should recognise
/// as math symbols.
#let _automath-values = (
  "+",
  "-",
  "m",
  "u",
  "alpha",
  "beta",
  "beta.alt",
  "gamma",
  "delta",
  "epsilon",
  "epsilon.alt",
  "zeta",
  "eta",
  "theta",
  "theta.alt",
  "iota",
  "kappa",
  "kappa.alt",
  "lambda",
  "mu",
  "nu",
  "xi",
  "omicron",
  "pi",
  "pi.alt",
  "rho",
  "rho.alt",
  "sigma",
  "sigma.alt",
  "tau",
  "upsilon",
  "phi",
  "phi.alt",
  "chi",
  "psi",
  "omega",
  "plus",
  "plus.minus",
  "minus",
  "minus.plus",
)

/// Automatically transform certain types of feature values to math equations.
/// 
/// Transforms feature values `"+"`, `"-"`, `"u"`, `"m"`, `"plus.minus"`,
/// `"minus.plus"` as well as the lowercase greek letter names (e.g. `"alpha"`,
/// `"beta"`) and numerals (e.g. `"0"`, `"99"`) plus potentially a preceeding 
/// `"+"` or `"-"` into a math equation.
/// 
/// Any other string passed to `_automath-value` will be returned as is.
/// 
/// Examples:
///   - ```typc _automath-value("+")``` -> $+$```
///   - ```typc _automath-value("gamma")``` -> $gamma$```
///   - ```typc _automath-value("plus.minus")``` -> $plus.minus$```
///   - ```typc _automath-value("-phi.alt")``` -> $- phi.alt$```
///   - ```typc _automath-value("something else")``` -> "something else"```
/// -> str
#let _automath-value(
  value
) = {
  let vparts = ()
  if value.len() > 1 and (value.starts-with("+") or value.starts-with("-")) {
    vparts.push(value.slice(0, 1))
    vparts.push(value.slice(1))
  } else {
    vparts.push(value)
  }
  if vparts.last() in _automath-values or vparts.last().match(regex("^[0-9]+$$")) != none {
    return eval("$" + vparts.join(" ") +"$")
  }
  return value
}

/// Construct a bare (un-braced) tabular feature matrix.
/// 
/// -> content
#let _bare-matrix-tabular(..feats) = {
  let cells = ()
  for feat in feats.pos() {
    if type(feat) == array and feat.len() > 1 {
      // valued feature
      cells.push(_automath-value(feat.at(0))) // value
      cells.push(feat.at(1))                  // label
    } else if type(feat) == array {
      // monovalent / privative feature
      cells.push(table.cell(colspan: 2, align: left, feat.at(0)))
    } else {
      // a submatrix or non-feature label
      cells.push(
        table.cell(colspan: 2, align: center, feat)
      )
    }
  }
  table(
    columns: (auto, auto),
    align: (center, left),
    stroke: none,
    gutter: 0em,
    inset: (left: 0em, top: 0.25em, bottom: 0.25em, right: 0.25em),
    ..cells
  )
}

/// Constructs a bare (un-braced) inline feature matrix.
/// 
/// -> content
#let _bare-matrix-inline(..feats) = {
  feats.pos().map(
    feat => {
      if type(feat) == array and feat.len() > 1 {
        // valued feature
        [#_automath-value(feat.at(0))\u{202f}#feat.at(1)]
      } else if type(feat) == array {
        // monovalent / privative feature
        [#feat.at(0)]
      } else {
        // a submatrix or non-feature label
        [#feat]
      }
    }
  ).join(", ")
}

/// Construct a bare (un-braced) feature matrix.
/// 
/// -> content
#let _bare-matrix(..feats, tabular: true) = {
  if tabular {
    _bare-matrix-tabular(..feats)
  } else {
    _bare-matrix-inline(..feats)
  }
}

/// Add braces to a tabular feature matrix.
/// 
/// -> content
#let _brace-matrix-tabular(
  matrix,
  valign: horizon,
  delim: ("[", "]")
) = {
  delim = _util.parse-delim(delim)
  let baseline = 0% + 0.225em
  if valign.y == horizon {
    baseline = 50% - 0.35em
  } else if valign.y == top {
    baseline = 100% - 0.9em
  }
  context {
    let matrix-height = measure(matrix).height
    let items = ()
    if delim.left != none {
      items.push(_draw.bracket(delim.left, matrix-height))
    }
    items.push(matrix)
    if delim.right != none {
      items.push(_draw.bracket(delim.right, matrix-height))
    }
    box(
      baseline: baseline,
      stack(
        dir: ltr,
        spacing: 0em,
        ..items
      )
    )
  }
}

/// Add braces to an inline feature matrix.
/// 
/// -> content
#let _brace-matrix-inline(
  matrix,
  delim: ("[", "]")
) = {
  delim = _util.parse-delim(delim)
  let items = ()
  if delim.left != none {
    items.push(delim.left)
  }
  items.push(matrix)
  if delim.right != none {
    items.push(delim.right)
  }
  items.join("")
}

/// Add braces to a feature matrix.
/// 
/// -> content
#let _brace-matrix(
  matrix,
  valign: horizon,
  tabular: true,
  delim: ("[", "]")
) = {
  if tabular {
    _brace-matrix-tabular(matrix, valign: valign, delim: delim)
  } else {
    _brace-matrix-inline(matrix, delim: delim)
  }
}

/// Feature matrix
/// 
/// -> content
#let fmat(..feats, tabular: true, valign: horizon, delim: ("[", "]"), submatrix-delim: ("<", ">")) = {
  // Find and pre-compose sub-matrices
  feats = feats.pos().map(
    feat => {
      if type(feat) == array and feat.len() > 0 and type(feat.at(0)) == array {
        // sub-feature matrix -> wrap in angle brackets
        _brace-matrix(
          tabular: tabular,
          valign: valign,
          delim: submatrix-delim,
          _bare-matrix(..feat, tabular: tabular)
        )
      } else {
        feat
      }
    }
  )
  _brace-matrix(
    tabular: tabular,
    valign: valign,
    delim: delim,
    _bare-matrix(..feats, tabular: tabular)
  )
}

#let fmat-tabular = fmat.with(tabular: true)
#let fmat-inline = fmat.with(tabular: false)
