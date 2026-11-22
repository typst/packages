#import "highlight.typ" as hl
#import "languages.typ": lang-tag-config
#import "../styling/pre-themes.typ": pre-default, pseudo-pre-default
#import "utils.typ" as ut

// -----------------------------------------------------------------------------
// Document states
// -----------------------------------------------------------------------------

/// The styles outside of the raw environments (one per nested uraw call), used by the headers, footers, and comments.
#let uraw-style = state("uraw-style", ())

/// The current text, paragraph and block settings that the raw blocks and `uraw` change, so that the headers, footers and comments look as they would outside of the raw block.
///
/// -> dictionary
#let outside-style() = (
  text: (
    font: text.font,
    size: text.size,
    hyphenate: text.hyphenate,
    overhang: text.overhang,
  ),
  par: (
    leading: par.leading,
    spacing: par.spacing,
    justify: par.justify,
    first-line-indent: par.first-line-indent,
    hanging-indent: par.hanging-indent,
  ),
  block: (
    above: block.above,
    below: block.below,
    width: block.width,
    height: block.height,
    fill: block.fill,
    stroke: block.stroke,
    inset: block.inset,
    outset: block.outset,
    radius: block.radius,
  ),
)

/// The style of the headers, footers, comments: the one outside of the raw environment (the current one before the state is known).
///
/// -> dictionary
#let base-style() = {
  let styles = uraw-style.get()
  if styles.len() > 0 { styles.last() } else {
    (text: (:), par: (:), block: (:))
  }
}

// -----------------------------------------------------------------------------
// Initialization
// -----------------------------------------------------------------------------

#let initial-config = pre-default

#let initial-lang-configs = {
  let configs = (:)
  for (lang, lt) in lang-tag-config {
    configs.insert(lower(lang), (lang-tag: lt))
  }
  configs
}

#let uraw-config-state = state("uraw-config-state", initial-config)

#let uraw-lang-configs-state = state(
  "uraw-lang-configs-state",
  initial-lang-configs,
)

// -----------------------------------------------------------------------------
// General
// -----------------------------------------------------------------------------

#let resolve-args(args) = {
  let pos = args.pos()
  let lang = if pos.len() == 0 {
    none
  } else if type(pos.first()) == str {
    pos.first()
  } else {
    panic("If a language is given, it must be a string.")
  }
  return (lang, args.named())
}

#let uncontext-category-getter(category, lang) = if lang == none {
  uraw-config-state.get().at(category)
} else {
  ut.filter-add-dict(
    uraw-config-state.get().at(category),
    uraw-lang-configs-state
      .get()
      .at(lang, default: (:))
      .at(category, default: (:)),
  )
}

#let category-getter(category, args) = context uncontext-category-getter(
  category,
  resolve-args(args).first(),
)

#let category-setter(category, args) = {
  let (lang, args) = resolve-args(args)

  if lang == none {
    uraw-config-state.update(config => {
      config.at(category) = ut.filter-add-dict(config.at(category), args)
      return config
    })
  } else {
    uraw-lang-configs-state.update(lang-configs => {
      if not lang in lang-configs { lang-configs.insert(lang, (:)) }
      if not category in lang-configs.at(lang) {
        lang-configs.at(lang).insert(category, (:))
      }
      lang-configs.at(lang).at(category) += args
      return lang-configs
    })
  }
}

// -----------------------------------------------------------------------------
// Parsing
// -----------------------------------------------------------------------------

#let category-parser(category, args, lang) = ut.filter-add-dict(
  uncontext-category-getter(category, lang),
  args.at(category, default: (:)),
)

