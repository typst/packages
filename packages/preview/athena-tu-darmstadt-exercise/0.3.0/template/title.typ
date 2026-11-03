#import "common/format.typ": format-date

#let title-info-keys = ("title", "header_title", "subtitle", "author")

#let resolve-info-layout(info-layout, info, dict) = if type(info-layout) == content {
  info-layout
} else if type(info-layout) == function {
  info-layout(info, dict)
} else {
  panic("info-layout has unsupported type. Expected content, function or none. Got " + type(info-layout))
}

#let tuda-make-title(
  inner_page_margin_top,
  title_rule,
  accent_color,
  on_accent_color,
  text_color,
  colorback,
  logo_element,
  sublogo_element,
  logo_height,
  info,
  info-layout,
  dict,
) = {
  let text_on_accent_color = if colorback {
    on_accent_color
  } else {
    text_color
  }

  let text_inset = if colorback {
    (x: 3mm)
  } else {
    (:)
  }

  let stroke_color = if colorback {
    black
  } else {
    text_color
  }

  let stroke = (paint: stroke_color, thickness: title_rule / 2)

  v(-inner_page_margin_top + 0.2mm) // would else draw over header

  set text(fill: text_on_accent_color)

  block(
    fill: if colorback { accent_color },
    width: 100%,
    outset: 0pt,
    {
      // line creates a paragraph spacing
      set par(spacing: 4pt)
      v(logo_height / 2)
      grid(
        columns: (1fr, auto),
        align: (auto, right),
        pad(y: 3mm, {
          set text(font: "Roboto", weight: "bold", size: 12pt)
          grid(
            row-gutter: 1em,
            inset: text_inset,
            ..(
              if "title" in info {
                text(info.title, size: 20pt)
              },
              if "subtitle" in info {
                info.subtitle
              },
              if "author" in info {
                if type(info.author) == array {
                  for author in info.author {
                    if type(author) == array {
                      [#author.at(0)
                        #text(weight: "regular", size: 0.8em)[(Mat.: #author.at(1))]]
                      linebreak()
                    } else {
                      author
                      linebreak()
                    }
                  }
                } else {
                  info.author
                }
              },
            ).filter(x => x != none)
          )

          v(.5em)
        }),
        {
          if logo_element != none {
            move(
              dx: 6mm,
              {
                set image(height: logo_height)
                logo_element
              },
            )
          }
          if sublogo_element != none {
            // 2/3 is from the tudapub example
            set image(height: logo_height * 2 / 3)
            sublogo_element
          }
        },
      )
      v(6pt)
      line(length: 100%, stroke: stroke)
      if info-layout != none and info.keys().any(x => not x in title-info-keys) {
        block(
          inset: text_inset,
          resolve-info-layout(info-layout, info, dict),
        )
        line(length: 100%, stroke: stroke)
      }
    },
  )
}
