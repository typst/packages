// Interpret TeX syntax in bibliography fields for rendering, labels, and sorting.

#import "../formats/_base.typ": tp

#let _lex(c) = {
  if c == " " or c == "\t" or c == "\n" or c == "\r" { "ws" }
  else if c == "~" or c == "-" { "sep" }
  else if c >= "0" and c <= "9" { "num" }
  else if (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") { "alpha" }
  else { "other" }
}

// bibtex.web, pre_define(control_seq_ilk): the foreign letters recognized by purify$.
#let foreign-purify = (
  i: "i", j: "j", o: "o", O: "O", l: "l", L: "L",
  oe: "oe", OE: "OE", ae: "ae", AE: "AE", aa: "a", AA: "A", ss: "ss",
)
#let _foreign-lower = (L: "l", O: "o", OE: "oe", AE: "ae", AA: "aa")
#let _foreign-upper = (l: "L", o: "O", oe: "OE", ae: "AE", aa: "AA")

// bibtex.web, x_purify: special-character groups have their own whitespace and control-sequence rules.
#let _purify-special(cp, n, p) = {
  let out = ""
  let bl = 1
  p += 1
  while p < n and bl > 0 {
    p += 1
    let y = p
    while p < n and _lex(cp.at(p)) == "alpha" { p += 1 }
    let cs = if p > y { cp.slice(y, p).join("") } else { "" }
    if cs in foreign-purify { out += foreign-purify.at(cs) }
    while p < n and bl > 0 and cp.at(p) != "\\" {
      let cc = cp.at(p)
      let l = _lex(cc)
      if l == "alpha" or l == "num" { out += cc }
      else if cc == "}" { bl -= 1 } else if cc == "{" { bl += 1 }
      p += 1
    }
  }
  (out, p - 1)
}

#let purify(s) = {
  let cp = s.codepoints()
  let n = cp.len()
  let out = ""
  let bl = 0
  let p = 0
  while p < n {
    let c = cp.at(p)
    let l = _lex(c)
    if l == "ws" or l == "sep" { out += " " }
    else if l == "alpha" or l == "num" { out += c }
    else if c == "{" {
      bl += 1
      if bl == 1 and p + 1 < n and cp.at(p + 1) == "\\" {
        let (so, sp) = _purify-special(cp, n, p)
        out += so
        p = sp
        bl = 0
      }
    } else if c == "}" { if bl > 0 { bl -= 1 } }
    p += 1
  }
  out
}

#let _conv-str(s, ct) = if ct == "u" { upper(s) } else { lower(s) }

#let _change-special(cp, n, p, ct) = {
  let out = "{"
  let bl = 1
  p += 1
  while p < n and bl > 0 {
    p += 1
    let x = p
    while p < n and _lex(cp.at(p)) == "alpha" { p += 1 }
    let cs = cp.slice(x, p).join("")
    out += "\\"
    if (ct == "t" or ct == "l") and cs in _foreign-lower { out += _foreign-lower.at(cs) }
    else if ct == "u" and cs in _foreign-upper { out += _foreign-upper.at(cs) }
    else { out += cs }
    let x2 = p
    while p < n and bl > 0 and cp.at(p) != "\\" {
      let cc = cp.at(p)
      if cc == "}" { bl -= 1 } else if cc == "{" { bl += 1 }
      p += 1
    }
    out += _conv-str(cp.slice(x2, p).join(""), ct)
  }
  (out, p - 1)
}

// bibtex.web, x_change_case: braces protect case except within special-character groups.
#let change-case(s, ct) = {
  let cp = s.codepoints()
  let n = cp.len()
  let out = ""
  let bl = 0
  let prev-colon = false
  let p = 0
  while p < n {
    let c = cp.at(p)
    if c == "{" {
      bl += 1
      let give-up = bl != 1 or p + 4 > n or cp.at(p + 1) != "\\"
      if ct == "t" and not give-up {
        if p == 0 { give-up = true }
        else if prev-colon and _lex(cp.at(p - 1)) == "ws" { give-up = true }
      }
      if not give-up {
        let (so, sp) = _change-special(cp, n, p, ct)
        out += so
        p = sp
        bl = 0
      } else { out += "{" }
      prev-colon = false
    } else if c == "}" {
      if bl > 0 { bl -= 1 }
      out += "}"
      prev-colon = false
    } else if bl == 0 {
      if ct == "t" {
        if p == 0 or (prev-colon and _lex(cp.at(p - 1)) == "ws") { out += c }
        else { out += lower(c) }
        if c == ":" { prev-colon = true }
        else if _lex(c) != "ws" { prev-colon = false }
      } else { out += _conv-str(c, ct) }
    } else { out += c }
    p += 1
  }
  out
}

