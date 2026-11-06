/// Utilities.

/// Make "x::y::z"-like namespace strings.
///
/// - n (arguments): Names in `str`.
/// -> str
#let ns(..n) = n.pos().join("::")

/// Force anything to an array.
///
/// - a (any): Variable to convert to array.
/// -> array
#let to-arr(a) = if type(a) == array { a } else { (a,) }

/// Choose the first item that should not be discarded.
///
/// - args (arguments): Items to choose from.
/// - discard (any): Criterion to discard an item.
/// - default (any): The fallback value.
/// - ts (function): A transformation to the selected item, excluding the default.
/// -> any
#let firstof(..args, discard: none, default: none, ts: a => a) = {
  for arg in args.pos() {
    if type(discard) == function {
      if discard(arg) { return ts(arg) }
    } else {
      if arg != discard {
        return ts(arg)
      }
    }
  }
  return default
}

/// Choose the first item that is not `auto`.
///
/// - args (arguments): Items to choose from.
/// - default (any): The fallback value.
/// - ts (function): A transformation to the selected item, excluding the default.
/// -> any
#let firstconcrete = firstof.with(discard: auto)

/// Compose a series of functions with a body.
///
/// - body (any): The body to execute things on.
/// - funcs (arguments): The functions to be composed, left-to-right.
/// -> any
#let compose(body, ..funcs) = (body, ..funcs.pos()).reduce((it, func) => if type(func) == function {
  func(it)
} else {
  it
})

/// Convert `data` to a dictionary, panic on fail.
///
/// - data (dictionary, module, function, arguments, none): The data to convert to dictionary.
/// -> dictionary
#let to-dict(data) = {
  if data == none {
    return (:)
  }

  let t = type(data)
  if t == dictionary {
    return data
  }
  if t == module {
    return dictionary(data)
  }
  if t == array {
    return data.to-dict()
  }
  if t == arguments {
    return data.named()
  }
  if t == function {
    return to-dict(t())
  }
  panic("Cannot convert a " + str(t) + " to a dictionary!")
}

/// Merge dictionaries, left-to-right.
/// On merge, values of existing keys are replaced, and values of new keys are added.
/// Values of type `dictionary` are not merged, instead their own pairs are merged.
///
/// - dicts (arguments): The `dictionary`s to be merged.
/// -> dictionary
#let merge-dicts(..dicts) = (
  dicts
    .pos()
    .reduce((orig, cand) => cand
      .keys()
      .fold(
        orig,
        (acc, k) => if k in orig.keys() and type(orig.at(k)) == dictionary and type(cand.at(k)) == dictionary {
          acc + ((k): merge-dicts(orig.at(k), cand.at(k)))
        } else {
          acc + ((k): cand.at(k))
        },
      ))
)

/// Load data from a list of files, then merge data into a dictionary.
/// The filenames minus extension will be the top-level keys.
///
/// - dir (path): A directory.
/// - files (arguments): A list of filenames under `dir` to load.
/// -> dictionary
#let load-dir(
  dir,
  ..files,
) = {
  files
    .pos()
    .map(file => {
      let ts = file.split(".")
      let name = ts.at(-2)
      let fmt = ts.last()
      // @typstyle off
      let func = (if fmt == "toml" { toml }
        else if fmt == "typ" { f => { import f: export; export } }
        else if fmt in ("yml", "yaml") { yaml }
        else if fmt == "csv" { csv }
        else if fmt == "json" { json }
        else if fmt == "cbor" { cbor }
        else if fmt == "xml" { xml }
        else { panic("Unsupported file format: " + fmt) })
      (name, func(dir + "/" + file))
    })
    .to-dict()
}

/// Spread a line horizontally.
///
/// - width (length, fraction, relative): Width of the spread.
/// - body (content): Content to be spread.
/// -> content
#let spreadl(
  width,
  body,
) = context {
  box(width: calc.max(width.to-absolute(), measure(body).width), {
    body
    linebreak(justify: true)
  })
}

