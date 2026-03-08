#import "cfg.typ": render
#import "hacks.typ"
#import "util/mod.typ": swap-kv, cartesian-product

/// Regex alternates.
#let any(..vars) = {
  "("
  vars.pos().join("|")
  ")"
}

// these below need to be kept in sync
// they are forward/backward for looking up in text vs. looking up their effect

/// Maps from canonical suffix to other possible suffices.
/// Must be ordered from most specific to least specific
/// since the first match is always taken.
#let suffices = (
  // dependency → dependent
  // frequency → frequencies
  "ncy": "(nt|ncies)",
  // dependence → dependent
  "nce": "nt",
  // consent → consensually
  // consent → consenting
  // coefficient → coefficients
  "nt": "(nsually|nting|nts)",
  // orthogonal → orthogonality
  "al": "ality",
  // responsible → responsibility
  "le": "ility",
  // criterion → criteria
  "ion": "ia",
  // suffix → suffices
  "ix": "ices",
  // vertex → vertices
  // latex → latexes
  "ex": "(ices|exes)",
  // accuracy → accurate
  "cy": "te",
  // elision -> elide
  "sion": "de",
  // basis → bases
  // basis → based
  "is": "e(s|d)",
  // define → defining
  // architecture → architectures
  // revoke → revokable
  // revoke → revokal
  // transpose → transposition
  "e": "(es|ing|able|al|ition)",
  // party → parties
  // voluntary → voluntariness
  "y": "(ies|iness)",
  // build → building
  // concept → conceptize
  // table → tables
  // guilt → guilty
  // dimension → dimensional
  "": any("ing", "ize", "s", "y", "al"),
)
// FIXME: can't handle same alternates for different canonical suffices
// would actually need to be a... multimap?
#let suffices-rev = swap-kv(suffices)

/// Returns an array of possible normalized forms of `it`.
#let normalize(it) = {
  let it = lower(it)

  // do we need to canonicalize the suffix?
  let choices = suffices-rev
    .keys()
    .filter(alternates => it.ends-with(regex(alternates)))
    .map(alternates => {
      let canonical = suffices-rev.at(alternates)
      it.trim(regex(alternates), at: end, repeat: false)
      canonical
    })

  (it,) + choices
}

#let expand(it) = {
  let it = lower(it)
  // make it irrelevant if the first character is uppercase or lowercase
  // but only if the first character is obvious
  let prefix = if it.at(0) == "(" {
    it.at(0)
  } else {
    any(it.at(0), upper(it.at(0)))
  }
  let rest = it.slice(1)

  // are there other possible suffices we need to account for?
  let suffix = suffices.keys().find(canonical => it.ends-with(canonical))
  let rest = if suffix == none {
    rest
  } else {
    let alternates = suffices.at(suffix)

    rest.trim(suffix, at: end, repeat: false)
    any(suffix, alternates)
  }

  prefix + rest
}

// Constructs a regex that matches any entry in the `keywords` array,
// even if they are e.g. pluralized or conjugated.
#let construct-picker(keywords) = regex({
  "\b"
  any(..keywords.map(expand))
  "\b"
})

// Finds the appropriate operation for the given keyword and applies it.
#let apply-one(selected, registered) = {
  // need to find the first normalization possibility
  // that matches one of the registered keywords (might be regexes)
  // yeah that's O(n m). could be made to O(n log(m)) with a prefix tree?

  let lookup = cartesian-product(
    normalize(selected.text),
    registered.pairs(),
  ).find(((possibility, (kw, _op))) => regex(kw) in possibility)

  if lookup == none {
    panic({
      "could not match keyword in text to original: "
      "matched: `" + selected.text + "`, "
      "registered: [" + registered.keys().join(", ") + "], "
      "normalized: [" + normalize(selected.text).join(", ") + "]"
    })
  }
  let (_matched, (name, effect)) = lookup

  // find a function to throw on the name
  let op = if type(effect) == function {
    effect
  } else if type(effect) == color {
    text.with(fill: effect)
  } else if type(effect) == label {
    link.with(effect)
  }

  op(selected)
}

#let process(body, cfg: none) = {
  if cfg == none {
    // no words to highlight → nothing to do!
    return body
  }

  // see the schema in src/info.typ for possible types cfg can have
  if type(cfg) == array {
    let converted = (:)
    for word in cfg {
      converted.insert(word, strong)
    }
    cfg = converted
  }

  // normalize all keys so the lookup normalization can find something
  for (word, op) in cfg {
    let _ = cfg.remove(word)
    cfg.insert(normalize(word).first(), op)
  }

  // then actually run through
  let picker = construct-picker(cfg.keys())

  // skip codeblocks
  show: hacks.only-main(
    picker,
    it => apply-one(it, cfg),
  )

  body
}