#let _unsupported(what) = panic(
  "tex-render: unsupported TeX " + what + ". Supply a `tex-render` callback "
  + "that handles this case and falls back to `default-tex-render` for the rest.")

#let _is-alpha(c) = (c >= "a" and c <= "z") or (c >= "A" and c <= "Z")
#let _is-num(c) = c >= "0" and c <= "9"
#let _is-alnum(c) = _is-alpha(c) or _is-num(c)
#let _tokenize(cp, i, stop) = {
  let n = cp.len()
  let toks = ()
  let run = ""
  while i < n {
    let c = cp.at(i)
    if stop != none and c == stop { break }
    if c == "\\" {
      if run != "" { toks.push((kind: "text", value: run)); run = "" }
      i += 1
      if i >= n { toks.push((kind: "cs", name: "\\")); break }
      let d = cp.at(i)
      if _is-alpha(d) {
        let j = i
        while j < n and _is-alpha(cp.at(j)) { j += 1 }
        toks.push((kind: "cw", name: cp.slice(i, j).join("")))
        i = j
        while i < n and cp.at(i) == " " { i += 1 }
      } else {
        toks.push((kind: "cs", name: d))
        i += 1
      }
    } else if c == "{" {
      if run != "" { toks.push((kind: "text", value: run)); run = "" }
      let (body, ni) = _tokenize(cp, i + 1, "}")
      toks.push((kind: "group", body: body))
      i = if ni < n { ni + 1 } else { ni }
    } else if c == "$" {
      if run != "" { toks.push((kind: "text", value: run)); run = "" }
      let (body, ni) = _tokenize(cp, i + 1, "$")
      toks.push((kind: "math", body: body))
      i = if ni < n { ni + 1 } else { ni }
    } else if c == "~" or c == "^" or c == "_" {
      if run != "" { toks.push((kind: "text", value: run)); run = "" }
      toks.push((kind: "special", char: c))
      i += 1
    } else if c == "}" {
      i += 1
    } else {
      run += c
      i += 1
    }
  }
  if run != "" { toks.push((kind: "text", value: run)) }
  (toks, i)
}
#let _lex-tokens(s) = _tokenize(s.codepoints(), 0, none).at(0)

// An unbraced TeX argument consumes one token, so split text runs at their first grapheme.
#let _grab(rest) = {
  let r = rest
  while r.len() > 0 and r.first().kind == "text" {
    let cps = r.first().value.codepoints()
    let k = 0
    while k < cps.len() and (cps.at(k) == " " or cps.at(k) == "\t" or cps.at(k) == "\n") { k += 1 }
    if k == cps.len() { r = r.slice(1) }
    else { r = ((kind: "text", value: cps.slice(k).join("")),) + r.slice(1); break }
  }
  if r.len() == 0 { return ((), ()) }
  let h = r.first()
  if h.kind == "group" { return (h.body, r.slice(1)) }
  if h.kind == "text" {
    let cl = h.value.clusters()
    let remaining = if cl.len() <= 1 { r.slice(1) }
      else { ((kind: "text", value: cl.slice(1).join("")),) + r.slice(1) }
    return (((kind: "text", value: cl.first()),), remaining)
  }
  ((h,), r.slice(1))
}

