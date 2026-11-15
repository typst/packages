#import "@preview/elembic:1.1.1" as e
#import "src/declarations.typ": __codly-prefix, __declaration

/// A language definition, see the `languages` field.
///
/// Additional, unknown fields are preserved and override the corresponding
/// `codly.lang` arguments for that language, e.g. `(py: (radius: 5pt))`
/// overrides `radius` for the Python language badge.
#let language = {
  e.types.declare(
    "language",
    prefix: __codly-prefix,
    ..__declaration("types", "language"),
    casts: (
      (from: dictionary),
      (from: str, with: constructor => value => constructor(name: value)),
    ),
  )
}

/// Automatic two-view syntax highlighting for `diff-<language>` or `diff,<language>` raw blocks.
/// The diff prefix is removed from code and shown in a separate gutter.
#let diff = {
  e.types.declare(
    "diff",
    prefix: __codly-prefix,
    ..__declaration("types", "diff"),
    casts: (
      (from: dictionary),
      (from: bool, with: constructor => value => constructor(enabled: value)),
    ),
  )
}

/// An independently styled gutter column. Arrays are indexed by source line;
/// callbacks receive `index`, `kind`, `source-line`, `number`, and `text`.
/// Only code and skip rows have gutter cells. `index` counts all displayed
/// rows, including headers and callouts, matching body-fill palette indexing.
/// Source lines are one-indexed; skipped/generated rows have no source or text.
/// Short arrays and `none` entries leave cells empty. `auto` styling inherits
/// the grid's number alignment/insets; `fill: auto` follows the body row.
#let gutter-column = {
  e.types.declare(
    "gutter-column",
    prefix: __codly-prefix,
    parse-args: (default-parser, ..options) => {
      (args, include-required: true) => {
        let result = default-parser(args, include-required: include-required)
        if result.first() {
          let width = result.last().at("width", default: auto)
          assert(
            width == auto
              or if type(width) == length {
                width.abs >= 0pt and width.em >= 0
              } else { width >= if type(width) == ratio { 0% } else { 0fr } },
            message: "codly: gutter width must be non-negative",
          )
        }
        result
      }
    },
    ..__declaration("types", "gutter-column"),
    casts: (
      (from: dictionary),
      (from: array, with: constructor => values => constructor(values: values)),
      (from: function, with: constructor => values => constructor(values: values)),
    ),
  )
}

/// A range of lines that should use a different syntax-highlighting language.
#let __sublang-normalize(value) = {
  let start = value.at("start")
  assert(start > 0, message: "codly: sublang `start` must be greater than 0")

  let end = value.at("end")
  assert(end >= start, message: "codly: sublang `end` must be at least `start`")

  value
}

#let __sublang-parser = {
  (default-parser, fields: (:), typecheck: true) => {
    (args, include-required: true) => {
      let result = default-parser(args, include-required: include-required)
      if result.at(0) {
        result.at(1) = __sublang-normalize(result.at(1))
      }
      result
    }
  }
}

/// A syntax-highlighting language applied to an inclusive range of lines.
#let sublang = {
  e.types.declare(
    "sublang",
    prefix: __codly-prefix,
    ..__declaration("types", "sublang"),
    parse-args: __sublang-parser,
    casts: (
      (from: dictionary),
    ),
  )
}

/// Optional grammar-aware delimiter coloring.
#let rainbow = {
  import "src/rainbow.typ" as r

  let parser(default-parser, fields: (:), typecheck: true) = {
    (args, include-required: true) => {
      let result = default-parser(args, include-required: include-required)
      if result.at(0) {
        let value = result.at(1)
        assert(
          value.at("palette", default: (black,)).len() > 0,
          message: "codly: rainbow palette must not be empty",
        )
        assert(
          value.at("depth-offset", default: 0) >= 0,
          message: "codly: rainbow depth-offset must be nonnegative",
        )
      }
      result
    }
  }

  e.types.declare(
    "rainbow",
    prefix: __codly-prefix,
    parse-args: parser,
    ..__declaration("types", "rainbow", scope: (r: r)),
    casts: (
      (from: dictionary),
      (from: bool, with: constructor => value => constructor(enabled: value)),
    ),
  )
}

