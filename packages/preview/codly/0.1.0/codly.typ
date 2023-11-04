// Lets you set a line number offset.
#let codly-offset(offset: 0) = {
  state("codly-offset").update(offset)
}

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

  // The width of the numbers column.
  // If set to `none`, the numbers column will be disabled.
  width-numbers: 2em,

  // Whether this code block is breakable.
  breakable: true,

  body,
) = {
  show raw.where(block: true): it => {
    let language_block = if display-name == false and display-icon == false {
      none
    } else if it.lang == none {
      none
    } else if it.lang in languages {
      let lang = languages.at(it.lang);
      let content = if display-name == true and display-icon == true {
        lang.icon + " " + lang.name
      } else if display-name == true {
        lang.name
      } else {
        lang.icon
      };

      style(styles => {
        let height = measure(content, styles).height
        box(
          radius: radius, 
          fill: lang.color.lighten(60%), 
          inset: padding,
          height: height + padding * 2,
          stroke: stroke-width + lang.color,
          content,
        )
      })
    } else {
      if display-name == false {
        style(styles => {
          let height = measure(it.lang, styles).height
          box(
            radius: radius, 
            fill: default-color.lighten(60%), 
            inset: padding,
            height: height + padding * 2,
            stroke: stroke-width + default-color,
            it.lang,
          )
        })
      } else {
        none
      }
    };

    let border(i, len) = {
      let stroke-width = if stroke-width == none { 0pt } else { stroke-width }
      let radii = (:)
      let stroke = (x: zebra-color + stroke-width)

      if i == 1 {
        radii.insert("top-left", radius)
        radii.insert("top-right", radius)
        stroke.insert("top", zebra-color + stroke-width)
      }

      if i == len {
        radii.insert("bottom-left", radius)
        radii.insert("bottom-right", radius)
        stroke.insert("bottom", zebra-color + stroke-width)
      }

      radii.insert("rest", 0pt)

      (radius: radii, stroke: stroke)
    }

    let width = if width-numbers == none { 0pt } else { width-numbers }
    show raw.line: it => block(
      width: 100%,
      height: 1.2em + padding * 2,
      inset: (left: padding + width, top: padding + 0.1em, rest: padding),
      fill: if calc.rem(it.number, 2) == 0 {
        zebra-color
      } else {
        white
      },
      radius: border(it.number, it.count).radius,
      stroke: border(it.number, it.count).stroke,
      {
        if it.number == 1 {
          place(
            top + right,
            language_block,
            dy: -padding * 0.66666,
            dx: padding * 0.66666 - 0.1em,
          )
        }

        set par(justify: false)
        if width-numbers != none {
          place(top + left, dx: -width-numbers, locate(loc => {
            (state("codly-offset").at(loc) + it.number)
          }))
        }
        it
      }
    )

    let stroke = if stroke-width == 0pt or stroke-width == none {
      none
    } else {
      stroke-width + zebra-color
    };

    block(
      breakable: breakable,
      clip: false,
      width: 100%,
      stack(dir: ttb, ..it.lines)
    )

    codly-offset()
  }

  body
}