/// Read some code from a file, to display it with `uraw` or `uraw-diff`.
///
/// - file (path): The file, given with `path` (a simple string is refused as it would be read relative to the package).
/// - from (int): The first line read.
/// - to (int, none): The last line read, `none` for the end of the file.
/// - lang (str, auto, none): The language of the code, `auto` for the extension of the file.
/// -> dictionary
#let read-code(file, from: 1, to: none, lang: auto) = {
  if type(file) == str {
    panic(
      "A file of code must be given by its path, as `path(\""
        + file
        + "\")` (a string would be read relative to the package).",
    )
  }
  assert(type(file) == path, message: "A file of code must be a path.")

  // (the line break ending the file does not start a new line)
  let lines = read(file).trim("\n", at: end, repeat: false).split("\n")
  let to = if to == none { lines.len() } else { to }
  assert(
    type(from) == int
      and type(to) == int
      and 1 <= from
      and from <= to
      and to <= lines.len(),
    message: "The lines read must be between 1 and "
      + str(lines.len())
      + ", the first one being before the last one.",
  )

  let lang = if lang != auto { lang } else {
    let ext = repr(file).find(regex("\\.[^./\"]+\"\\)$"))
    if ext != none { ext.slice(1, -2) }
  }
  (
    uraw-code: (
      raw: raw(lines.slice(from - 1, to).join("\n"), lang: lang, block: true),
      first-line: from,
    ),
  )
}

/// The raw block of some code (given as a raw block, a path or read with `read-code`) and the number of its first line, any other content being returned with the first line 1.
#let code-input(it) = {
  let it = if type(it) in (str, path) { read-code(it) } else { it }
  if type(it) == dictionary and "uraw-code" in it {
    (it.uraw-code.raw, it.uraw-code.first-line)
  } else { (it, 1) }
}

#let parse-markers-entry(m) = if type(m) == array and m.len() == 2 {
  let pl = hl.parse-line(m.first())
  if pl != none { (pl, m.last()) }
} else if type(m) == dictionary and "line" in m and "content" in m {
  let pl = hl.parse-line(m.line)
  if pl != none { (pl, m.content) }
}

#let parse-markers(markers, line-index, line-numbers) = {
  let by-line = line-numbers.map(_ => none)

  for m in ut.single-to-list-map(markers, parse-markers-entry) {
    assert(
      m != none,
      message: "A marker is either an array of the form `(line, content)` or a dictionary of the form `(line: l, content: c)`.",
    )
    let ((from, to), content) = m
    for l in range(from, to + 1) {
      let i = line-index(l)
      assert(
        by-line.at(i) == none,
        message: "Several markers are given for line " + str(l) + ".",
      )
      by-line.at(i) = content
    }
  }

  return by-line
}

// -----------------------------------------------------------------------------
// Spec
// -----------------------------------------------------------------------------

#let make-spec(default, categories, shortcuts, additional) = {
  let categories = categories
    .map(sec => (sec, default.at(sec).keys()))
    .to-dict()

  let flat-names = (
    categories
      .pairs()
      .map(((sec, parameters)) => {
        parameters.map(param => if param != "visible" {
          ((sec + "-" + param): (sec, param))
        } else { (:) })
      })
      .flatten()
      .sum(default: (:))
      + shortcuts
  )

  (categories: categories, flat-names: flat-names, additional: additional)
}

#let uraw-spec = make-spec(
  pre-default,
  (
    "code",
    "numbers",
    "general",
    "header",
    "footer",
    "frame",
    "lang-tag",
    "highlight",
    "comment",
    "jump",
  ),
  (
    line-spacing: ("code", "line-spacing"),
    indentation: ("code", "indentation"),
    indent-size: ("code", "indent-size"),
    theme: ("code", "theme"),
    indented-line-return: ("code", "indented-line-return"),
    start: ("numbers", "start"),
    end: ("numbers", "end"),
    width: ("frame", "width"),
    breakable: ("frame", "breakable"),
    sharp-page-break: ("frame", "sharp-page-break"),
  )
    + pre-default.general.keys().map(k => (k, ("general", k))).to-dict(),
  ("markers", "highlights", "comments", "jumps", "follows", "precedes"),
)

#let diff-categories = ("diff-marker", "old", "new")

// (the settings of diffs: the ones of uraw, completed by the ones specific to diffs)
#let diff-default = (
  pre-default
    + pre-default
      .diff
      .pairs()
      .map(((c, s)) => (c, pre-default.at(c, default: (:)) + s))
      .to-dict()
)