/// Optional indentation guides, independent of syntax delimiter nesting.
#let indent-guides = {
  let parser(default-parser, fields: (:), typecheck: true) = {
    (args, include-required: true) => {
      let result = default-parser(args, include-required: include-required)
      if result.at(0) {
        let value = result.at(1)
        let width = value.at("width", default: auto)
        let palette = value.at("palette", default: auto)
        let offset = value.at("depth-offset", default: auto)
        assert(width == auto or width > 0, message: "codly: indent-guides width must be positive")
        assert(
          palette == auto or palette.len() > 0,
          message: "codly: indent-guides palette must not be empty",
        )
        assert(
          offset == auto or offset >= 0,
          message: "codly: indent-guides depth-offset must be nonnegative",
        )
        let thickness = value.at("thickness", default: 0.5pt)
        assert(
          thickness.abs >= 0pt and thickness.em >= 0 and thickness != 0pt,
          message: "codly: indent-guides thickness must be positive",
        )
      }
      result
    }
  }

  e.types.declare(
    "indent-guides",
    prefix: __codly-prefix,
    parse-args: parser,
    ..__declaration("types", "indent-guides"),
    casts: (
      (from: dictionary),
      (from: bool, with: constructor => value => constructor(enabled: value)),
    ),
  )
}

/// Configuration for smart skips, see the `smart-skip` field.
#let smart-skip = {
  e.types.declare(
    "smart-skip",
    prefix: __codly-prefix,
    ..__declaration("types", "smart-skip"),
    casts: (
      (
        from: dictionary,
        with: constructor => value => {
          let rest = value.at("rest", default: false)
          let first = value.at("first", default: rest)
          let last = value.at("last", default: rest)
          constructor(first: first, last: last, rest: rest)
        },
      ),
      (
        from: bool,
        with: constructor => value => constructor(first: value, last: value, rest: value),
      ),
    ),
  )
}

/// A single highlight, see the `highlights` field.
#let __highlight-normalize(value) = {
  let line = value.at("line")
  assert(line > 0, message: "codly: highlight `line` must be greater than 0")

  let start = value.at("start", default: none)
  if start == none {
    value.insert("start", 0)
  } else {
    assert(start >= 0, message: "codly: highlight `start` must be at least 0")
  }

  let end = value.at("end", default: none)
  if end == none {
    value.insert("end", 999999999)
  } else {
    assert(end >= 0, message: "codly: highlight `end` must be at least 0")
  }

  value
}

#let __highlight-parser = {
  (default-parser, fields: (:), typecheck: true) => {
    (args, include-required: true) => {
      let result = default-parser(args, include-required: include-required)
      if result.at(0) {
        result.at(1) = __highlight-normalize(result.at(1))
      }
      result
    }
  }
}

#let highlight-config = {
  e.types.declare(
    "highlight",
    prefix: __codly-prefix,
    ..__declaration("types", "highlight-config"),
    parse-args: __highlight-parser,
    casts: (
      (
        from: dictionary,
        with: constructor => value => {
          let line = value.remove("line")
          constructor(line, ..value)
        },
      ),
    ),
  )
}

/// A single annotation, see the `annotations` field.
#let __annotation-normalize(value) = {
  let start = value.at("start")
  assert(start > 0, message: "codly: annotation `start` must be greater than 0")

  let end = value.at("end", default: none)
  if end == none {
    end = start
    value.insert("end", end)
  } else {
    assert(end > 0, message: "codly: annotation `end` must be greater than 0")
  }

  assert(end >= start, message: "codly: annotation `end` must be at least `start`")

  if "content" not in value {
    value.insert("content", none)
  }

  value
}

#let __annotation-parser = {
  (default-parser, fields: (:), typecheck: true) => {
    (args, include-required: true) => {
      let result = default-parser(args, include-required: include-required)
      if result.at(0) {
        result.at(1) = __annotation-normalize(result.at(1))
      }
      result
    }
  }
}

