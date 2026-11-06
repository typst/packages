#import "common/format.typ": format-date

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
  dict
) = {
  let text_on_accent_color = if colorback {
    on_accent_color
  } else {
    text_color
  }

  let text_inset = if colorback {
    (left:3mm)
  } else {
    ()
  }

  let stroke_color = if colorback {
    black
  } else {
    text_color
  }

  let stroke = (paint: stroke_color, thickness: title_rule / 2)

  v(-inner_page_margin_top + 0.2mm) // would else draw over header

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
          set text(font: "Roboto", weight: "bold", size: 12pt, fill: text_on_accent_color)
          grid(row-gutter: 1em,
            inset: text_inset,
            if info.title != none {
              text(info.title, size: 20pt)
            },
            if info.subtitle != none {
              info.subtitle
            },
            if info.author != none {
              if type(info.author) == array {
                for author in info.author {
                   author
                   linebreak()
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
      if info.term != none or info.date != none or info.sheetnumber != none {
        set text(fill: text_on_accent_color)
        grid(
          inset: text_inset,
          row-gutter: 0.4em,
          if info.term != none {
              info.term
          },
          if info.date != none {
            if type(info.date) == datetime {
              format-date(info.date, dict.locale)
            } else {
              info.date
            }
          },
          if info.sheetnumber != none {
            dict.sheet + " " + str(info.sheetnumber)
          }
        )
        line(length: 100%, stroke: stroke)
      }
    }
  )
}