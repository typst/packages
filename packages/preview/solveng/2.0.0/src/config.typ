// Options, their checks, and the two states: definitions and options.

#let _st = state("solveng", (:))
// errors are values (typst can't catch panics): (err: "message"), passed up and shown in the document
#let _err(m) = (err: m)
#let _E(x) = type(x) == dictionary and "err" in x
// the export target; Typst 0.14 only knows target() with --features html, else it is paged
#let _target() = if "target" in dictionary(std) { std.target() } else { "paged" }
// ---------- configuration: #worksheet(..) / #show: worksheet.with(..), or per call ----------
#let _DEF = (
  // numbers
  digits: 4, trailing-zeros: false, decimal-separator: auto, grouping: none, notation-thresholds: (-3, 6), notation: "auto", multiplication: "dot",
  number-form: "auto", max-denominator: 1000, fraction-style: "stacked",
  // units
  prefixes: "all", show-si: false, preferred-units: (),
  // output
  show-approximation: true, block: true, max-solutions: 6,
  // output of defined
  defined-style: "grid",
  // problems: shown in the document, or stop the compilation
  errors: "document",
  // types (f(x: #A)) in what solveng shows, the equations as written included: left out, as plain math or as chips
  show-types: "chip",
  // how they look: the word for any-unit types (a German text might want beliebig), the chips' colours or a
  // function drawing them, and units: a function given each shown unit, the decimal-separator between units
  words: (any: "any"), chips: auto, unit-style: auto, unit-separator: auto,
  // how constants are shown, by identity, over the built-in displays: (imaginary: $j$)
  constant-displays: (:),
  // graphs: per curve, repeating – Petroff's ten colors (apart for color-blind readers, lilaq's default too), the
  // line styles of scientific plotting tools, and dot shapes that tell curves apart without color too
  graph-colors: (rgb("#3f90da"), rgb("#ffa90e"), rgb("#bd1f01"), rgb("#94a4a2"), rgb("#832db6"), rgb("#a96b59"), rgb("#e76300"), rgb("#b9ac70"), rgb("#717581"), rgb("#92dadd")),
  graph-lines: ("solid", "dashed", "dotted", "dash-dotted"),
  graph-dots: ("circle", "square", "triangle", "diamond"),
  graph-joined: (false,),
)
// the strings options and graph's arguments take, alone or in an array: for the checks, and for editors' completions
// (as _CH, which also lists each option's only values)
#let _VALUES = (
  graph-dots: ("circle", "square", "triangle", "triangle-down", "diamond", "pentagon", "hexagon", "star", "cross", "plus"),
  graph-lines: ("solid", "dotted", "densely-dotted", "loosely-dotted", "dashed", "densely-dashed", "loosely-dashed", "dash-dotted", "densely-dash-dotted", "loosely-dash-dotted"),
  prefixes: ("all", "a", "f", "p", "n", "u", "µ", "m", "c", "d", "k", "M", "G", "T"),
  mark: ("crossings", "roots", "extrema"),
  // any string; these are the usual ones
  decimal-separator: (".", ","),
)
#let _DOTS = _VALUES.graph-dots
#let _DASHES = _VALUES.graph-lines
// a graph style, per curve: one value or an array of them, checked and made an array; (err: …) if it isn't one
// a graph style, per curve: one value or an array of them, checked and made an array; (err: …) if it isn't one.
// auto, alone or for a curve, keeps what the worksheets around (or the defaults) have there, see _merge.
#let _graph-style(name, v) = {
  let kind = name.split("-").last()
  if type(v) == content { return (err: name + ": square brackets make content – write an array with parentheses, like " + (colors: "(gray, blue)", lines: "(\"solid\", \"dashed\")", dots: "(\"circle\", \"square\")", joined: "(true, false)").at(kind)) }
  let fits(d) = d == auto or if kind == "colors" { type(d) in (color, gradient) } else if kind == "lines" {
    // a single pattern can be an array of lengths too: (4pt, 2pt) is one dash, ((4pt, 2pt), "dotted") two
    let lens(a) = type(a) == array and a.len() > 0 and a.all(l => type(l) == length or l == "dot")
    d == none or (type(d) == str and d in _DASHES) or lens(d) or (type(d) == dictionary and lens(d.at("array", default: none)) and d.keys().all(k => k in ("array", "phase")) and type(d.at("phase", default: 0pt)) == length)
  } else if kind == "dots" { d == none or (type(d) == str and d in _DOTS) } else { type(d) == bool }
  let one = type(v) != array or (kind == "lines" and v.len() > 0 and v.all(l => type(l) == length or l == "dot"))
  let v = if one { (v,) } else { v }
  if v.len() == 0 or not v.all(fits) {
    return (err: name + ": " + (
      colors: "a color or an array of colors like (gray, blue, rgb(\"#f98eff\"))",
      lines: "a dash pattern or an array of them, like (\"solid\", \"dashed\") or (4pt, 2pt); none draws no line; patterns: " + _DASHES.join(", "),
      dots: "a dot shape or an array of them, like (\"circle\", \"square\"); none draws no dots; shapes: " + _DOTS.join(", "),
      joined: "true (everything the curve draws joined with a line), false, or an array of these per curve",
    ).at(kind) + "; auto keeps the worksheet's, also for a single curve: (auto, \"dotted\")")
  }
  v
}
#let _GRAPH = ("graph-colors", "graph-lines", "graph-dots", "graph-joined")
// options given over the ones in force: a graph style curve by curve, auto keeping the one in force for that curve
#let _merge(c, lc) = {
  let out = c + lc
  for k in _GRAPH.filter(k => k in lc) {
    let (old, new) = (c.at(k), lc.at(k))
    let gcd(a, b) = { while b != 0 { (a, b) = (b, calc.rem(a, b)) }; a }
    let period = int(old.len() / gcd(old.len(), new.len())) * new.len()
    out.insert(k, range(period).map(i => {
      let v = new.at(calc.rem(i, new.len()))
      if v == auto { old.at(calc.rem(i, old.len())) } else { v }
    }))
  }
  out
}
#let _CH = (
  notation: ("auto", "plain", "scientific", "engineering"),
  number-form: ("auto", "decimal", "fraction", "input"), multiplication: ("dot", "times"), fraction-style: ("stacked", "slash"),
  errors: ("document", "panic"),
  show-types: ("none", "plain", "chip"), defined-style: ("grid", "column", "inline", "list"),
  // worksheet's scope, not an option
  scope: ("isolated", "inherit", "shared"),
)
// allowed types per option
#let _TY = (
  digits: (int,), trailing-zeros: (bool,), decimal-separator: (type(auto), str), grouping: (type(none), str, symbol, content), notation-thresholds: (type(none), array), notation: (str,),
  multiplication: (str,), number-form: (str,), max-denominator: (int,), fraction-style: (str,), prefixes: (str, type(none), array), show-si: (bool,),
  preferred-units: (array, content),
  show-approximation: (bool,), block: (bool,),
  max-solutions: (int,), defined-style: (str,), errors: (str,), show-types: (str,),
  words: (dictionary,), chips: (type(auto), dictionary, function), unit-style: (type(auto), function), unit-separator: (type(auto), content, str, symbol),
  constant-displays: (dictionary,),
  graph-colors: (array, color, gradient, content), graph-lines: (array, str, dictionary, type(none), content), graph-dots: (array, str, type(none), content), graph-joined: (array, bool, content),
)
// the colours of a kind of chip: fill, mark and ink, and the ones a dark page takes in `dark`
#let _chip-colours(v) = {
  let palette(p) = type(p) == dictionary and p.pairs().all(((k, c)) => k in ("fill", "mark", "ink") and type(c) == color)
  (type(v) == dictionary and palette(v.pairs().filter(((k, _)) => k != "dark").to-dict())
    and ("dark" not in v or palette(v.dark)))
}
#let _tyname(ts) = ts.map(t => if t == type(none) { "none" } else if t == type(auto) { "auto" } else { str(t) }).join(" or ")
// units are checked by the engine once a worksheet sets them (see #worksheet)
#let _check(o) = {
  if type(o) != dictionary { return (err: "config: expected a dictionary of options like (digits: 3), got " + str(type(o))) }
  let o = o
  for (k, v) in o {
    if k not in _DEF { return (err: "unknown option '" + k + "' (options: " + _DEF.keys().join(", ") + ")") }
    if type(v) not in _TY.at(k) { return (err: k + ": expected " + _tyname(_TY.at(k)) + ", got " + repr(v)) }
    if k in _CH and v not in _CH.at(k) { return (err: k + ": " + repr(v) + " – use one of " + _CH.at(k).map(repr).join(", ")) }
  }
  if "digits" in o and (o.digits < 1 or o.digits > 15) { return (err: "digits must be 1…15") }
  if "max-denominator" in o and o.max-denominator < 1 { return (err: "max-denominator must be ≥ 1") }
  if "max-solutions" in o and o.max-solutions < 1 { return (err: "max-solutions must be ≥ 1") }
  if "notation-thresholds" in o and o.notation-thresholds != none and (o.notation-thresholds.len() != 2 or o.notation-thresholds.any(x => type(x) != int)) { return (err: "notation-thresholds must be (low, high) with integers, or none") }
  if "prefixes" in o and type(o.prefixes) == str and o.prefixes != "all" { return (err: "prefixes: \"all\", none or an array like (\"m\", \"k\")") }
  if "prefixes" in o and type(o.prefixes) == array and o.prefixes.any(p => type(p) != str) { return (err: "prefixes: the array must hold strings like \"m\"") }
  if "words" in o and (o.words.keys().any(k => k != "any") or type(o.words.at("any", default: "any")) != str) { return (err: "words: the word shown for any-unit types, (any: \"beliebig\")") }
  if "chips" in o and type(o.chips) == dictionary and o.chips.pairs().any(((k, v)) => k != "type" or not _chip-colours(v)) { return (err: "chips: the colours of type chips, (type: (fill: …, mark: …, ink: …, dark: (fill: …, mark: …, ink: …))), or a function (kind, mark, unit) => content") }
  if "constant-displays" in o and o.constant-displays.values().any(v => type(v) not in (content, symbol)) { return (err: "constant-displays: how constants are shown, by identity: (imaginary: $j$)") }
  for k in _GRAPH {
    if k in o { let v = _graph-style(k, o.at(k)); if _E(v) { return v }; o.insert(k, v) }
  }
  if "preferred-units" in o {
    if type(o.preferred-units) == content { o.preferred-units = (o.preferred-units,) }
    if o.preferred-units.any(u => type(u) != content or u.func() != math.equation) { return (err: "preferred-units: math expressions containing unit values") }
  }
  o
}
// named option arguments -> the ones actually given (auto = keep the current setting)
#let _given(o) = o.pairs().filter(((k, v)) => v != auto).to-dict()
#let _cf = state("solveng-cf", _DEF)