// Accents produce decomposed Unicode; normalize before comparing names written in different forms.
#let _accent-cs = (
  "\"": "\u{0308}", "'": "\u{0301}", "`": "\u{0300}", "^": "\u{0302}",
  "~": "\u{0303}", "=": "\u{0304}", ".": "\u{0307}",
)
#let _accent-cw = (
  H: "\u{030B}", v: "\u{030C}", u: "\u{0306}", r: "\u{030A}",
  k: "\u{0328}", c: "\u{0327}", b: "\u{0331}", d: "\u{0323}",
)
#let _special-letters = (
  ss: "ß", SS: "ẞ", ae: "æ", AE: "Æ", oe: "œ", OE: "Œ", aa: "å", AA: "Å",
  o: "ø", O: "Ø", l: "ł", L: "Ł", i: "ı", j: "ȷ",
)

// Biber decodes characters before name parsing while preserving structural braces.
// Accent-protecting braces disappear; braces around letter commands remain.
#let _accent-of(name) = _accent-cs.at(name, default: _accent-cw.at(name, default: none))
#let _dotted(t) = t.replace("ı", "i").replace("ȷ", "j")
#let _accented = m => {
  let d = _accent-of(m.captures.at(0))
  if d == none { return m.text }
  let a = m.captures.at(1)
  _dotted(if a.starts-with("\\") { _special-letters.at(a.slice(1)) } else { a }) + d
}
#let _cs-or-cw = "([A-Za-z]+|[\"'`^~=.])"
#let _acc-arg = "(\\p{L}|\\\\[ij])"
#let decode-chars(s) = {
  s
    .replace(regex("\\{\\\\" + _cs-or-cw + "[ \t\n]*\\{?" + _acc-arg + "\\}?\\}"), _accented)
    .replace(regex("\\\\" + _cs-or-cw + "[ \t\n]*\\{" + _acc-arg + "\\}"), _accented)
    .replace(regex("\\\\([\"'`^~=.])[ \t\n]*" + _acc-arg), _accented)
    .replace(regex("\\\\([A-Za-z]+)[ \t\n]+" + _acc-arg), _accented)
    .replace(regex("\\\\([A-Za-z]+)(\\{\\})?[ \t\n]*"),
      m => _special-letters.at(m.captures.at(0), default: m.text))
}
// newtxmath.sty, \DeclareMathSizes; unlisted sizes use LaTeX's \defaultscriptratio.
#let _script-sizes = (
  (5, 5.5), (6, 5.5), (7, 5.5), (8, 6), (9, 6.6), (10, 7.3), (10.95, 8), (11, 8),
  (12, 8.8), (14.4, 10.5), (17.28, 12.5), (20.74, 16.1), (24.88, 18.2),
)
#let script-size(size) = {
  let pt = size / tp
  for (text-size, script) in _script-sizes {
    if calc.abs(pt - text-size) < 0.005 { return script * tp }
  }
  0.7 * size
}

// \textsuperscript scales ordinary glyphs; disable Typst's substitution of dedicated superscript glyphs.
#let script-super(body) = context super(
  typographic: false, size: script-size(text.size), body)

// latex.ltx, \TeX: baseline shifts preserve glyph advance widths.
#let _tex-tail = context {
  let ex = measure(text(top-edge: "x-height", bottom-edge: "baseline")[x]).height
  [T#h(-0.1667em)#box(baseline: 0.5 * ex)[E]#h(-0.125em)X]
}

// latex.ltx, \LaTeX: the smaller A's cap top aligns with the T.
#let _latex-a = context {
  let size = text.size
  let a-size = script-size(size)
  let cap = measure(text(top-edge: "cap-height", bottom-edge: "baseline")[T]).height
  box(baseline: -cap * (1 - a-size / size), text(size: a-size)[A])
}

#let tex-logo = box(height: 1em, _tex-tail)
#let latex-logo = box(height: 1em, [L#h(-0.36em)#_latex-a#h(-0.15em)] + _tex-tail)
#let bibtex-logo = box(height: 1em, [Bib] + _tex-tail)
#let latexe-logo = box(height: 1em, [L#h(-0.36em)#_latex-a#h(-0.15em)] + _tex-tail + [2e])

