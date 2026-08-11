/// HTML output module for hypraw code highlighting.

#import "utils.typ": *
#import "styles.typ": hypraw-state, resolve-highlights, resolve-line-numbers

/// Maps CSS styles to generated class names for deduplication.
#let _hl-class-db() = {
  query(<hypraw:style>).dedup().enumerate().map(((i, m)) => (m.value, "c" + str(i))).to-dict()
}

/// Applies HTML styling to a single text fragment. Generates a span element with CSS classes or inline styles.
#let code-span-rule(it) = {
  let fields = it.fields()
  if "attrs" in fields and "style" in fields.attrs {
    let style = fields.attrs.remove("style")
    [#metadata(style)<hypraw:style>]
    html.span(it.body, class: _hl-class-db().at(style, default: "`"))
  } else {
    it
  }
}

/// Renders inline code as HTML `<code>` elements with syntax highlighting.
#let code-inline-rule(it) = {
  let attrs = (
    class: class-list("hypraw", if it.lang != none { "language-" + it.lang }),
  )

  html.elem("code", attrs: attrs, {
    it.lines.join("\n")
  })
}

/// Renders a single line with optional line number gutter.
#let render-line(line, line-number, line-classes: ()) = {
  let classes = ("ec-line",) + line-classes
  html.div(class: classes.join(" "), {
    // Add gutter with line number
    html.div(class: "gutter", {
      html.div(class: "ln", {
        html.span(aria-hidden: true, str(line-number))
      })
    })
    // Code content
    html.div(class: "code", line)
  })
}

/// Renders block code as HTML `<div><pre><code>` structure with syntax highlighting.
/// Supports optional line numbers displayed in a gutter.
#let code-rule(
  it,
  line-numbers: false,
  copy-button: true,
) = {
  let style-state = hypraw-state.get()
  hypraw-state.update((:)) // Reset upon used
  let copy-button = style-state.at("copy-button", default: copy-button)
  let line-numbers = resolve-line-numbers(
    style-state.at("line-numbers", default: line-numbers),
    it.lines.len(),
  )
  let highlights = resolve-highlights(
    style-state.at("highlight", default: none),
    it.lines.len(),
  )

  let attrs = (class: "hypraw")
  // Add class to indicate line numbers are enabled
  if line-numbers != none {
    attrs.class = "hypraw has-line-numbers"

    // Calculate the width needed for line numbers (number of digits)
    let ln-width = if line-numbers.len() > 0 {
      // Use the width of the first and last number
      calc.max(str(line-numbers.first()).len(), str(line-numbers.last()).len())
    } else {
      0
    }
    // Set line number width as CSS variable when width > 2
    if ln-width > 2 {
      attrs.style = "--ln-width:" + str(ln-width) + "ch"
    }
  }

  html.div(..attrs, {
    // Add copy button if enabled
    if copy-button {
      html.elem("button", attrs: (
        class: "hypraw-copy-btn",
        aria-label: "Copy code",
        data-copy: it.text,
      ))
    }

    html.pre({
      let code-attrs = (:)
      if it.lang != none {
        code-attrs.data-lang = it.lang
      }
      html.elem("code", attrs: code-attrs, {
        if line-numbers != none {
          // Render with line structure for line numbers
          for (i, (line, ln)) in it.lines.zip(line-numbers).enumerate() {
            // Collect all classes for this line from highlights
            let line-classes = ()
            for (class, indices) in highlights {
              if i in indices {
                line-classes.push(class)
              }
            }
            render-line(line, ln, line-classes: line-classes)
          }
        } else {
          // Original simple rendering without line structure
          it.lines.join("\n")
        }
      })
    })
  })
}

/// Generates CSS styles for syntax highlighting. Creates `<style>` element with rules for HTML output.
#let additional-styles() = {
  if is-html-target() {
    let db = _hl-class-db()
    if db.len() > 0 {
      db.pairs().map(((k, v)) => ".hypraw ." + v + "{" + k + "}\n").join()
    }
  }
}

