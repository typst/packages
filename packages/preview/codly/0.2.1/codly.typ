#let __codly-enabled = state("codly-enabled", false)
#let __codly-offset = state("codly-offset", 0)
#let __codly-range = state("codly-range", none)
#let __codly-languages = state("codly-languages", (:))
#let __codly-display-names = state("codly-display-names", true)
#let __codly-display-icons = state("codly-display-icons", true)
#let __codly-default-color = state("codly-default-color", rgb("#283593"))
#let __codly-radius = state("codly-radius", 0.32em)
#let __codly-padding = state("codly-padding", 0.32em)
#let __codly-fill = state("codly-fill", white)
#let __codly-zebra-color = state("codly-zebra-color", luma(240))
#let __codly-stroke-width = state("codly-stroke-width", none)
#let __codly-stroke-color = state("codly-stroke-color", luma(240))
#let __codly-numbers-format = state("codly-numbers-format", text)
#let __codly-breakable = state("codly-breakable", true)
#let __codly-enable-numbers = state("codly-enable-numbers", true)

// Default language-block style
#let default-language-block(name, icon, color, loc) = {
  let radius = __codly-radius.at(loc)
  let padding = __codly-padding.at(loc)
  let stroke-width = __codly-stroke-width.at(loc)
  let color = if color == none { __codly-default-color.at(loc) } else { color }
  box(
    radius: radius,
    fill: color.lighten(60%),
    inset: padding,
    stroke: stroke-width + color,
    outset: 0pt,
    icon + name,
  )
}

#let __codly-language-block = state("codly-language-block", default-language-block)

// Lets you set a line number offset.
#let codly-offset(offset: 0) = {
  __codly-offset.update(offset)
}

// Lets you set a range of line numbers to highlight.
#let codly-range(
  start: 1,
  end: none,
) = {
  __codly-range.update((start, end))
}

// Disables codly.
#let disable-codly() = {
  __codly-enabled.update(false)
}

// Configures codly.
#let codly(
  // The list of languages, allows setting a display name and an icon,
  // it should be a dict of the form:
  //  `<language-name>: (name: <display-name>, icon: <icon-content>, color: <color>)`
  languages: none,

  // Whether to display the language name.
  display-name: none,

  // Whether to display the language icon.
  display-icon: none,

  // The default color for a language not in the list.
  // Only used if `display-icon` or `display-name` is `true`.
  default-color: none,

  // Radius of a code block.
  radius: none,

  // Padding of a code block.
  padding: none,

  // Fill color of lines.
  // If zebra color is enabled, this is just for odd lines.
  fill: none,

  // The zebra color to use or `none` to disable.
  zebra-color: none,

  // The stroke width to use to surround the code block.
  // Set to `none` to disable.
  stroke-width: none,

  // The stroke color to use to surround the code block.
  stroke-color: none,

  // Whether to enable line numbers.
  enable-numbers: none,

  // Format of the line numbers.
  // This is a function applied to the text of every line number.
  numbers-format: none,

  // A function that takes 3 positional parameters:
  // - name
  // - icon
  // - color
  // It returns the content for the language block.
  language-block: none,

  // Whether this code block is breakable.
  breakable: none,
) = {
  // Enable codly
  __codly-enabled.update(true)

  if languages != none {
    assert(type(languages) == type((:)), message: "codly: `languages` must be a dict")
    __codly-languages.update(languages)
  }

  if display-name != none {
    assert(type(display-name) == bool, message: "codly: `display-name` must be a dict")
    __codly-display-names.update(display-name)
  }

  if display-icon != none {
    assert(type(display-icon) == bool, message: "codly: `display-icon` must be a dict")
    __codly-display-icons.update(display-icon)
  }

  if default-color != none {
    assert(
      type(default-color) == color
        or type(default-color) == gradient
        or type(default-color) == pattern,
      message: "codly: `default-color` must be a color or a gradient or a pattern"
    )
    __codly-default-color.update(default-color)
  }

  if radius != none {
    assert(
      type(radius) == type(1pt + 0.32em),
      message: "codly: `radius` must be a length"
    )
    __codly-radius.update(radius)
  }

  if padding != none {
    assert(
      type(padding) == type(1pt + 0.32em),
      message: "codly: `padding` must be a length"
    )
    __codly-padding.update(padding)
  }

  if fill != none {
    assert(
      type(fill) == color
        or type(fill) == gradient
        or type(fill) == pattern,
      message: "codly: `fill` must be a color or a gradient or a pattern"
    )
    __codly-fill.update(fill)
  }

  if zebra-color != none {
    assert(
      zebra-color == none
        or type(zebra-color) == color
        or type(zebra-color) == gradient
        or type(zebra-color) == pattern,
      message: "codly: `zebra-color` must be none, a color, a gradient, or a pattern"
    )
    __codly-zebra-color.update(zebra-color)
  }

  if stroke-width != none {
    assert(
      type(stroke-width) == type(1pt + 0.1em),
      message: "codly: `stroke-width` must be a length"
    )
    __codly-stroke-width.update(stroke-width)
  }

  if stroke-color != none {
    assert(
      stroke-color == none
        or type(stroke-color) == color
        or type(stroke-color) == gradient
        or type(stroke-color) == pattern,
      message: "codly: `stroke-color` must be none, a color, a gradient, or a pattern"
    )
    __codly-stroke-color.update(stroke-color)
  }

  if enable-numbers != none {
    assert(
      type(enable-numbers) == bool,
      message: "codly: `enable-numbers` must be a bool"
    )
    __codly-enable-numbers.update(enable-numbers)
  }

  if numbers-format != none {
    assert(
      type(numbers-format) == function,
      message: "codly: `numbers-format` must be a function"
    )
    __codly-numbers-format.update((_) => numbers-format)
  }

  if breakable != none {
    assert(
      type(breakable) == bool,
      message: "codly: `breakable` must be a bool"
    )
    __codly-breakable.update(breakable)
  }

  if language-block != none {
    assert(
      type(language-block) == function,
      message: "codly: `language-block` must be a function"
    )
    __codly-language-block.update(language-block)
  }
}