#let _logos = (LaTeX: "LATEX", TeX: "TEX", BibTeX: "BibTEX", LaTeXe: "LATEX2e")
#let _logo-content = (LaTeX: latex-logo, TeX: tex-logo, BibTeX: bibtex-logo, LaTeXe: latexe-logo)
// \emph toggles emphasis; \textit and \textsl force an italic shape.
#let _emph-cw = ("emph",)
#let _italic-cw = ("textit", "textsl")
#let _strong-cw = ("textbf",)
#let _sc-cw = ("textsc",)
#let _id-cw = ("textrm", "textsf", "textnormal", "textup", "textmd", "mbox", "text")
// Declarations apply to the rest of the enclosing group.
#let _switch-cw = (
  it: "it", itshape: "it", sl: "it", slshape: "it", em: "em",
  bf: "bf", bfseries: "bf",
  sc: "sc", scshape: "sc",
  tt: "tt", ttfamily: "tt",
  rm: "id", rmfamily: "id", sf: "id", sffamily: "id",
  normalfont: "id", upshape: "id", mdseries: "id",
)
#let _noop-cw = ("relax", "protect", "noindent")
#let _cs-literal = ("&": "&", "%": "%", "$": "$", "#": "#", "_": "_", "{": "{", "}": "}")
#let _cs-space = (" ": " ", ",": "\u{2009}", ";": " ", ":": " ")
#let _noop-cs = ("/", "-", "!", "@")

// Typst does not apply markup substitutions to interpolated strings.
#let _render-run(s) = {
  s = s.replace("---", "\u{2014}").replace("--", "\u{2013}")
  s = s.replace("``", "\u{201C}").replace("''", "\u{201D}")
  s = s.replace("`", "\u{2018}").replace("'", "\u{2019}")
  s
}

// Separate math letters so Typst does not parse adjacent letters as one identifier.
#let _math-run(s) = {
  let out = ""
  let prev = none
  for c in s.codepoints() {
    if prev != none and _is-alnum(prev) and _is-alnum(c) and not (_is-num(prev) and _is-num(c)) {
      out += " "
    }
    out += c
    prev = c
  }
  out
}

#let _math-sym = (
  alpha: "alpha", beta: "beta", gamma: "gamma", delta: "delta", epsilon: "epsilon",
  varepsilon: "epsilon.alt", zeta: "zeta", eta: "eta", theta: "theta", vartheta: "theta.alt",
  iota: "iota", kappa: "kappa", lambda: "lambda", mu: "mu", nu: "nu", xi: "xi",
  omicron: "omicron", pi: "pi", varpi: "pi.alt", rho: "rho", varrho: "rho.alt",
  sigma: "sigma", varsigma: "sigma.alt", tau: "tau", upsilon: "upsilon", phi: "phi",
  varphi: "phi.alt", chi: "chi", psi: "psi", omega: "omega",
  Gamma: "Gamma", Delta: "Delta", Theta: "Theta", Lambda: "Lambda", Xi: "Xi",
  Pi: "Pi", Sigma: "Sigma", Upsilon: "Upsilon", Phi: "Phi", Psi: "Psi", Omega: "Omega",
  times: "times", cdot: "dot.c", div: "div", pm: "plus.minus", mp: "minus.plus",
  ast: "ast.op", star: "star.op", oplus: "plus.o", otimes: "times.o",
  odot: "dot.o", circ: "compose", bullet: "bullet", cup: "union", cap: "inter",
  setminus: "without", wedge: "and", land: "and", vee: "or", lor: "or",
  leq: "lt.eq", le: "lt.eq", geq: "gt.eq", ge: "gt.eq", neq: "eq.not", ne: "eq.not",
  approx: "approx", equiv: "equiv", sim: "tilde.op", simeq: "tilde.eq", cong: "tilde.equiv",
  propto: "prop", ll: "lt.double", gg: "gt.double",
  to: "arrow.r", rightarrow: "arrow.r", Rightarrow: "arrow.r.double", leftarrow: "arrow.l",
  Leftarrow: "arrow.l.double", leftrightarrow: "arrow.l.r", mapsto: "arrow.r.bar",
  infty: "infinity", partial: "partial", nabla: "nabla", forall: "forall", exists: "exists",
  neg: "not", "in": "in", notin: "in.not", ni: "in.rev", subset: "subset",
  subseteq: "subset.eq", supset: "supset", supseteq: "supset.eq", emptyset: "emptyset",
  varnothing: "nothing", perp: "perp", parallel: "parallel", angle: "angle", ell: "ell",
  hbar: "planck", aleph: "aleph", prime: "prime", dag: "dagger", ddag: "dagger.double",
  ldots: "dots.h", dots: "dots.h", cdots: "dots.c",
  sum: "sum", prod: "product", int: "integral",
)
#let _math-op-cw = (
  log: "log", ln: "ln", exp: "exp", sin: "sin", cos: "cos", tan: "tan", cot: "cot",
  sec: "sec", csc: "csc", lim: "lim", limsup: "limsup", liminf: "liminf", max: "max",
  min: "min", sup: "sup", inf: "inf", det: "det", dim: "dim", gcd: "gcd", bmod: "mod",
)
#let _math-fn1 = (
  sqrt: "sqrt", mathbb: "bb", mathcal: "cal", mathbf: "bold", mathrm: "upright",
  mathit: "italic", mathsf: "sans", mathtt: "mono", mathfrak: "frak", boldsymbol: "bold",
  hat: "hat", widehat: "hat", tilde: "tilde", widetilde: "tilde", bar: "macron",
  overline: "overline", underline: "underline", vec: "arrow", dot: "dot", ddot: "dot.double",
  check: "caron", breve: "breve", acute: "acute", grave: "grave",
)
#let _math-fn2 = (frac: "frac", tfrac: "frac", dfrac: "frac", binom: "binom")
#let _math-noop = ("left", "right", "displaystyle", "textstyle", "scriptstyle",
  "limits", "nolimits", "bigl", "bigr", "big", "Big", "biggl", "biggr")
