// ============================================================================
//  intl-math — math operators that print in the language of the document.
//
//  The problem: mathematical abbreviations are NOT universal. In Spanish, sine
//  is "sen", limit is "lím" and the greatest common divisor is "mcd"; in English
//  they are "sin", "lim" and "gcd". Typst ships only the English ones, so a
//  Spanish document comes out in English notation — unless the operators get
//  redefined by hand in every project.
//
//  The idea: the IDENTIFIER does not change (you keep writing `sin(x)`, the name
//  you already use and the one Typst documents); what changes is the PRINTED
//  word, decided by `text.lang`. Adopting the package does not force anyone to
//  rewrite content.
//
//      #import "@preview/intl-math:0.1.0": intl
//      #let m = intl()
//      #set text(lang: "es")
//      $#m.sin (x)$    →  sen(x)
//      $#(m.lim)_(x->0)$ →  lím
//
//  With the language set to "en", the same identifiers print sin and lim.
// ============================================================================

#import "lang/en.typ" as en-lang
#import "lang/es.typ" as es-lang

// The languages that ship with the package. Adding one means adding its file
// and one line HERE — nowhere else: the symbols build themselves out of the
// English keys (see `intl` below).
#let BUILTIN = (
  en: en-lang.words,
  es: es-lang.words,
)

// What SHAPE each symbol has. It does not depend on the language, so it lives
// apart from the tables: whoever adds a language needs to know nothing about it.
//   "op"     → math operator (math.op: set upright, with the spacing an operator
//              is entitled to).
//   "spaced" → a plain word inside a formula, with a space on each side (the
//              "if" of piecewise functions).
#let _shape = (
  pw-if: "spaced",
)

// Operators whose condition goes UNDERNEATH rather than beside: `lim_(x->0)`
// puts the condition below the word, while `log_a` keeps it as a subscript.
// This is the same list Typst uses for its native operators, verified by
// compiling them: the rest (log, sin, arg, dim…) does NOT take limits.
#let _limits = ("lim", "liminf", "limsup", "max", "min", "sup", "inf", "det", "gcd", "Pr")

// The `context` goes INSIDE the `math.op`, and this is NOT a matter of style.
//
// The other way round — `context { math.op(word) }` — the result stops being an
// operator as far as Typst is concerned: it is opaque content. And then the
// operator spacing is lost as soon as there is a subscript, which is exactly
// when it is needed most: `log_a m` came out as "log_a​m", glued, and so did
// `lim_(x->0) f(x)`. It compiles without a complaint and only shows up by
// comparison. It surfaced while migrating a Year 10 course, where a logarithm
// formula fitted on one line with the new engine and took two with the old one.
//
// With the `context` inside, the outer node IS a `math.op` and keeps its class;
// the only thing resolved late is the word itself.
#let _symbol(key, tables) = {
  // The fallback is a cascade: document language → English → the key itself.
  // So an incomplete table does NOT break the document (the English word comes
  // out), and neither does an unknown language (everything comes out English).
  let word = context {
    let table = tables.at(text.lang, default: tables.en)
    table.at(key, default: tables.en.at(key, default: key))
  }
  if _shape.at(key, default: "op") == "op" {
    math.op(word, limits: _limits.contains(key))
  } else {
    // The spaces go OUTSIDE the `context`: inside it, `word` is already content
    // and cannot be concatenated with strings.
    math.text(" ") + word + math.text(" ")
  }
}

/// The symbols, resolved according to the language of the document.
///
/// - extra (dictionary): ADDITIONAL languages, `(code: (key: "word"))`. Lets you
///   use a language the package does not ship yet **without forking it**; if you
///   also want to contribute it, it is one file in `lang/`.
///
/// Returns a dictionary with one symbol per key (see `lang/en.typ` for the full
/// list). Use it with `#`, because in math mode a bare identifier would be read
/// as a product of variables: `$#m.sin (x)$`.
#let intl(extra: (:)) = {
  let tables = BUILTIN + extra
  let out = (:)
  // The keys come from the English table, which is the reference one: adding a
  // new symbol means adding it there (and to `_shape` if it is not an operator).
  for key in en-lang.words.keys() {
    out.insert(key, _symbol(key, tables))
  }
  out
}

/// The language codes that ship with the package, to check whether yours is in.
#let languages() = BUILTIN.keys()
