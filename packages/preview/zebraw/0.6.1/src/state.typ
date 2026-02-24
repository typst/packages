#let background-color-state = state("zebraw-background-color", luma(245))
#let highlight-color-state = state("zebraw-highlight-color", rgb("#94e2d5").lighten(70%))
#let comment-color-state = state("zebraw-comment-color", none)
#let lang-color-state = state("zebraw-lang-color", none)

#let inset-state = state("zebraw-inset", (top: 0.34em, right: 0.34em, bottom: 0.34em, left: 0.34em))
#let radius-state = state("zebraw-radius", 0.34em)
#let comment-flag-state = state("zebraw-comment-flag", ">")
#let numbering-state = state("zebraw-numbering", true)
#let lang-state = state("zebraw-lang", true)
#let extend-state = state("zebraw-extend", true)
#let numbering-separator-state = state("zebraw-numbering-separator", false)

#let numbering-font-args-state = state("zebraw-numbering-font-args", (:))
#let comment-font-args-state = state("zebraw-comment-font-args", (:))
#let lang-font-args-state = state("zebraw-lang-font-args", (:))

#let hanging-indent-state = state("zebraw-hanging-indent", false)
#let indentation-state = state("zebraw-indentation", 0)
#let fast-preview-state = state("zebraw-fast-preview", false)

/// Helper function to get argument value or fallback to state
/// If arg is none, returns the state value; otherwise returns arg itself
#let get-arg-or-state(arg, state-getter) = {
  if arg == none {
    state-getter.get()
  } else {
    arg
  }
}

/// Helper function to merge state with provided argument (for dictionaries)
/// Used for inset and font-args which need to be merged with global state
#let merge-state-with-arg(arg, state-getter) = {
  if arg == none {
    state-getter.get()
  } else {
    state-getter.get() + arg
  }
}

/// Initialize the `zebraw` block in global.
/// -> content
#let zebraw-init(
  /// Whether to show the line numbers.
  /// -> boolean
  numbering: true,
  /// The inset of each line.
  /// -> dictionary
  inset: (top: 0.34em, right: 0.34em, bottom: 0.34em, left: 0.34em),
  /// The radius of the code block corners.
  /// -> length
  radius: 0.34em,
  /// The background color of the block and normal lines.
  /// -> color | array
  background-color: luma(245),
  /// The background color of the highlighted lines.
  /// -> color
  highlight-color: rgb("#94e2d5").lighten(70%),
  /// The background color of the comments. When it's set to `none`, it will be rendered in a lightened `highlight-color`.
  /// -> color
  comment-color: none,
  /// The background color of the language tab. The color is set to `none` at default and it will be rendered in comments' color.
  /// -> color
  lang-color: none,
  /// The flag at the beginning of comments.
  /// -> string | content
  comment-flag: ">",
  /// Whether to show the language tab, or a string or content of custom language name to display.
  /// -> boolean | string | content
  lang: true,
  /// The arguments passed to comments' font.
  /// -> dictionary
  comment-font-args: (:),
  /// The arguments passed to the language tab's font.
  /// -> dictionary
  lang-font-args: (:),
  /// The arguments passed to the line numbers' font.
  /// -> dictionary
  numbering-font-args: (:),
  /// Whether to extend the vertical spacing.
  /// -> boolean
  extend: true,
  /// Whether to show the numbering separator line.
  /// -> boolean
  numbering-separator: false,
  /// Whether to show the hanging indent.
  /// -> boolean
  hanging-indent: false,
  /// The amount of indentation. Default is 0, when it's set to a positive integer, the indentation line will be shown.
  /// -> integer
  indentation: 0,
  /// Whether to enable the fast preview mode.
  /// -> boolean
  fast-preview: false,
  /// (Only for HTML) Whether to show the copy button.
  /// -> boolean
  copy-button: true,
  /// The body
  /// -> content
  body,
) = context {
  numbering-state.update(numbering)
  inset-state.update(it => it + inset)
  radius-state.update(radius)

  background-color-state.update(background-color)
  highlight-color-state.update(highlight-color)
  comment-color-state.update(comment-color)
  lang-color-state.update(lang-color)

  comment-flag-state.update(comment-flag)
  lang-state.update(lang)

  comment-font-args-state.update(comment-font-args)
  lang-font-args-state.update(lang-font-args)
  numbering-font-args-state.update(numbering-font-args)

  extend-state.update(extend)
  numbering-separator-state.update(numbering-separator)

  hanging-indent-state.update(hanging-indent)
  indentation-state.update(indentation)
  fast-preview-state.update(fast-preview)

  if counter("zebraw-html-styles").get().last() == 0 {
    import "html.typ": zebraw-html-styles
    zebraw-html-styles()
    counter("zebraw-html-styles").step()
  }
  if counter("zebraw-html-clipboard").get().last() == 0 and copy-button {
    import "html.typ": zebraw-html-clipboard-copy
    zebraw-html-clipboard-copy()
    counter("zebraw-html-clipboard").step()
  }

  body
}

#let parse-zebraw-args(
  numbering: none,
  inset: none,
  radius: none,
  background-color: none,
  highlight-color: none,
  comment-color: none,
  lang-color: none,
  comment-flag: none,
  lang: none,
  comment-font-args: none,
  lang-font-args: none,
  numbering-font-args: none,
  extend: none,
  hanging-indent: none,
  indentation: none,
  fast-preview: none,
  numbering-separator: none,
) = {
  // Use helper functions to reduce repetition
  let numbering = get-arg-or-state(numbering, numbering-state)
  let inset = merge-state-with-arg(inset, inset-state)
  let radius = get-arg-or-state(radius, radius-state)
  let background-color = get-arg-or-state(background-color, background-color-state)
  let highlight-color = get-arg-or-state(highlight-color, highlight-color-state)

  // Comment color has special fallback logic
  let comment-color = if comment-color == none {
    if comment-color-state.get() == none {
      highlight-color-state.get().lighten(50%)
    } else {
      comment-color-state.get()
    }
  } else {
    comment-color
  }

  // Lang color falls back to comment color if not set
  let lang-color = if lang-color == none {
    if lang-color-state.get() == none { comment-color } else { lang-color-state.get() }
  } else {
    lang-color
  }

  let comment-flag = get-arg-or-state(comment-flag, comment-flag-state)
  let lang = get-arg-or-state(lang, lang-state)

  // Font args need to be merged with state
  let comment-font-args = merge-state-with-arg(comment-font-args, comment-font-args-state)
  let lang-font-args = merge-state-with-arg(lang-font-args, lang-font-args-state)
  let numbering-font-args = merge-state-with-arg(numbering-font-args, numbering-font-args-state)

  let extend = get-arg-or-state(extend, extend-state)
  let hanging-indent = get-arg-or-state(hanging-indent, hanging-indent-state)
  let indentation = get-arg-or-state(indentation, indentation-state)
  let numbering-separator = get-arg-or-state(numbering-separator, numbering-separator-state)

  // Fast preview has special logic with sys.inputs
  let fast-preview = fast-preview-state.get() or sys.inputs.at("zebraw-fast-preview", default: false)

  (
    numbering: numbering,
    inset: inset,
    radius: radius,
    background-color: background-color,
    highlight-color: highlight-color,
    comment-color: comment-color,
    lang-color: lang-color,
    comment-flag: comment-flag,
    lang: lang,
    comment-font-args: comment-font-args,
    lang-font-args: lang-font-args,
    numbering-font-args: numbering-font-args,
    extend: extend,
    numbering-separator: numbering-separator,
    hanging-indent: hanging-indent,
    indentation: indentation,
    fast-preview: fast-preview,
  )
}
