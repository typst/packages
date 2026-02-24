#import "state.typ": *

#let whitespaces = (
  "\u{0009}", // Tab
  "\u{000B}", // Vertical Tab
  "\u{000C}", // Form Feed
  "\u{0020}", // Space
  "\u{00A0}", // No-break Space
  "\u{FEFF}", // Zero Width No-break Space
)
#let whitespace-regex = regex("[" + whitespaces.join() + "]")


/// Render a single indentation marker (vertical line)
#let indentation-render-marker(config) = {
  if config.fast-preview {
    set text(fill: gray.transparentize(50%))
    "|"
  } else if config.height != none {
    let line-end-y = if config.hanging-indent {
      config.height - config.inset.top
    } else {
      config.line-height + config.inset.bottom
    }

    place(
      std.line(
        start: (0em, -config.inset.top),
        end: (0em, line-end-y),
        stroke: .05em + gray.transparentize(50%),
      ),
      left + top,
    )
    " "
  } else {
    " "
  }
}

/// Process indentation and add vertical guide lines
#let indentation-format(indent-str, config) = {
  if config.indentation <= 0 { return indent-str }

  // Process each leading space in the indentation string
  let len = indent-str.len()
  let processed = ""

  let breakpoint = -1
  for i in range(len) {
    // Add vertical line for each position that is a multiple of the indentation
    if calc.rem(i, config.indentation) == 0 and indent-str.at(i) == " " {
      processed += box(indentation-render-marker(config))
    } else if indent-str.at(i) != " " {
      breakpoint = i
      break
    } else {
      processed += indent-str.at(i)
    }
  }

  // Add remaining non-space characters
  if breakpoint != -1 {
    for i in range(breakpoint, len) {
      processed += indent-str.at(i)
    }
  }

  processed
}

/// Render a code line with indentation processing
#let indentation-render-line(line, height, hanging-indent, indentation, inset, fast-preview) = {
  let line-height = measure("|").height

  let config = (
    height: height,
    line-height: line-height,
    indentation: indentation,
    inset: inset,
    fast-preview: fast-preview,
    hanging-indent: hanging-indent,
  )

  // Only process indentation when it exists
  if hanging-indent {
    grid(
      columns: 2,
      indentation-format(line.indentation, config), line.body,
    )
  } else {
    if line.keys().contains("indentation") {
      indentation-format(line.indentation, config)
    }
    line.body
  }
}

/// Extract indentation string from line text
#let indentation-extract-from-text(text) = {
  let leading-whitespace = ""
  for c in text {
    if whitespaces.contains(c) {
      if c == "\u{FEFF}" {
        // Ignore zero width no-break space
      } else if c == "\u{00A0}" or c == " " {
        leading-whitespace += " "
      } else {
        leading-whitespace += c
      }
    } else {
      break
    }
  }
  leading-whitespace
}