/// Spread string horizontally.
///
/// - width (length, fraction, relative): Width of the spread.
/// - str (str): String to be spread.
/// - dir (direction): Direction of the spread, must be horizontal.
/// -> content
#let spreads(
  width,
  str,
  dir: ltr,
) = box(width: width, stack(
  dir: dir,
  ..str.clusters().intersperse(1fr),
))


/// Spread an array of content-compatibles.
///
/// - length (length, fraction, relative): Length of the spread.
/// - dir (direction): Direction of the spread.
/// - arr (array): Content-compatibles to be spread.
/// -> content
#let spreada(
  length,
  dir,
  arr,
) = box(
  ..(
    if dir in (ltr, rtl) {
      (width: length)
    } else {
      (height: length)
    }
  ),
  stack(
    dir: dir,
    ..arr.intersperse(1fr),
  ),
)

#let ord-en(n) = {
  if n in range(11, 14) { return "th" }

  let last-digit = calc.rem(n, 10)
  if last-digit == 1 { return "st" }
  if last-digit == 2 { return "nd" }
  if last-digit == 3 { return "rd" }
  return "th"
}

#let args-lang(
  lang,
  region,
) = {
  arguments(
    lang: lang,
    region: firstconcrete(
      region,
      default: {
        if lang == "zh" { "cn" } else { "us" }
      },
    ),
  )
}

#let take-lang(
  dict,
  lang,
) = {
  dict
    .pairs()
    .map(
      ((k, v)) => {
        if type(v) == dictionary {
          (k, v.at(lang, default: none))
        }
      },
    )
    .filter(i => i != none)
    .to-dict()
}

#let infer-display-title(
  title,
  display-title,
  bachelor: false,
) = {
  let ts(l, t) = if bachelor {
    (l, t)
  } else if l == "en" {
    (l, upper(t))
  } else {
    (l, t)
  }

  title
    .pairs()
    .map(((l, t)) => {
      if l in display-title {
        if display-title.at(l) == auto {
          return ts(l, t)
        }
        return (l, display-title.at(l))
      }
      return ts(l, t)
    })
    .to-dict()
}

#let pkg = toml("../typst.toml")

#let pkg-name = pkg.package.name

#let trans-default = load-dir("./trans", "zh.typ", "en.typ")

#let config = state(ns(pkg-name, "config"), (:))

#let doc-state = state(ns(pkg-name, "state"), none)

#let doc-class = state(ns(pkg-name, "class"), none)

#let numbering-with-chapter(
  ..ns,
  loc: auto,
  numbering: none,
  chapter-numbering: none,
) = {
  let loc = firstconcrete(loc, here())
  let numf = if numbering == none {
    (..sink) => none
  } else if type(numbering) == str {
    std.numbering.with(numbering)
  } else {
    numbering.with(loc: loc)
  }
  let chnumf = if chapter-numbering == none {
    (..sink) => none
  } else if type(chapter-numbering) == str {
    std.numbering.with(chapter-numbering)
  } else {
    chapter-numbering.with(loc: loc)
  }

  let i = if doc-state.at(loc) == "appendix" and doc-class.at(loc) == "bachelor" { 1 } else { 0 }

  chnumf(
    counter(heading).at(loc).at(i, default: 9),
  )
  numf(
    ..ns,
  )
}

#let figure-numbering-with-chapter = numbering-with-chapter.with(
  chapter-numbering: (
    ..ns,
    loc: auto,
  ) => context {
    let pattern = if doc-state.at(loc) == "appendix" {
      "A-"
    } else {
      "1-"
    }
    numbering(pattern, ..ns)
  },
)

#let equation-numbering-with-chapter = numbering-with-chapter.with(
  numbering: "1)",
  chapter-numbering: (
    ..ns,
    loc: auto,
  ) => context {
    let pattern = if doc-state.at(loc) == "appendix" {
      "(A-"
    } else {
      "(1-"
    }
    numbering(pattern, ..ns)
  },
)