#let annotation-config = {
  e.types.declare(
    "annotation",
    prefix: __codly-prefix,
    ..__declaration("types", "annotation-config"),
    parse-args: __annotation-parser,
    casts: (
      (
        from: dictionary,
        with: constructor => value => {
          let start = value.remove("start")
          constructor(start, ..value)
        },
      ),
    ),
  )
}

/// A callout attached to a source line, see the `callouts` field.
#let __callout-normalize(value) = {
  let line = value.at("line")
  assert(line > 0, message: "codly: callout `line` must be greater than 0")
  value
}

#let __callout-parser = {
  (default-parser, fields: (:), typecheck: true) => {
    (args, include-required: true) => {
      let result = default-parser(args, include-required: include-required)
      if result.at(0) {
        result.at(1) = __callout-normalize(result.at(1))
      }
      result
    }
  }
}

#let callout-config = {
  import "src/callout.typ" as callout-impl

  e.types.declare(
    "callout",
    prefix: __codly-prefix,
    ..__declaration("types", "callout-config"),
    parse-args: __callout-parser,
    casts: (
      (from: dictionary, with: constructor => value => constructor(..value)),
    ),
  )
}

/// A custom argument parser for the pair-like types below (range, skip,
/// highlighted-line). It allows specifying the pair's fields either
/// positionally, e.g. `range(2, 4)`, or by name, e.g. `range(start: 2, end: 4)`,
/// unlike the default parser which only accepts positional arguments for
/// required fields.
#let __pair-parser(first-field) = {
  (default-parser, fields: (:), typecheck: true) => {
    let names = fields.user-fields.keys()
    (args, include-required: true) => {
      let positional = args.pos()
      let named = args.named()
      if include-required and positional.len() == 0 and first-field in named {
        // All fields given by name: convert to positional order based on field
        // declaration order.
        let ordered = ()
        for name in names {
          if name in named {
            ordered.push(named.remove(name))
          }
        }
        // Any remaining named fields are unknown and will error in the default parser
        if named.len() > 0 {
          return default-parser(args, include-required: include-required)
        }
        default-parser(arguments(..ordered), include-required: include-required)
      } else {
        default-parser(args, include-required: include-required)
      }
    }
  }
}

/// A cast from a dictionary for the pair-like types, converting the dict to
/// positional arguments based on field order.
#let __pair-dict-cast(field-names) = {
  constructor => value => {
    let ordered = ()
    for name in field-names {
      if name in value {
        ordered.push(value.remove(name))
      }
    }
    if value.len() > 0 {
      assert(false, message: "elembic: unknown e.field(s) " + value.keys().join(", "))
    }
    constructor(..ordered)
  }
}

/// A single range of line numbers, see the `range` and `ranges` fields.
/// Can be constructed as `range(start, end)`, `range(start: .., end: ..)`,
/// or cast from the array `(start, end)`.
#let range = {
  e.types.declare(
    "range",
    prefix: __codly-prefix,
    ..__declaration("types", "range"),
    parse-args: __pair-parser("start"),
    casts: (
      (
        from: dictionary,
        with: __pair-dict-cast(("start", "end")),
      ),
      (
        from: array,
        check: value => value.len() in (1, 2),
        with: constructor => value => constructor(..value),
      ),
    ),
  )
}

/// A single skip, see the `skips` field.
/// Can be constructed as `skip(position, length)`, `skip(position: .., length: ..)`,
/// or cast from the array `(position, length)`.
#let skip = {
  e.types.declare(
    "skip",
    prefix: __codly-prefix,
    ..__declaration("types", "skip"),
    parse-args: __pair-parser("position"),
    casts: (
      (
        from: dictionary,
        with: __pair-dict-cast(("position", "length")),
      ),
      (
        from: array,
        check: value => value.len() in (1, 2),
        with: constructor => value => constructor(..value),
      ),
    ),
  )
}

/// A single highlighted line, see the `highlighted-lines` field.
/// Can be constructed as `highlighted-line(line)`, `highlighted-line(line, color)`,
/// or cast from an integer or an array of the form `(line, color)`.
#let highlighted-line = {
  e.types.declare(
    "highlighted-line",
    prefix: __codly-prefix,
    ..__declaration("types", "highlighted-line"),
    parse-args: __pair-parser("line"),
    casts: (
      (
        from: dictionary,
        with: __pair-dict-cast(("line", "color")),
      ),
      (
        from: int,
        with: constructor => value => constructor(value),
      ),
      (
        from: array,
        check: value => value.len() in (1, 2),
        with: constructor => value => constructor(..value),
      ),
    ),
  )
}