#let diff-spec = make-spec(
  diff-default,
  diff-categories + uraw-spec.categories.keys(),
  (
    line-spacing: ("code", "line-spacing"),
    indentation: ("code", "indentation"),
    indent-size: ("code", "indent-size"),
    theme: ("code", "theme"),
    start: ("numbers", "start"),
    end: ("numbers", "end"),
    width: ("frame", "width"),
    breakable: ("frame", "breakable"),
    sharp-page-break: ("frame", "sharp-page-break"),
    indented-line-return: ("general", "indented-line-return"),
  )
    + diff-default.general.keys().map(k => (k, ("general", k))).to-dict(),
  ("follows", "precedes"),
)

#let pseudo-spec = make-spec(
  pseudo-pre-default,
  ("code", "numbers", "general", "header", "footer", "frame", "comment"),
  (
    line-spacing: ("code", "line-spacing"),
    indentation: ("code", "indentation"),
    indent-size: ("code", "indent-size"),
    style: ("code", "style"),
    start: ("numbers", "start"),
    end: ("numbers", "end"),
    width: ("frame", "width"),
    breakable: ("frame", "breakable"),
    sharp-page-break: ("frame", "sharp-page-break"),
  )
    + pseudo-pre-default.general.keys().map(k => (k, ("general", k))).to-dict(),
  (),
)

#let normalize-settings(args, spec) = {
  let settings = (:)

  // The settings are applied in the order they are given (by category or flat), a later one overriding an earlier one (so that the settings given after a theme override it)
  for (name, value) in args {
    if name in spec.categories {
      let parameters = spec.categories.at(name)
      if name == "highlight" {
        parameters += ("del", "ldel", "rdel")
      }
      let value = (
        if type(value) == dictionary {
          value
        } else if type(value) == bool and "visible" in parameters {
          (visible: value)
        } else if "format" in parameters
          and (
            value in (none, auto) or type(value) in (function, str)
          ) {
          (format: value)
        } else if "content" in parameters {
          (content: value)
        } else {
          panic(
            "The `"
              + name
              + "` settings must be a dictionary"
              + if "format" in parameters {
                " or a format (`none` to hide it, `auto`, a function)"
              } else if "visible" in parameters {
                " or a bool (its visibility)"
              }
              + ".",
          )
        }
      )
      value = ut.known-keys(value, parameters)
      settings.insert(name, settings.at(name, default: (:)) + value)
    } else if name == "diff" and spec != pseudo-spec {
      // The settings of diffs (as in a theme): they override the other ones for a diff, and are kept apart otherwise (for `set-uraw`)
      assert(
        type(value) == dictionary,
        message: "The `diff` settings must be a dictionary.",
      )
      let is-diff = "old" in spec.categories
      let target = if is-diff { settings } else {
        settings.at("diff", default: (:))
      }
      for (c, v) in normalize-settings(value, diff-spec) {
        target.insert(c, target.at(c, default: (:)) + v)
      }
      if is-diff { settings = target } else { settings.diff = target }
    } else if name in spec.additional {
      settings.insert(name, value)
    } else if name in spec.flat-names {
      let (section, key) = spec.flat-names.at(name)
      settings.insert(
        section,
        settings.at(section, default: (:)) + ((key): value),
      )
    }
    // (an unknown setting is ignored)
  }

  settings
}

// -----------------------------------------------------------------------------
// Main functions
// -----------------------------------------------------------------------------

/// Get the current `uraw` configuration, specific to a language if one is mentioned. The context must be known to call this function.
///
/// #example(`
/// #context get-uraw("typ")
/// `)
///
/// - lang (arguments): The optional language name as a positional argument.
///
/// -> dictionary
#let get-uraw(..lang) = (
  uraw-spec
    .categories
    .keys()
    .map(sec => (
      sec,
      uncontext-category-getter(sec, resolve-args(lang).first()),
    ))
    .to-dict()
)

/// Store some normalized settings of diffs, overriding the stored ones (the ones of a language if one is given).
#let update-diff(settings, lang) = {
  let add(diff) = {
    for (category, value) in settings {
      diff.insert(category, diff.at(category, default: (:)) + value)
    }
    diff
  }
  if lang == none {
    uraw-config-state.update(config => config + (diff: add(config.diff)))
  } else {
    uraw-lang-configs-state.update(lang-configs => {
      let configs = lang-configs.at(lang, default: (:))
      configs.diff = add(configs.at("diff", default: (:)))
      lang-configs + ((lang): configs)
    })
  }
}

