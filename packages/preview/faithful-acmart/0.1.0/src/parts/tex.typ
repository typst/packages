// TeX-string semantics for the "bst" bibliography backend.
//
// This module is the single home for *TeX text handling*, split by purpose from
// the .bib parser (bibtex.typ) and the .bst formatter (acmref.typ):
//
//   * the LOGIC layer — `purify` and `change-case`, exact ports of BibTeX's
//     `purify$` and `change.case$` built-ins (string -> string, math-blind,
//     brace/special-character aware). BibTeX carries the RAW TeX string through
//     its whole pipeline and only ever applies these two transforms for sort
//     keys and display case; we follow it literally. Verified against the real
//     bibtex binary (see tests/unit/tex.typ), which is a closed, finite spec.
//
//   * the PRESENTATION layer — one TeX *tokenizer* feeding mode-aware
//     *evaluators*: `tex-to-content` (raw TeX -> content: accents/special letters
//     -> Unicode, inline math -> real Typst equations, \emph/\textbf/... -> styled
//     content, \url/\href -> links) and `tex-to-string` (raw TeX -> plain string,
//     for sort/cite labels). `tex-to-content` is what the acmart() `tex-render`
//     option overrides; the logic layer is never user-overridable (it would
//     corrupt sorting). Unknown commands raise an error rather than passing
//     through silently — the user is expected to handle them in a `tex-render`
//     callback that falls back to `default-tex-render`.
//
// The 13-entry foreign-character table and the brace/special-character rules
// below are quoted from bibtex.web (`x_purify`, `x_change_case`, and the
// `pre_define(... control_seq_ilk)` block) — not guessed.

// ---- character classes (bibtex lex_class) ---------------------------------
// ASCII letters/digits are alpha/numeric; space & tab are white_space; tilde
// (tie) and hyphen are sep_char; everything else (incl. `$ ^ _ { } \`) is other.
#let _lex(c) = {
  if c == " " or c == "\t" or c == "\n" or c == "\r" { "ws" }
  else if c == "~" or c == "-" { "sep" }
  else if c >= "0" and c <= "9" { "num" }
  else if (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") { "alpha" }
  else { "other" }
}

// ---- the 13 predefined foreign-character control sequences -----------------
// bibtex.web pre_define(... control_seq_ilk): the ONLY control sequences BibTeX
// recognizes as foreign letters. `purify$` maps each to the first alphabetic
// char of its name, plus the second only for \oe \OE \ae \AE \ss (hence \aa->a
// but \ss->ss). Anything else inside a special character is dropped.
#let _foreign-purify = (
  i: "i", j: "j", o: "o", O: "O", l: "l", L: "L",
  oe: "oe", OE: "OE", ae: "ae", AE: "AE", aa: "a", AA: "A", ss: "ss",
)
// change.case$ flips only the recognized foreign LETTER commands in place
// (backslash + name kept): lowering touches the upper ones, uppercasing the
// lower ones; \i \j \ss are never case-flipped.
#let _foreign-lower = (L: "l", O: "o", OE: "oe", AE: "ae", AA: "aa")
#let _foreign-upper = (l: "L", o: "O", oe: "OE", ae: "AE", aa: "AA")

// ---- purify$ ---------------------------------------------------------------
// `@<Purify a special character@>`: inside `{\...}`, emit the table value for a
// recognized control sequence (nothing for an unknown one), then the trailing
// alphanumerics; whitespace inside a special character is dropped (not spaced).
// `cp` is the codepoint array, `p` sits on the opening brace. Returns the
// appended text and the index of the closing brace (caller advances past it).
#let _purify-special(cp, n, p) = {
  let out = ""
  let bl = 1
  p += 1                                   // skip "{"
  while p < n and bl > 0 {
    p += 1                                 // skip "\"
    let y = p
    while p < n and _lex(cp.at(p)) == "alpha" { p += 1 }
    // A control SYMBOL (`\'e`, `\"o`, …) has no alpha name, so the slice is empty
    // and array.join returns none; treat it as the unrecognized cs "" (drop the
    // accent, keep the trailing letter), matching BibTeX purify$.
    let cs = if p > y { cp.slice(y, p).join("") } else { "" }
    if cs in _foreign-purify { out += _foreign-purify.at(cs) }
    while p < n and bl > 0 and cp.at(p) != "\\" {
      let cc = cp.at(p)
      let l = _lex(cc)
      if l == "alpha" or l == "num" { out += cc }
      else if cc == "}" { bl -= 1 } else if cc == "{" { bl += 1 }
      p += 1
    }
  }
  (out, p - 1)                             // decr: leave p on the closing brace
}