/// A source line excluded from line numbering, see the `unnumbered-lines` field.
/// Can be constructed as `unnumbered-line(line)`, `unnumbered-line(line, fill)`,
/// or cast from an integer or an array of the form `(line, fill)`.
#let unnumbered-line = {
  e.types.declare(
    "unnumbered-line",
    prefix: __codly-prefix,
    ..__declaration("types", "unnumbered-line"),
    parse-args: __pair-parser("line"),
    casts: (
      (
        from: dictionary,
        with: __pair-dict-cast(("line", "fill")),
      ),
      (
        from: int,
        with: constructor => value => constructor(value),
      ),
      (
        from: array,
        check: value => value.len() in (1, 2),
        with: constructor => value => constructor(..value),
      ),
    ),
  )
}

/// Shared formatting settings read by the line, highlight, and annotation
/// reference renderers. Generated references currently use figure numbering.
#let ref = {
  e.element.declare(
    "codly-ref",
    prefix: __codly-prefix,
    display: it => it.body,
    ..__declaration("elements", "ref"),
  )
}

/// A native reference to a displayed line of a codly code block.
#let line-ref = {
  import "src/lib.typ": __codly-line-ref-show

  e.element.declare(
    "codly-line-ref",
    prefix: __codly-prefix,
    display: __codly-line-ref-show.with(ref),
    ..__declaration("elements", "line-ref"),
  )
}

/// A native reference to a labelled highlight in a codly code block.
#let highlight-ref = {
  import "src/lib.typ": __codly-highlight-ref-show

  e.element.declare(
    "codly-highlight-ref",
    prefix: __codly-prefix,
    display: __codly-highlight-ref-show.with(ref),
    ..__declaration("elements", "highlight-ref"),
  )
}

/// A native reference to a labelled annotation in a codly code block.
#let annotation-ref = {
  import "src/lib.typ": __codly-annotation-ref-show

  e.element.declare(
    "codly-annotation-ref",
    prefix: __codly-prefix,
    display: __codly-annotation-ref-show.with(ref),
    ..__declaration("elements", "annotation-ref"),
  )
}

/// A single highlight within a codly code block.
#let highlight = {
  import "src/lib.typ": __codly-highlight-show
  import "src/themes.typ" as themes-impl

  e.element.declare(
    "codly-highlight",
    prefix: __codly-prefix,
    display: __codly-highlight-show.with(ref, highlight-ref),
    ..__declaration("elements", "highlight", scope: (
      highlight-config: highlight-config,
      themes-impl: themes-impl,
    )),
  )
}

/// A single line of a codly code block. Takes over the line-level styling
/// arguments of `codly` (`radius`, `inset`, `fill`, `stroke`).
#let line = {
  import "src/lib.typ": __codly-line-show

  e.element.declare(
    "codly-line",
    prefix: __codly-prefix,
    display: __codly-line-show.with(highlight, ref, line-ref),
    ..__declaration("elements", "line", scope: (highlight-config: highlight-config)),
  )
}

/// The header of a codly code block. Takes over the `header-` prefixed
/// arguments of `codly`.
#let header = {
  e.element.declare(
    "codly-header",
    prefix: __codly-prefix,
    display: it => it.body,
    ..__declaration("elements", "header"),
  )
}

/// The footer of a codly code block. Takes over the `footer-` prefixed
/// arguments of `codly`.
#let footer = {
  e.element.declare(
    "codly-footer",
    prefix: __codly-prefix,
    display: it => it.body,
    ..__declaration("elements", "footer"),
  )
}

/// The language badge of a codly code block. Takes over the `lang-` prefixed
/// arguments of `codly`, as well as `display-name` and `display-icon`.
#let lang = {
  import "src/lib.typ": __codly-lang-show

  e.element.declare(
    "codly-lang",
    prefix: __codly-prefix,
    display: __codly-lang-show,
    ..__declaration("elements", "lang", scope: (language: language)),
  )
}