/// Set the `uraw` configuration, specific to a language if one is mentioned. Here is an example changing the appearance for Typst raw blocks:
///
/// #example(`
/// #set-uraw("typ",
///   numbers: (format: "1.", align: top + left, sep: teal),
///   frame: (fill: teal.transparentize(95%), stroke: black),
///   lang-tag: (fill: teal.transparentize(75%), stroke: teal, name: "Typst"),
/// )
/// `)
///
/// The following two calls are equivalent:
///
/// #example(`
/// #set-uraw(code: (fill: aqua, indentation: blue))
/// #set-uraw(code-fill: aqua, code-indentation: blue)
/// `)
///
/// To have a better view of all the possible parameters, it is recommended to read the #link("https://github.com/JulesViennotFranca/ultraw/blob/main/docs/doc.pdf")[Docs].
///
/// - args (arguments): The optional language and the configuration settings. The language is given as a positional argument; the settings are given as named arguments. Here is the complete list of settings with their type and default value (set by `themes.pre-themes.pre-default`):
///
///   - *code*
///     - `line-spacing (length | auto) = auto` the space between lines, `auto` is the leading of the paragraphs (`par.leading`)
///     - `theme (bytes | str | auto | none) = auto` the syntax highlighting theme, as the `theme` of `raw`
///     - `color (function | color | gradient | tiling | auto | none) = auto` the color of the code, `auto` and `none` being the color of the text of the document, a function gives the color from the line number (e.g. `n => if calc.even(n) { blue } else { red }`)
///     - `fill (function | color | gradient | tiling | none) = none` the background of the code, `none` being the one of the frame, a function gives the background from the line number
///     - `indentation (length | color | gradient | stroke | tiling | none) = gray` the stroke of the indentation guidelines, `none` for no guidelines
///     - `indented-line-return (bool) = true` whether the code after a line return starts at the indentation of its line, or at the left
///     - `indent-size (int | auto) = auto` the number of spaces of an indent, `auto` detecting it from the most common indent #(" ")
///   increase
///
///   - *numbers*
///     - `start (int | auto) = auto` the number of the first line, `auto` being 1 or the first line read with `read-code`
///     - `end (int | none) = none` the number of the last line, which overrides `start` when it is not `none`
///     - `format (function | str | auto | none) = auto` how the numbers are displayed: a function gives some content from the number (e.g. `n => strong(str(n))`), a string must contain a `1` replaced by the number (e.g. `"1:"`), `auto` displays the number and `none` hides the numbers
///     - `color (function | color | gradient | tiling | auto | none) = auto` the color of the numbers, `auto` being the one of the code, `none` the color of the text of the document, a function gives it from the line number
///     - `fill (function | color | gradient | tiling | auto | none) = auto` the background of the numbers, `auto` being the one of the code, `none` the one of the frame, a function gives it from the line number
///     - `gutter (length | array | auto) = auto` the space between the numbers and the code: a pair `(before, after)` gives the spaces before and after the separator, a relative length `l` is `(l / 2, l / 2)`, `auto` is `(frame.inset.left, frame.inset.right)`
///     - `sep (length | color | gradient | stroke | tiling | none) = none` the separator line between the numbers (and markers) and the code
///     - `align (alignment) = top + right` the alignment of the numbers in their cells (markers share the same vertical alignment but are centered #(" ")
///   horizontally)
///
///   - *general*
///     - `coloring-follow-numbers (bool) = true` whether the coloring functions (`fill`, `color`) take the line numbers, or the absolute positions of the lines in the block
///     - `markers-over-numbers (bool) = false` whether the markers are displayed over the numbers (rather than in their own column), a line whose number is hidden by a marker can still be referenced with `@label.n`
///     - `line-reference (function) = n => ", line " + str(n) + ","` the text written after "Listing ..." when referencing a line
///     - `default-stroke-thickness (length) = .5pt` the thickness of the strokes given without #(" ")
///   one
///
///   - *header* and *footer* (they have the same parameters)
///     - `content (content | none) = none` the content of the header or footer, `none` for no header or footer
///     - `color (color | gradient | tiling | auto | none) = auto` the color of the text of the header or footer, `auto` being the one of the code, `none` being the color of the text of the document
///     - `fill (color | gradient | tiling | auto | none) = none` the background color, with `auto` it is the code background color at line `numbers.start - 1` (useful for striped code styles), with `none` it is the background color of the frame
///     - `repeat (bool) = false` whether the header or footer of a raw block should be repeated at page breaks or when chaining blocks with `follows` and `precedes`
///     - `sep (length | color | gradient | stroke | tiling | auto | none) = auto` the separator line between the header or footer and the code, `auto` is the same as the frame's stroke
///     - `inset (relative | dictionary) = 5pt` the inset of the header or footer block
///     - `align (alignment) = left + horizon` the alignment of the content of the header or footer
///     - `code-aligned (bool) = false` whether to align the header or footer content with the code (when numbers or markers are #(" ")
///   visible)
///
///   - *frame*
///     - `breakable (bool) = true` whether the raw block is breakable
///     - `sharp-page-break (bool) = true` at page breaks, when `false` the raw block is displayed within two frame blocks (normal Typst processing), when `true` the frame block appears cut in half (no border, no radius, no inset along the page break)
///     - `width (relative | auto) = auto` the total width of the raw block
///     - `fill (color | gradient | tiling | none) = none` the background color of the whole raw block
///     - `stroke (length | color | gradient | stroke | tiling | dictionary | none) = none` the border of the raw block
///     - `radius (relative | dictionary) = 1mm` the radius of the raw block
///     - `inset (length | dictionary) = (x: 3pt)` the inset of the raw #(" ")
///   block
///
///   - *lang-tag* (updated by default for common languages)
///     - `visible (bool) = true` whether to show the lang tag or not
///     - `name (content | auto | none) = auto` the language name displayed in the lang tag, `auto` defaults to the raw block `lang`
///     - `icon (content | none) = none` the icon displayed in the lang tag
///     - `placement ("inline" | "code" | "header" | "top-left" | "top" | "top-right" | "bottom-left" | "bottom" | "bottom-right" | "left-top" | "left" | "left-bottom" | "right-top" | "right" | "right-bottom") = "code"` where the lang tag is displayed: `"inline"` places it on the first line of code; `"code"` is like `"inline"` but the vertical space for the lang tag is reserved on all the lines of the code; `"header"` places it in the header and defaults to `"code"` when there is no header; the rest place it on the border of the frame, the first location indicates the frame side while the second indicates the placement on that side (no second location is like `center` or `horizon`)
///     - `spacing (length) = 5pt` the spacing between the lang tag and the content when the placement is `"inline"`, `"code"` or `"header"`
///     - `color (color | gradient | tiling | auto | none) = auto` the color of the language name in the lang tag, `auto` is the same as the code's color, `none` is the same as the document's text color
///     - `fill (color | gradient | tiling | auto | none) = luma(230)` the background color of the lang tag, `auto` defaults to the frame's background color
///     - `stroke (length | color | gradient | stroke | tiling | dictionary | auto | none) = auto` the border of the lang tag, `auto` defaults to the frame's border
///     - `radius (relative | dictionary) = 2pt` the radius of the lang #(" ")
///   tag
///
///   - *highlight* default parameters for highlights
///     - `fill (color | gradient | tiling | none) = none` the background color of the highlight block
///     - `stroke (length | color | gradient | stroke | tiling | none) = none` the border of the highlight block
///     - `radius (relative | dictionary) = 3pt` the radius of the highlight block
///     - `code-style (function) = it => it` a styling function to apply to the highlighted content
///     - `sticky (bool | auto) = auto` whether the parts of the highlight merge from one line to the next (the stroke and radius are changed accordingly), `auto` sets this parameter automatically: a highlight defined with `line` is sticky while others are not
///     - `expand (alignment | auto | none) = auto` the side on which the highlight expands when going from one line to the next (`none` = no expansion, `left` = left side, `right` = right side, `center` = both sides), `auto` sets this parameter automatically: a highlight defined with `line` expands on both sides while others don't #(" ")
///   expand
///
///   - *comment* default styling parameters for comments
///     - `style (function) = text.with(style: "italic")` a basic style to apply to the content of all comments
///     - `indent (bool) = false` whether the comment inherits the indentation of the targeted line
///     - `fill (color | gradient | tiling | none) = luma(245)` the background color of the comment, `none` is the same as the background color of the targeted line
///     - `separate (bool | length | color | gradient | stroke | tiling | dictionary: (top: ..., bottom: ...) | auto | none) = false` whether the comment is separated from the code: `false` lets the numbers column's separator and guidelines pass over the comment; other values draw a separator at the `top` or `bottom` between the code and other comments that don't have a separator on the shared side (`none` for no separator, `true` or `auto` for the separator of the numbers column), the style applies to both separators if it is not a dictionary
///     - `marker (content | none) = none` the marker of the comment
///     - `marker-fill (color | gradient | tiling | auto | none) = auto` the background color of the comment's marker, `auto` is the comment's background color, `none` is the numbers column background color
///     - `marker-placement ("numbers" | "markers") = "numbers"` the placement of the marker inside the numbers column: in the space reserved for `"numbers"` or for #(" ")
///   `"markers"`
///
///   - *jump* default styling parameters for jumps
///     - `comment (content | function | none) = none` the default comment content associated with jumps, a function taking the bounds of the jump `from` and `to` as arguments
///     - `style`, `indent`, `fill`, `separate`, `marker`, `marker-fill`, `marker-placement` as for `comment`, `auto` is the default value for all of these and it means taking the corresponding `comment` #(" ")
///   parameter
///
///   - *diff* the settings of diffs, as for `set-uraw-diff`
///
/// -> content
#let set-uraw(..args) = {
  let lang = args.pos()
  let settings = normalize-settings(args.named(), uraw-spec)
  for sec in uraw-spec.categories.keys() {
    if sec in settings {
      category-setter(sec, arguments(..lang, ..settings.at(sec)))
    }
  }
  if "diff" in settings {
    update-diff(settings.diff, resolve-args(arguments(..lang)).first())
  }
}

