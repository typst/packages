#import "i18n.typ": strings

#let code(
  caption: none, // content of caption bubble (string, none)
  bgcolor: rgb("#eaeaea"), // back ground color (color)
  strokecolor: auto, // frame color (color)
  hlcolor: auto, // color to use for highlighted lines (auto, color)
  width: 100%,
  radius: 3pt,
  inset: 5pt,
  numbers: false, // show line numbers (boolean)
  stepnumber: 1, // only number lines divisible by stepnumber (integer)
  numberfirstline: false, // if the firstline isn't divisible by stepnumber, force it to be numbered anyway (boolean)
  numberstyle: auto, // style function to apply to line numbers (auto, style)
  firstnumber: 1, // number of the first line (integer)
  highlight: none, // line numbers to highlight (none, array of integer)
  code_label: none,
  breakable: false,
  lang: "de",
  content,
) = {
  let translations = strings(lang)
  show figure.where(kind: "listing"): set block(breakable: breakable)
  if hlcolor == auto {
    hlcolor = bgcolor.darken(10%)
  }
  if highlight == none {
    highlight = ()
  }
  if numberstyle == auto {
    numberstyle = text.with(
      style: "italic",
      slashed-zero: false,
    )
  }
  let final_strokecolor = if strokecolor == auto {
    0.5pt + bgcolor.darken(20%)
  } else {
    strokecolor
  }
  let line_count = content.text.split("\n").len()
  let last_number = firstnumber + line_count - 1
  let code_block = block(
    width: width,
    fill: bgcolor,
    stroke: final_strokecolor,
    radius: radius,
    inset: inset,
    clip: false,
    {
      set par(justify: false)
      set align(left)
      context {
        let outer-font = text.font
        let number = n => text(font: outer-font, numberstyle(str(n)))
        let numwidth = if numbers {
          measure(number(last_number)).width
        } else {
          0pt
        }
        let space-width = measure(raw(lang: content.lang, " ")).width
        show raw.line: it => {
          let n = it.number - 1 + firstnumber
          let show_number = numbers and (
            calc.rem(n, stepnumber) == 0 or (numberfirstline and it.number == 1)
          )
          let bg = if n in highlight { hlcolor } else { none }
          let m = it.text.match(regex("^ +"))
          let indent_chars = if m != none { m.text.len() } else { 0 }
          let body = par(hanging-indent: indent_chars * space-width, it.body)
          box(width: 100%, fill: bg, outset: (y: 2pt), {
            if numbers {
              grid(
                columns: (numwidth, 1fr),
                column-gutter: .5em,
                align(right, if show_number {
                  number(n)
                } else {
                  none
                }),
                body,
              )
            } else {
              body
            }
          })
        }
        raw(lang: content.lang, content.text)
      }
    },
  )
  let fig = figure(
    code_block,
    caption: caption,
    kind: "listing",
    supplement: translations.listing-supplement,
  )
  
  if code_label != none [
    #fig #label(code_label)
  ] else {
    fig
  }
}