/// A filename badge, independently styleable from the language badge.
#let file = {
  import "src/file.typ" as file-impl

  e.element.declare(
    "codly-file",
    prefix: __codly-prefix,
    display: file-impl.badge,
    ..__declaration("elements", "file"),
  )
}

/// A single annotation of a codly code block. Takes over the `annotation-`
/// prefixed arguments of `codly`.
#let annotation = {
  import "src/lib.typ": __codly-annotation-show

  e.element.declare(
    "codly-annotation",
    prefix: __codly-prefix,
    display: __codly-annotation-show,
    ..__declaration("elements", "annotation"),
  )
}

/// The painted bubble inside a callout. Owns independent styling defaults.
#let bubble = {
  import "src/callout.typ" as callout-impl

  e.element.declare(
    "codly-bubble",
    prefix: __codly-prefix,
    display: callout-impl.bubble-display,
    ..__declaration("elements", "bubble"),
  )
}

/// A callout row. Its cell properties can be configured with set rules.
#let callout = {
  import "src/callout.typ" as callout-impl

  e.element.declare(
    "codly-callout",
    prefix: __codly-prefix,
    display: callout-impl.display.with(bubble),
    ..__declaration("elements", "callout"),
  )
}

/// A line number of a codly code block. Takes over the `number-` prefixed
/// arguments of `codly`.
#let number = {
  import "src/lib.typ": __codly-numbering

  e.element.declare(
    "codly-number",
    prefix: __codly-prefix,
    display: it => if it.number == none { [] } else if type(it.number) == content {
      it.number
    } else if type(it.number) == array {
      __codly-numbering(it.numbering, ..it.number)
    } else {
      __codly-numbering(it.numbering, it.number)
    },
    ..__declaration("elements", "number"),
  )
}

#let sublang-block = {
  e.element.declare(
    "sublang-block",
    prefix: __codly-prefix,
    display: it => {
      show raw.where(block: true): raw => {
        let idx = str(it.idx)

        for (i, line) in raw.lines.enumerate() {
          let line-label = label("__codly_sublang_line_" + idx + "_" + str(i))
          [
            #metadata(line) #line-label
          ]
        }
      }

      it.body
    },
    ..__declaration("elements", "sublang-block"),
  )
}

#let codly = {
  import "src/lib.typ": __codly-show

  let codly-show = __codly-show.with(
    line,
    highlight,
    lang,
    file,
    header,
    footer,
    number,
    annotation,
    callout,
    bubble,
    annotation-ref,
    ref,
    sublang-block,
    gutter-constructor: gutter-column,
    diff-defaults: e.fields(diff()),
  )

  e.element.declare(
    "codly",
    prefix: __codly-prefix,
    construct: constructor => (..args) => {
      let element = constructor(..args)
      let body = e.fields(element).body
      // Figure kind inference scans the original content tree, before Elembic's
      // deferred display. Expose the source without placing it a second time.
      // The empty raw fallback also covers paths and contextual source content;
      // file reads and scoped language/theme settings remain deferred.
      let source = if type(body) == content { (body, raw("", block: true)) } else if (
        type(body) == str
      ) { raw(body, block: true) } else if type(body) == path { raw("", block: true) }
      if source == none { return element }
      // Keep Elembic's instance tag last, preserving fields/data extraction.
      (metadata(source), ..element.children).join()
    },
    display: it => {
      import "src/file.typ" as file-impl
      let body = it.remove("body")
      let prepared = file-impl.prepare(body, file: it.file, lang: it.lang)
      body = prepared.body
      it.file = prepared.file
      let file-position = it.at("file-position")
      let lang-position = it.at("lang-position")
      let inline-file = it.file != none and file-position != none and file-position.y == none
      let inline-lang = lang-position != auto and lang-position != none and lang-position.y == none
      if prepared.source and it.header == none and not inline-file and not inline-lang {
        it.header = []
      }
      if prepared.source and lang-position == auto and not inline-file {
        it.at("lang-position") = top + right
      }
      let data = it.remove("__elembic_stored_element_data")
      let constructor = data.default-constructor
      let alias-style = (size: text.size, theme: raw.theme, syntaxes: raw.syntaxes)
      show raw.where(block: true): codly-show.with(
        constructor,
        it,
        alias-style,
      )
      body
    },
    ..__declaration("elements", "new", scope: (
      diff: diff,
      gutter-column: gutter-column,
      sublang: sublang,
      rainbow: rainbow,
      indent-guides: indent-guides,
      smart-skip: smart-skip,
      highlight-config: highlight-config,
      annotation-config: annotation-config,
      callout-config: callout-config,
      range: range,
      skip: skip,
      highlighted-line: highlighted-line,
      unnumbered-line: unnumbered-line,
    )),
  )
}