#let codly-init(
  body,
) = {
  show raw.where(block: true): it => locate(loc => {
    let range = __codly-range.at(loc)
    let in_range(line) = {
      if range == none {
        true
      } else if range.at(1) == none {
        line >= range.at(0)
      } else {
        line >= range.at(0) and line <= range.at(1)
      }
    }
    if __codly-enabled.at(loc) != true {
      return it
    }

    let languages = __codly-languages.at(loc)
    let display-names = __codly-display-names.at(loc)
    let display-icons = __codly-display-icons.at(loc)
    let language-block = __codly-language-block.at(loc)
    let default-color = __codly-default-color.at(loc)
    let radius = __codly-radius.at(loc)
    let offset = __codly-offset.at(loc)
    let stroke-width = __codly-stroke-width.at(loc)
    let stroke-color = __codly-stroke-color.at(loc)
    let zebra-color = __codly-zebra-color.at(loc)
    let numbers-format = __codly-numbers-format.at(loc)
    let padding = __codly-padding.at(loc)
    let breakable = __codly-breakable.at(loc)
    let fill = __codly-fill.at(loc)
    let enable-numbers = __codly-enable-numbers.at(loc)

    let start = if range == none { 1 } else { range.at(0) };

    let stroke = if stroke-width == 0pt or stroke-width == none or stroke-color == none {
      none
    } else {
      stroke-width + stroke-color
    };

    let items = ()
    for (i, line) in it.lines.enumerate() {
      if not in_range(line.number) {
        continue
      }

      // Always push the formatted line number
      if enable-numbers {
        items.push(numbers-format(str(line.number + offset)))
      }

      // The language block (icon + name)
      let language-block = if line.number != start or display-names != true and display-icons != true {
        items.push(line)
        continue
      } else if it.lang == none {
        items.push(line)
        continue
      } else if it.lang in languages {
        let lang = languages.at(it.lang);
        let name = if display-names {
          lang.name
        } else {
          []
        }
        let icon = if display-icons {
          lang.icon
        } else {
          []
        }
        (language-block)(name, icon, lang.color, loc)
      } else if display-names {
        (language-block)(it.lang, [], default-color, loc)
      }

      // Push the line and the language block in a grid for alignment
      items.push(style(styles => grid(
        columns: (1fr, measure(language-block, styles).width + 2 * padding),
        line,
        place(right + horizon, language-block),
      )))
    }

    block(
      breakable: breakable,
      clip: true,
      width: 100%,
      radius: radius,
      stroke: stroke-color + stroke-width,
      if enable-numbers {
        table(
          columns: (auto, 1fr),
          inset: padding * 1.5,
          stroke: none,
          align: left + horizon,
          fill: (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
            zebra-color
          } else {
            fill
          },
          ..items,
        )
      } else {
        table(
          columns: (1fr,),
          inset: padding * 1.5,
          stroke: none,
          align: left + horizon,
          fill: (x, y) => if zebra-color != none and calc.rem(y, 2) == 0 {
            zebra-color
          } else {
            fill
          },
          ..items,
        )
      }
    )

    codly-offset()
    codly-range(start: 1, end: none)
  })

  body
}