#let _math-cs-space = (
  ",": "thin", ":": "med", ">": "med", ";": "thick", " ": "space",
  "!": "#h(-(1em)/6)",
)

#let _apply(tag, x, cont) = {
  if not cont { x }
  else if tag == "em" { emph(x) }
  else if tag == "it" { text(style: "italic", x) }
  else if tag == "bf" { strong(x) }
  else if tag == "sc" { smallcaps(x) }
  else if tag == "ul" { underline(x) }
  else { x }
}

// One evaluator permits recursive mode changes without mutual recursion, which Typst cannot bind.
// Iterate over tokens so field length does not consume call depth.
#let _eval(toks, mode) = {
  let cont = mode == "content"
  let math = mode == "math"
  let out = if cont { [] } else { "" }
  let rest = toks
  while rest.len() > 0 {
    let t = rest.first()
    let tail = rest.slice(1)
    let next = tail
    let piece = if cont { [] } else { "" }

    if t.kind == "text" {
      piece = if math { _math-run(t.value) + " " } else { _render-run(t.value) }
    } else if t.kind == "group" {
      let g = _eval(t.body, mode)
      // Flattening math groups makes later scripts attach to the last atom; this is an approximation.
      piece = if math { g + " " } else { g }
    } else if t.kind == "math" {
      if cont { piece = eval(_eval(t.body, "math"), mode: "math") }
      else if math { piece = _eval(t.body, "math") }
      else { _unsupported("inline math in a name/label field") }
    } else if t.kind == "special" {
      if math {
        if t.char == "~" { piece = "space.nobreak " }
        else {
          let (a, r) = _grab(tail)
          piece = t.char + "(" + _eval(a, "math") + ") "
          next = r
        }
      } else if t.char == "~" { piece = "\u{00A0}" }
      else { _unsupported("character '" + t.char + "' outside math mode (use $...$, \\textasciicircum or \\textunderscore)") }
    } else if t.kind == "cw" {
      let nm = t.name
      if math {
        if nm in _math-op-cw { piece = "op(\"" + _math-op-cw.at(nm) + "\") " }
        else if nm in _math-sym { piece = _math-sym.at(nm) + " " }
        else if nm in _math-fn1 { let (a, r) = _grab(tail); piece = _math-fn1.at(nm) + "(" + _eval(a, "math") + ") "; next = r }
        else if nm in _math-fn2 {
          let (a, r) = _grab(tail)
          let (b, r2) = _grab(r)
          piece = _math-fn2.at(nm) + "(" + _eval(a, "math") + ", " + _eval(b, "math") + ") "
          next = r2
        }
        else if nm == "text" or nm == "mbox" or nm == "textrm" {
          let (a, r) = _grab(tail)
          let s = _eval(a, "string").replace("\\", "\\\\").replace("\"", "\\\"")
          piece = "\"" + s + "\" "; next = r
        }
        else if nm in _math-noop { }
        else { _unsupported("math command \\" + nm) }
      } else if nm in _special-letters { piece = _special-letters.at(nm) }
      else if nm in _logos { piece = if cont { _logo-content.at(nm) } else { _logos.at(nm) } }
      else if nm == "ensuremath" {
        let (a, r) = _grab(tail); next = r
        piece = if cont { eval(_eval(a, "math"), mode: "math") } else { _unsupported("\\ensuremath in a name/label field") }
      }
      else if nm in _accent-cw { let (a, r) = _grab(tail); piece = _dotted(_eval(a, "string")) + _accent-cw.at(nm); next = r }
      else if nm in _id-cw { let (a, r) = _grab(tail); piece = _eval(a, mode); next = r }
      else if nm in _switch-cw {
        let tag = _switch-cw.at(nm); next = ()
        if tag == "tt" { let s = _eval(tail, "string"); piece = if cont { raw(s) } else { s } }
        else { piece = _apply(tag, _eval(tail, mode), cont) }
      }
      else if nm in _emph-cw { let (a, r) = _grab(tail); piece = _apply("em", _eval(a, mode), cont); next = r }
      else if nm in _italic-cw { let (a, r) = _grab(tail); piece = _apply("it", _eval(a, mode), cont); next = r }
      else if nm in _strong-cw { let (a, r) = _grab(tail); piece = _apply("bf", _eval(a, mode), cont); next = r }
      else if nm in _sc-cw { let (a, r) = _grab(tail); piece = _apply("sc", _eval(a, mode), cont); next = r }
      else if nm == "underline" { let (a, r) = _grab(tail); piece = _apply("ul", _eval(a, mode), cont); next = r }
      else if nm == "textsuperscript" { let (a, r) = _grab(tail); let x = _eval(a, mode); piece = if cont { script-super(x) } else { x }; next = r }
      else if nm == "textsubscript" { let (a, r) = _grab(tail); let x = _eval(a, mode); piece = if cont { sub(x) } else { x }; next = r }
      else if nm == "texttt" { let (a, r) = _grab(tail); let s = _eval(a, "string"); piece = if cont { raw(s) } else { s }; next = r }
      else if nm == "url" { let (a, r) = _grab(tail); let u = _eval(a, "string"); piece = if cont { link(u)[#u] } else { u }; next = r }
      else if nm == "href" { let (a, r) = _grab(tail); let (b, r2) = _grab(r); let u = _eval(a, "string"); let x = _eval(b, mode); piece = if cont { link(u)[#x] } else { x }; next = r2 }
      else if nm == "noopsort" { let (a, r) = _grab(tail); next = r }
      else if nm in _noop-cw { }
      else { _unsupported("command \\" + nm) }
    } else if t.kind == "cs" {
      let nm = t.name
      if math {
        if nm in _math-cs-space { piece = _math-cs-space.at(nm) + " " }
        else { _unsupported("math command \\" + nm) }
      } else if nm in _accent-cs { let (a, r) = _grab(tail); piece = _dotted(_eval(a, "string")) + _accent-cs.at(nm); next = r }
      else if nm in _cs-literal { piece = _cs-literal.at(nm) }
      else if nm in _cs-space { piece = _cs-space.at(nm) }
      else if nm in _noop-cs { }
      else { _unsupported("command \\" + nm) }
    }

    out += piece
    rest = next
  }
  out
}

#let tex-to-content(s) = if type(s) != str { s } else { _eval(_lex-tokens(s), "content") }
#let tex-to-string(s) = if type(s) != str { s } else { _eval(_lex-tokens(s), "string") }