// `@<Perform the purification@>`: keep letters/digits; turn each white_space or
// sep_char (`~`,`-`) into a single space; drop everything else (so `$ ^ _` and a
// bare backslash vanish, but a bare `\cmd`'s letters survive as plain text);
// `{` at level 1 followed by `\` enters the special-character branch.
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

// ---- change.case$ ----------------------------------------------------------
#let _conv-str(s, ct) = if ct == "u" { upper(s) } else { lower(s) }

// `@<Convert a special character@>`: keep the braces and backslash; case-flip a
// recognized foreign letter command in place; convert the trailing noncontrol
// sequence with lower/upper. `p` sits on the opening brace; returns the
// converted text and the index of the closing brace.
#let _change-special(cp, n, p, ct) = {
  let out = "{"
  let bl = 1
  p += 1                                   // skip "{"
  while p < n and bl > 0 {
    p += 1                                 // skip "\"
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

// `@<Perform the case conversion@>` + `@<Convert a brace_level = 0 character@>`.
// `ct` is "t" (title: lower all but the first char and the first after ": "),
// "l" (all lower) or "u" (all upper). Only brace-level-0 chars are converted, so
// `{ACM}` is protected; a `{\foreign}` at level 1 is case-flipped in place.
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

// ===========================================================================
// PRESENTATION layer: tokenizer -> mode-aware evaluators.
// ===========================================================================
// BibTeX never decodes to Unicode — TeX does, at typeset time. We replicate
// "what TeX renders": a single mode-independent tokenizer turns raw TeX into a
// token tree, then evaluators interpret it (text -> content, text -> string,
// math -> a Typst-math source string that is `eval`'d). Field values flow
// through the whole pipeline as RAW TeX and only become content here.

#let _unsupported(what) = panic(
  "tex-render: unsupported TeX " + what + ". Supply a `tex-render` callback "
  + "that handles this case and falls back to `default-tex-render` for the rest.")

// ---- tokenizer -------------------------------------------------------------
// Token kinds (a nested tree; groups/math carry sub-token lists):
//   (kind: "text",    value: <run>)         maximal run, excludes \ { } $ ~ ^ _
//   (kind: "cw",      name:  <letters>)      control word \foo (swallows spaces)
//   (kind: "cs",      name:  <one char>)     control symbol \& \" \, ...
//   (kind: "group",   body:  (..tokens))     { ... }
//   (kind: "math",    body:  (..tokens))     $ ... $
//   (kind: "special", char:  "~"|"^"|"_")    catcode-special single chars
// Mode-independent: `^`/`_` are emitted as `special` regardless of mode; the
// evaluators give them meaning (scripts in math, an error bare in text).
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
        while i < n and cp.at(i) == " " { i += 1 }   // control word swallows spaces
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
      i += 1                                  // unmatched close: drop (TeX errors)
    } else {
      run += c
      i += 1
    }
  }
  if run != "" { toks.push((kind: "text", value: run)) }
  (toks, i)
}
#let _lex-tokens(s) = _tokenize(s.codepoints(), 0, none).at(0)

// Grab one TeX argument from the front of a token list: a {group}'s body, or a
// single token — and for a text run, just its FIRST grapheme (TeX's unbraced
// single-token rule), slicing the tail back so the rest stays text. Leading
// spaces are skipped (accents/commands take the next non-space). Returns
// (arg-tokens, remaining-tokens).
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
    // `().join("")` is `none`, not "" — so guard the single-cluster case (an accent
    // grabbing the last char of a run, e.g. a title ending in "Caf\'e").
    let remaining = if cl.len() <= 1 { r.slice(1) }
      else { ((kind: "text", value: cl.slice(1).join("")),) + r.slice(1) }
    return (((kind: "text", value: cl.first()),), remaining)
  }
  ((h,), r.slice(1))
}