// -----------------------------------------------------------------------------
// Pseudo code
// -----------------------------------------------------------------------------

#let initial-pseudo-config = pseudo-pre-default

#let uraw-pseudo-config-state = state(
  "uraw-pseudo-config-state",
  initial-pseudo-config,
)

/// The settings of a category of pseudo code, the given ones taking precedence over the configured ones (in a context).
///
/// - category (str):
/// - args (dictionary): The normalized settings (see `normalize-settings`).
/// -> dictionary
#let pseudo-category-parser(category, args) = ut.filter-add-dict(
  uraw-pseudo-config-state.get().at(category),
  args.at(category, default: (:)),
)

/// Get the current `uraw-pseudo` configuration. The context must be known to call this function.
///
/// #example(`
/// #context get-uraw-pseudo()
/// `)
///
/// -> dictionary
#let get-uraw-pseudo() = uraw-pseudo-config-state.get()

/// Set the `uraw-pseudo` configuration. Here is an example changing the appearance of pseudo codes:
///
/// #example(`
/// #set-uraw-pseudo(
///   numbers: (format: "1.", align: top + left, sep: teal),
///   frame: (fill: teal.transparentize(95%), stroke: black),
///   code: (style: emph, indent-size: 5pt),
/// )
/// `)
///
/// The following two calls are equivalent:
///
/// #example(`
/// #set-uraw-pseudo(code: (fill: aqua, indentation: blue))
/// #set-uraw-pseudo(code-fill: aqua, code-indentation: blue)
/// `)
///
/// To have a better view of all the possible parameters, it is recommended to read the #link("https://github.com/JulesViennotFranca/ultraw/blob/main/docs/doc.pdf")[Docs].
///
/// - args (arguments): Pseudo codes have the same `code`, `numbers`, `general`, `header`, `footer`, `frame` and `comment` settings as `uraw` (see `set-uraw` for their description, see `themes.pre-themes.pseudo-pre-default` for the default values). The only exceptions are:
///   - `indent-size` is now a length;
///   - `code` has an additional `style` parameter that applies a styling function to pseudo code lines;
///   - `general` has an additional `algorithm-figure` parameter that controls whether pseudo codes inside figures are counted as Algorithms or Figures (`#show: uraw` is required for the counting of Algorithms to work);
///   - `theme`, `indented-line-return`, `lang-tag`, `markers-over-numbers`, `comment-marker-placement` are removed.
///
/// -> content
#let set-uraw-pseudo(..args) = {
  assert(
    args.pos().len() == 0,
    message: "The settings of pseudo code do not depend on a language.",
  )
  let settings = normalize-settings(args.named(), pseudo-spec)
  uraw-pseudo-config-state.update(config => {
    for (category, value) in settings {
      config.at(category) = ut.filter-add-dict(config.at(category), value)
    }
    return config
  })
}