#let new = codly
#let set_(..args) = {
  e.set_(codly, ..args)
}
#let show_(it, ..args) = {
  e.show_(codly, it, ..args)
}
#let selector(..args) = {
  e.selector(codly, ..args)
}
#let lang-set_(..args) = {
  e.set_(lang, ..args)
}
#let lang-show_(it, ..args) = {
  e.show_(lang, it, ..args)
}
#let file-set_(..args) = {
  e.set_(file, ..args)
}
#let file-show_(it, ..args) = {
  e.show_(file, it, ..args)
}
#let header-set_(..args) = {
  e.set_(header, ..args)
}
#let header-show_(it, ..args) = {
  e.show_(header, it, ..args)
}
#let footer-set_(..args) = {
  e.set_(footer, ..args)
}
#let footer-show_(it, ..args) = {
  e.show_(footer, it, ..args)
}
#let line-set_(..args) = {
  e.set_(line, ..args)
}
#let line-show_(it, ..args) = {
  e.show_(line, it, ..args)
}
#let highlight-set_(..args) = {
  e.set_(highlight, ..args)
}
#let highlight-show_(it, ..args) = {
  e.show_(highlight, it, ..args)
}
#let annotation-set_(..args) = {
  e.set_(annotation, ..args)
}
#let annotation-show_(it, ..args) = {
  e.show_(annotation, it, ..args)
}
#let callout-set_(..args) = {
  e.set_(callout, ..args)
}
#let callout-show_(it, ..args) = {
  e.show_(callout, it, ..args)
}
#let bubble-set_(..args) = {
  e.set_(bubble, ..args)
}
#let bubble-show_(it, ..args) = {
  e.show_(bubble, it, ..args)
}
#let ref-set_(..args) = {
  e.set_(ref, ..args)
}
#let line-ref-set_(..args) = {
  e.set_(line-ref, ..args)
}
#let line-ref-show_(it, ..args) = {
  e.show_(line-ref, it, ..args)
}
#let highlight-ref-set_(..args) = {
  e.set_(highlight-ref, ..args)
}
#let highlight-ref-show_(it, ..args) = {
  e.show_(highlight-ref, it, ..args)
}
#let annotation-ref-set_(..args) = {
  e.set_(annotation-ref, ..args)
}
#let annotation-ref-show_(it, ..args) = {
  e.show_(annotation-ref, it, ..args)
}
#let number-set_(..args) = {
  e.set_(number, ..args)
}
#let number-show_(it, ..args) = {
  e.show_(number, it, ..args)
}

/// In context, read source line count and the last displayed number of a block.
#import "src/lib.typ": __codly-block-info as info

/// Built-in theme dictionaries and a constructor for reusable custom themes.
#import "src/themes.typ": presets as themes, define as define-theme

/// Load a preset or custom theme with scoped element set rules.
/// Example: `#show: codly.theme("dark")`.
#let theme(..options) = {
  import "src/themes.typ" as impl
  assert(options.pos().len() <= 1, message: "codly: theme accepts at most one preset")
  let preset = options.pos().at(0, default: "thesis")
  impl.apply.with(
    config: define-theme(base: preset, ..options.named()),
    elements: (
      block: codly,
      line: line,
      number: number,
      lang: lang,
      file: file,
      header: header,
      footer: footer,
      highlight: highlight,
      callout: callout,
      bubble: bubble,
      annotation: annotation,
    ),
  )
}
