// Configuration via sys.inputs or `--input` on the command line.
// Yeah, this doesn't exactly follow the "parse, don't validate" model,
// but given Typst's lack of typing for the moment I wasn't exactly feeling like
// forcing that paradigm on it.
#let _define(name) = {
  let source = sys.inputs.at(name, default: none)

  let check(name, actual, matches, expected) = {
    if matches {
      return
    }

    panic(
      "input `"
        + name
        + "` received invalid value; "
        + "expected: "
        + expected
        + "; "
        + "actual: `"
        + actual
        + "`",
    )
  }

  (
    bool: () => {
      if source == none { return none }
      let value = source == "true"
      check(
        name,
        source,
        source in ("true", "false", none),
        "either `true`, `false` or left unspecified",
      )
      value
    },
    enum: (..variants) => {
      let variants = variants.pos()
      check(
        name,
        source,
        source in variants,
        "one of `"
          + variants.filter(var => var != none).intersperse("`, `").join()
          + "`"
          + if none in variants {
            " or left unspecified"
          },
      )

      source
    },
    string: () => source,
  )
}

#let _default(actual, default) = {
  if actual != none {
    actual
  } else {
    default
  }
}

#let _alias(actual, lookup) = {
  lookup.at(actual, default: actual)
}

/// If true, assume the final document won't be printed
/// and some sacrifices for display on a screen can be made.
/// If false, assume the final document will be printed
/// and try to be as useful as possible on real paper.
#let dev = (_define("dev").bool)()
#let dev = _default(dev, "x-preview" in sys.inputs)

/// What colors to display the document in.
/// - bow: Black on white
///   - Default if `dev` is false
///   - Typical sciency-looking papers
///   - Very well printable
/// - wob: White on black
///   - Same as bow, just with foreground and background swapped
///   - Essentially the "night mode" option in most PDF viewers
///     - But without inverting other colors
/// - duality: Spacy theme that has never been published in full
///   that I use a lot, personally.
///   - Default if `dev` is true
///   - **Not quite colorblind-safe**
#let theme = (_define("theme").enum)("bow", "wob", "duality", none)
#let theme = _default(
  theme,
  if dev {
    "duality"
  } else {
    "bow"
  },
)

/// The name of the file the note is stored in.
/// It is trimmed and used as default for the document title
/// iff you didn't specify anything else in the template.
#let filename = (_define("filename").string)()

/// How much to render:
///
/// - all
///   - Render the document normally with everything
///   - Default
/// - text
///   - Skip rendering more costly stuff
///     like the outline and cetz canvases
///   - Greatly impacts the visual result
///     while leaving most of the machine content same
/// - info
///   - Only offer metadata via the `<info>` label
///   - The output is very likely just a blank PDF
///   - Best used in combination with `typst query`
///     - `flow-query` specifies this automatically
///
/// Note on deprecated aliases (... is converted to ...):
///
/// - true → all
/// - false → text
///
/// When looking programmatically through documents,
/// chances are you don't need "all" and
/// could have a lot of performance boost
/// by using "text" instead.
#let render = (_define("render").enum)(
  "all",
  "text",
  "info",
  "false",
  "true",
  none,
)
#let render = _default(render, "all")
#let render = _alias(render, ("true": "all", "false": "info"))

/// What the target format is.
/// One of "paged" (the default) or "html".
/// Effectively a simulation of the built-in function `target`
/// but not since it's gated behind the `html` feature.
#let target = (_define("target").enum)("paged", "html", none)
#let target = _default(target, "paged")