// -----------------------------------------------------------------------------
// Diff
// -----------------------------------------------------------------------------

/// The settings specific to diffs, by category (in a context): the global ones, overridden by the ones of the language if one is given.
///
/// - lang (none, str):
/// -> dictionary
#let uncontext-diff-getter(lang) = {
  let diff = uraw-config-state.get().diff
  let lang-diff = if lang == none { (:) } else {
    uraw-lang-configs-state
      .get()
      .at(lang, default: (:))
      .at("diff", default: (:))
  }
  for (category, value) in lang-diff {
    diff.insert(category, diff.at(category, default: (:)) + value)
  }
  diff
}

// The settings of diffs are the ones of uraw, overridden by the ones stored for diffs (global, then of the language)
#let diff-category-parser(category, args, lang) = ut.filter-add-dict(
  (
    if category in diff-categories { (:) } else {
      uncontext-category-getter(category, lang)
    }
      + uncontext-diff-getter(lang).at(category, default: (:))
  ),
  args.at(category, default: (:)),
)

/// Get the current `uraw-diff` configuration, specific to a language if one is mentioned. The context must be known to call this function.
///
/// #example(`
/// #context get-uraw-diff("typ")
/// `)
///
/// - lang (arguments): The optional language name as a positional argument.
///
/// -> dictionary
#let get-uraw-diff(..lang) = uncontext-diff-getter(resolve-args(lang).first())