// ---- command tables --------------------------------------------------------
// Combining diacritics (NFC composes downstream; the text gate NFKC-folds).
#let _accent-cs = (                        // control symbols: \"o \'e \^o ...
  "\"": "\u{0308}", "'": "\u{0301}", "`": "\u{0300}", "^": "\u{0302}",
  "~": "\u{0303}", "=": "\u{0304}", ".": "\u{0307}",
)
#let _accent-cw = (                        // control words: \H{o} \v s ...
  H: "\u{030B}", v: "\u{030C}", u: "\u{0306}", r: "\u{030A}",
  k: "\u{0328}", c: "\u{0327}", b: "\u{0331}", d: "\u{0323}",
)
#let _special-letters = (
  ss: "ß", SS: "ẞ", ae: "æ", AE: "Æ", oe: "œ", OE: "Œ", aa: "å", AA: "Å",
  o: "ø", O: "Ø", l: "ł", L: "Ł", i: "ı", j: "ȷ",
)
#let tex-logo = box(height: 1em)[T#h(-0.1667em)E#h(-0.125em)X]
#let latex-logo = box(height: 1em)[L#h(-0.36em)#text(size: 0.82em)[A]#h(-0.15em)T#h(-0.1667em)E#h(-0.125em)X]
#let bibtex-logo = box(height: 1em)[BibT#h(-0.1667em)E#h(-0.125em)X]
#let latexe-logo = box(height: 1em)[L#h(-0.36em)#text(size: 0.82em)[A]#h(-0.15em)T#h(-0.1667em)E#h(-0.125em)X2e]

#let _logos = (LaTeX: "LATEX", TeX: "TEX", BibTeX: "BibTEX", LaTeXe: "LATEX2e")
#let _logo-content = (LaTeX: latex-logo, TeX: tex-logo, BibTeX: bibtex-logo, LaTeXe: latexe-logo)
// Argument-taking inline formatting: \textit{x}, \emph{x}, \textbf{x}, \textsc{x}.
// LaTeX \emph toggles emphasis, but \textit/\textsl force an italic/slanted shape.
#let _emph-cw = ("emph",)
#let _italic-cw = ("textit", "textsl")
#let _strong-cw = ("textbf",)
#let _sc-cw = ("textsc",)
#let _id-cw = ("textrm", "textsf", "textnormal", "textup", "textmd", "mbox", "text")
// Declaration *switches* (NO argument): they restyle the REST of the enclosing
// group — `{\it a b}` italicizes "a b", not just the next char. Name -> styler tag
// (em/bf/sc/tt, or id = a font *reset*, which we approximate as identity).
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

// TeX *input* ligatures (NOT font ligatures, which Typst applies itself; these
// are markup-level in Typst and so are NOT applied to interpolated strings).
#let _render-run(s) = {
  s = s.replace("---", "\u{2014}").replace("--", "\u{2013}")
  s = s.replace("``", "\u{201C}").replace("''", "\u{201D}")
  s = s.replace("`", "\u{2018}").replace("'", "\u{2019}")
  s
}

// In math, each letter is its OWN italic identifier and a digit-run is a number.
// Typst reads consecutive letters as one (usually undefined) identifier and ERRORS
// (`$ab$` -> "unknown variable: ab"; `$x2$` likewise), so a raw run must be split:
// insert a space between adjacent alphanumerics unless both are digits (keeping a
// multi-digit number intact). Non-alphanumerics (operators, parens) pass through.
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

// ---- math: tokens -> Typst-math source string ------------------------------
// Symbols map to Typst math identifiers; one-/two-arg functions to Typst math
// functions; LaTeX `^{..}`/`_{..}` grouping becomes Typst `^(..)`/`_(..)`.
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
  infty: "infinity", partial: "diff", nabla: "nabla", forall: "forall", exists: "exists",
  neg: "not", "in": "in", notin: "in.not", ni: "in.rev", subset: "subset",
  subseteq: "subset.eq", supset: "supset", supseteq: "supset.eq", emptyset: "emptyset",
  varnothing: "nothing", perp: "perp", parallel: "parallel", angle: "angle", ell: "ell",
  hbar: "planck.reduce", aleph: "aleph", prime: "prime", dag: "dagger", ddag: "dagger.double",
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
// Math spacing control symbols: a literal " " is IGNORED by Typst math, so each
// maps to a real spacing keyword. \, = thin, \: \> = medium, \; = thick,
// \(space) = normal, \! = negative thin (LaTeX's are 3/4/5/-3 of 18mu = 1/6 em).
#let _math-cs-space = (
  ",": "thin", ":": "med", ">": "med", ";": "thick", " ": "space",
  "!": "#h(-(1em)/6)",
)

