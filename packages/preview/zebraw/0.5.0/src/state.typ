#let background-color-state = state("zebraw-background-color", luma(245))
#let highlight-color-state = state("zebraw-highlight-color", rgb("#94e2d5").lighten(70%))
#let comment-color-state = state("zebraw-comment-color", none)
#let lang-color-state = state("zebraw-lang-color", none)

#let inset-state = state("zebraw-inset", (top: 0.34em, right: 0.34em, bottom: 0.34em, left: 0.34em))
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

/// Initialize the `zebraw` block in global.
/// -> content
#let zebraw-init(
  /// Whether to show the line numbers.
  /// -> boolean
  numbering: true,
  /// The inset of each line.
  /// -> dictionary
  inset: (top: 0.34em, right: 0.34em, bottom: 0.34em, left: 0.34em),
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
  /// The body
  /// -> content
  body,
) = context {
  numbering-state.update(numbering)
  inset-state.update(inset)

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

  body
}

#let parse-zebraw-args(
  numbering: none,
  inset: none,
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
  let numbering = if numbering == none {
    numbering-state.get()
  } else {
    numbering
  }
  let inset = if inset == none {
    inset-state.get()
  } else {
    inset-state.get() + inset
  }

  let background-color = if background-color == none {
    background-color-state.get()
  } else {
    background-color
  }

  let highlight-color = if highlight-color == none {
    highlight-color-state.get()
  } else {
    highlight-color
  }

  let comment-color = if comment-color == none {
    if comment-color-state.get() == none {
      highlight-color-state.get().lighten(50%)
    } else {
      comment-color-state.get()
    }
  } else {
    comment-color
  }

  let lang-color = if lang-color == none {
    if lang-color-state.get() == none { comment-color } else { lang-color-state.get() }
  } else {
    lang-color
  }

  let comment-flag = if comment-flag == none {
    comment-flag-state.get()
  } else {
    comment-flag
  }

  let lang = if lang == none {
    lang-state.get()
  } else {
    lang
  }

  let comment-font-args = if comment-font-args == none {
    comment-font-args-state.get()
  } else {
    comment-font-args-state.get() + comment-font-args
  }

  let lang-font-args = if lang-font-args == none {
    lang-font-args-state.get()
  } else {
    lang-font-args-state.get() + lang-font-args
  }

  let numbering-font-args = if numbering-font-args == none {
    numbering-font-args-state.get()
  } else {
    numbering-font-args-state.get() + numbering-font-args
  }

  let extend = if extend == none {
    extend-state.get()
  } else {
    extend
  }

  let hanging-indent = if hanging-indent == none {
    hanging-indent-state.get()
  } else {
    hanging-indent
  }

  let indentation = if indentation == none {
    indentation-state.get()
  } else {
    indentation
  }

  let fast-preview = fast-preview-state.get() or sys.inputs.at("zebraw-fast-preview", default: false)

  let numbering-separator = if numbering-separator == none {
    numbering-separator-state.get()
  } else {
    numbering-separator
  }


  (
    numbering: numbering,
    inset: inset,
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