/// Set the `uraw-diff` configuration, specific to a language if one is mentioned. Here is an example changing the appearance for Typst diffs:
///
/// #example(`
/// #set-uraw-diff("typ",
///   numbers: (format: "1.", align: top + left, sep: teal),
///   lang-tag: (fill: teal.transparentize(75%), stroke: teal, name: "Typst"),
///   old: (fill: orange.lighten(80%), numbers-fill: orange.lighten(40%)),
///   new: (fill: blue.lighten(85%), numbers-fill: blue.lighten(50%)),
/// )
/// `)
///
/// The following two calls are equivalent:
///
/// #example(`
/// #set-uraw-diff(code: (fill: aqua, indentation: blue))
/// #set-uraw-diff(code-fill: aqua, code-indentation: blue)
/// `)
///
/// To have a better view of all the possible parameters, it is recommended to read the #link("https://github.com/JulesViennotFranca/ultraw/blob/main/docs/doc.pdf")[Docs].
///
/// - args (arguments): The optional language and the configuration settings. The language is given as a positional argument; the settings are given as named arguments. By default, diffs inherit the same settings as `uraw` (set by `set-uraw`) but `set-uraw-diff` updates the configuration for diffs only. In addition to the settings of `uraw` (see `set-uraw` for their description), here is the complete list of diff-only settings with their type and default value (set by `themes.pre-themes.pre-default`):
///
///   - *general* parameters specific to diffs
///     - `columns (relative | ratio | array | auto) = (auto, auto)` the columns of the diff, one column meaning that both versions are displayed in the same code part, working as the `columns` parameter of `grid`
///     - `column-gutter (relative) = 0pt` a separator space when there are two columns
///     - `sep (length | color | gradient | stroke | tiling | none) = gray` a separator line when there are two columns
///     - `blank-fill (color | gradient | tiling | none) = style.hatch(luma(200))` the background color of spaces that don't contain anything
///     - `line-reference (function) = (n, version) => ", " + version + " line " + str(n) + ","` the text written after "Listing ..." when referencing a precise #(" ")
///   line
///
///   - *old* and *new* versions parameters
///     - `diff-marker (content) = text(red.darken(20%))[-] / text(olive)[+]` the marker associated with changes on old / new lines
///     - `fill (color | gradient | tiling | none) = red.lighten(75%) / rgb("#32C04C").lighten(75%)` the background color of old / new lines of code where changes happened, `none` doesn't change the background
///     - `numbers-color (color | gradient | tiling | auto | none) = auto` the color of the numbers on old / new lines that change, `auto` is the same color as the other numbers, `none` is the same as the document's text color
///     - `numbers-fill (color | gradient | tiling | auto | none) = rgb("#FF8B85") / rgb("#7CCBA7")` the background color of numbers on old / new lines that change, `auto` is the same as `fill`, `none` is the background color of #(" ")
///   numbers
///
///   - *diff-marker*
///     - `visible (bool) = true` whether the markers specific to diffs (lying in the code part) are shown
///     - `gutter (length) = 3pt` the space between the diff markers and the code
///     - `unchanged (content) = []` the markers to use for lines with no #(" ")
///   changes
///
///   - *comment* parameters specific to diffs
///     - `span (bool) = false` whether the comments span over both code versions, their marker being in the numbers column of the old #(" ")
///   code
///
///   - *jump* parameters specific to diffs
///     - `span (bool | auto) = auto` as for `comment-span`, `auto` being the same as `comment-span`
///
/// -> content
#let set-uraw-diff(..args) = {
  let (lang, settings) = resolve-args(args)
  update-diff(normalize-settings(settings, diff-spec), lang)
}

