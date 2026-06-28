#import "common/format.typ": format-date

#let resolve-title-sub(title-sub, info, dict) = if type(title-sub) == content {
  title-sub
} else if type(title-sub) == function {
  title-sub(info, dict)
} else {
  panic("title-sub has unsupported type. Expected content, function or none. Got " + type(title-sub))
}

#let tuda-make-title(
  inner_page_margin_top,
  title_rule,
  accent_color,
  on_accent_color,
  text_color,
  colorback,
  logo_element,
  logo_height,
  info,
  title-sub,
  dict
) = {
  let text_on_accent_color = if colorback {
    on_accent_color
  } else {
    text_color
  }

  let text_inset = if colorback {
    (x:3mm)
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

  box(
    fill: if colorback {accent_color}, 
    width: 100%,
    outset: 0pt,
    {
      // line creates a paragraph spacing
      set par(spacing: 4pt)
      v(logo_height / 2)
      grid(
        columns: (1fr, auto),
        box(inset: (y:3mm),{
          set text(font: "Roboto", weight: "bold", size: 12pt)
          grid(row-gutter: 1em,
            inset: text_inset,
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
            }
          )

          v(.5em)
        }
        ),
        { 
          if logo_element != none {
            move(
              dx: 6mm,
              {
                set image(height: logo_height)
                logo_element
              }
            )
          }
        }
      )
      v(6pt)
      line(length: 100%, stroke: stroke)
      if title-sub != none {
        block(
          inset: text_inset,
          resolve-title-sub(title-sub, info, dict)
        )
        line(length: 100%, stroke: stroke)
      }
    }
  )
}