// Lets you set a line number offset.
#let codly-offset(offset: 0) = {
  state("codly-offset").update(offset)
}

// Lets you set a range of line numbers to highlight.
#let codly-range(
  start: 1,
  end: none,
) = {
  state("codly-range").update((start, end))
}

// Disables codly.
#let disable-codly() = {
  state("codly-config").update(none)
}

// Configures codly.
#let codly(
  // The list of languages, allows setting a display name and an icon,
  // it should be a dict of the form:
  //  `<language-name>: (name: <display-name>, icon: <icon-content>, color: <color>)`
  languages: (:),

  // Whether to display the language name.
  display-name: true,

  // Whether to display the language icon.
  display-icon: true,

  // The default color for a language not in the list.
  // Only used if `display-icon` or `display-name` is `true`.
  default-color: rgb("#283593"),

  // Radius of a code block.
  radius: 0.32em,

  // Padding of a code block.
  padding: 0.32em,

  // The zebra color to use or `none` to disable.
  zebra-color: luma(240),

  // The stroke width to use to surround the code block.
  // Set to `none` to disable.
  stroke-width: 0.1em,

  // The stroke color to use to surround the code block.
  stroke-color: luma(240),

  // The width of the numbers column.
  // If set to `none`, the numbers column will be disabled.
  width-numbers: 2em,

  // Whether this code block is breakable.
  breakable: true,
) = locate(loc => {
  let old = state("codly-config").at(loc);
  if old == none {
    state("codly-config").update((
      languages: languages,
      display-name: display-name,
      display-icon: display-icon,
      default-color: default-color,
      radius: radius,
      padding: padding,
      zebra-color: zebra-color,
      stroke-width: stroke-width,
      width-numbers: width-numbers,
      breakable: breakable,
      stroke-color: stroke-color,
    ))
  } else {
    let folded_langs = old.languages;
    for (lang, def) in languages {
      folded_langs.insert(lang, def)
    }

    state("codly-config").update((
      languages: folded_langs,
      display-name: display-name,
      display-icon: display-icon,
      default-color: default-color,
      radius: radius,
      padding: padding,
      zebra-color: zebra-color,
      stroke-width: stroke-width,
      width-numbers: width-numbers,
      breakable: breakable,
      stroke-color: stroke-color,
    ))
  }
})

#let codly-init(
  body,
) = {
  show raw.where(block: true): it => locate(loc => {
    let config = state("codly-config").at(loc)
    let range = state("codly-range").at(loc)
    let in_range(line) = {
      if range == none {
        true
      } else if range.at(1) == none {
        line >= range.at(0)
      } else {
        line >= range.at(0) and line <= range.at(1)
      }
    }
    if config == none {
      return it
    }
    let language_block = if config.display-name == false and config.display-icon == false {
      none
    } else if it.lang == none {
      none
    } else if it.lang in config.languages {
      let lang =config. languages.at(it.lang);
      let content = if config.display-name == true and config.display-icon == true {
        lang.icon + lang.name
      } else if config.display-name == true {
        lang.name
      } else {
        lang.icon
      };

      style(styles => {
        let height = measure(content, styles).height
        box(
          radius: config.radius, 
          fill: lang.color.lighten(60%), 
          inset: config.padding,
          height: height + config.padding * 2,
          stroke: config.stroke-width + lang.color,
          content,
        )
      })
    } else {
      if config.display-name == false {
        style(styles => {
          let height = measure(it.lang, styles).height
          box(
            radius: config.radius, 
            fill: config.default-color.lighten(60%), 
            inset: config.padding,
            height: height + padding * 2,
            stroke: config.stroke-width + config.default-color,
            it.lang,
          )
        })
      } else {
        none
      }
    };

    let offset = state("codly-offset").at(loc);
    let start = if range == none { 1 } else { range.at(0) };
    let border(i, len) = {
      let end = if range == none { len } else if range.at(1) == none { len } else { range.at(1) };

      let stroke-width = if config.stroke-width == none { 0pt } else { config.stroke-width };
      let radii = (:)
      let stroke = (x: config.stroke-color + stroke-width)

      if i == start {
        radii.insert("top-left", config.radius)
        radii.insert("top-right", config.radius)
        stroke.insert("top", config.stroke-color + stroke-width)
      }

      if i == end {
        radii.insert("bottom-left", config.radius)
        radii.insert("bottom-right", config.radius)
        stroke.insert("bottom", config.stroke-color + stroke-width)
      }

      radii.insert("rest", 0pt)

      (radius: radii, stroke: stroke)
    }

    let width = if config.width-numbers == none { 0pt } else { config.width-numbers }
    show raw.line: it => if not in_range(it.number) {
      none
    } else {
      block(
        width: 100%,
        height: 1.2em + config.padding * 2,
        inset: (left: config.padding + width, top: config.padding + 0.1em, rest: config.padding),
        fill: if calc.rem(it.number, 2) == 0 {
          config.zebra-color
        } else {
          white
        },
        radius: border(it.number, it.count).radius,
        stroke: border(it.number, it.count).stroke,
        {
          if it.number == start  {
            place(
              top + right,
              language_block,
              dy: -config.padding * 0.66666,
              dx: config.padding * 0.66666 - 0.1em,
            )
          }

          set par(justify: false)
          if config.width-numbers != none {
            place(
              top + left,
              dx: -config.width-numbers, 
              [#(offset + it.number)]
            )
          }
          it
        }
      )
    }

    let stroke = if config.stroke-width == 0pt or config.stroke-width == none {
      none
    } else {
      config.stroke-width + config.zebra-color
    };

    block(
      breakable: config.breakable,
      clip: false,
      width: 100%,
      stack(dir: ttb, ..it.lines)
    )

    codly-offset()
    codly-range(start: 1, end: none)
  })

  body
}