// -----------------------------------------------------------------------------
// Themes
// -----------------------------------------------------------------------------

#let flatten-theme(theme, spec) = {
  let flat = (:)
  for (category, settings) in theme {
    for (k, v) in ut.known-keys(settings, spec.categories.at(category)) {
      // (a name or icon of the lang tag `none` would hide the ones of the languages)
      if category == "lang-tag" and k in ("name", "icon") and v == none {
        continue
      }
      flat.insert(if k == "visible" { category } else { category + "-" + k }, v)
    }
  }
  flat
}

#let merge-categories(base, pre-theme) = (
  base
    + pre-theme
      .pairs()
      .map(((c, s)) => (c, base.at(c, default: (:)) + s))
      .to-dict()
)

#let complete-pre-theme(pre-theme) = {
  // (the unknown categories being ignored)
  pre-theme = ut.known-keys(pre-theme, uraw-spec.categories.keys() + ("diff",))
  if "diff" in pre-theme {
    pre-theme.diff = ut.known-keys(pre-theme.diff, diff-spec.categories.keys())
  }
  let diff = merge-categories(pre-default.diff, pre-theme.at(
    "diff",
    default: (:),
  ))
  merge-categories(pre-default, pre-theme) + (diff: diff)
}

/// Make a theme of `uraw` and `uraw-diff` from a pre-theme.
///
/// - pre-theme (dictionary): The pre-theme to format, look at `themes.pre-themes.pre-default` for an example.
/// -> dictionary
#let make(pre-theme) = {
  let pre-theme = complete-pre-theme(pre-theme)
  let diff = pre-theme.remove("diff")
  flatten-theme(pre-theme, uraw-spec) + (diff: flatten-theme(diff, diff-spec))
}

/// Make a theme of `uraw-pseudo` from a pre-theme.
///
/// - pre-theme (dictionary): The pre-theme to format, look at `themes.pre-themes.pseudo-pre-default` for an example.
/// -> dictionary
#let make-pseudo(pre-theme) = {
  flatten-theme(
    merge-categories(
      pseudo-pre-default,
      ut.known-keys(pre-theme, pseudo-spec.categories.keys()),
    ),
    pseudo-spec,
  )
}