// Apply a formatting tag to already-evaluated inner content `x` (content mode
// only — in string/math modes formatting is dropped and `x` passes through).
#let _apply(tag, x, cont) = {
  if not cont { x }
  else if tag == "em" { emph(x) }
  else if tag == "it" { text(style: "italic", x) }
  else if tag == "bf" { strong(x) }
  else if tag == "sc" { smallcaps(x) }
  else if tag == "ul" { underline(x) }
  else { x }
}

// ---- the evaluator: tokens -> content / string / math-source ---------------
// ONE recursive function over three modes, so every call is self-referential
// (Typst has no late binding between separate module-level `#let`s, which rules
// out mutual recursion). `mode`:
//   "content" -> content (the default tex-render: styled, real equations, links)
//   "string"  -> plain string (sort/cite labels: formatting dropped)
//   "math"    -> a Typst-math SOURCE string (later eval'd inside $...$)
// The LINEAR walk over the token list is a LOOP (reassigning `rest`), so its depth
// is O(1) in field length — Typst's call-depth limit is ~72, and a field can have
// dozens of tokens. Only the STRUCTURAL descent (group/arg/math bodies, via the
// recursive `_eval` calls below) recurses, and that is bounded by brace/math
// nesting depth (a handful), not token count.
#let _eval(toks, mode) = {
  let cont = mode == "content"
  let math = mode == "math"
  let out = if cont { [] } else { "" }
  let rest = toks
  while rest.len() > 0 {
    let t = rest.first()
    let tail = rest.slice(1)
    let next = tail                    // commands that take arguments override this
    let piece = if cont { [] } else { "" }

    if t.kind == "text" {
      piece = if math { _math-run(t.value) + " " } else { _render-run(t.value) }
    } else if t.kind == "group" {
      let g = _eval(t.body, mode)
      // A `{group}` is invisible grouping (NOT parentheses); in math we just inline
      // the body. (A following ^/_ then attaches to the body's last atom, not the
      // whole group — an accepted approximation; explicit scripts use `^{..}`.)
      piece = if math { g + " " } else { g }
    } else if t.kind == "math" {
      if cont { piece = eval(_eval(t.body, "math"), mode: "math") }
      else if math { piece = _eval(t.body, "math") }
      else { _unsupported("inline math in a name/label field") }
    } else if t.kind == "special" {
      if math {
        // `~` in math is a (non-breaking) interword space; a literal " " is ignored.
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
          // \text{..} -> a quoted Typst string literal; escape \ and " so the
          // generated math source can't be broken by the field's own characters.
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
      else if nm in _accent-cw { let (a, r) = _grab(tail); piece = _eval(a, "string") + _accent-cw.at(nm); next = r }
      else if nm in _id-cw { let (a, r) = _grab(tail); piece = _eval(a, mode); next = r }
      else if nm in _switch-cw {                  // declaration switch: restyle REST of group
        let tag = _switch-cw.at(nm); next = ()
        if tag == "tt" { let s = _eval(tail, "string"); piece = if cont { raw(s) } else { s } }
        else { piece = _apply(tag, _eval(tail, mode), cont) }
      }
      else if nm in _emph-cw { let (a, r) = _grab(tail); piece = _apply("em", _eval(a, mode), cont); next = r }
      else if nm in _italic-cw { let (a, r) = _grab(tail); piece = _apply("it", _eval(a, mode), cont); next = r }
      else if nm in _strong-cw { let (a, r) = _grab(tail); piece = _apply("bf", _eval(a, mode), cont); next = r }
      else if nm in _sc-cw { let (a, r) = _grab(tail); piece = _apply("sc", _eval(a, mode), cont); next = r }
      else if nm == "underline" { let (a, r) = _grab(tail); piece = _apply("ul", _eval(a, mode), cont); next = r }
      else if nm == "textsuperscript" { let (a, r) = _grab(tail); let x = _eval(a, mode); piece = if cont { super(x) } else { x }; next = r }
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
      } else if nm in _accent-cs { let (a, r) = _grab(tail); piece = _eval(a, "string") + _accent-cs.at(nm); next = r }
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

// ---- public entry points ---------------------------------------------------
#let tex-to-content(s) = if type(s) != str { s } else { _eval(_lex-tokens(s), "content") }
#let tex-to-string(s) = if type(s) != str { s } else { _eval(_lex-tokens(s), "string") }
