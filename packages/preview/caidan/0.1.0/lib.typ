#import "nord.typ": *

#let en_text(size, body, fill: nord3, style: "italic") = text(
  font: "Ysabeau Infant",
  size: size,
  style: style,
  fill: fill,
  weight: "light",
)[#body]

#let zh_text(size, body, fill: nord0) = text(
  font: "LXGW Wenkai",
  size: size,
  fill: fill,
  weight: "light",
)[#body]

#let cuisine(name_zh, name_en) = align(center)[
  #v(.5em)
  #zh_text(16pt)[#name_zh] \ #en_text(10pt)[#name_en]
  #v(.3em)
]

#let item(name_zh, name_en) = box[
  #zh_text(14pt)[#name_zh #h(1fr)] \
  #v(-.7em)#h(.14em)#en_text(10pt)[#name_en]#v(.3em)
]

#let caidan(
  title: none,
  cover_image: none,
  update_date: none,
  page_height: 595.28pt,
  page_width: 841.89pt,
  num_columns: 3,
  body,
) = {
  let frame_font_size = 40pt
  let frame_format = c => text(
    c,
    font: "WebOMints GD",
    size: frame_font_size,
    fill: nord3,
  )

  let frame = (
    chars: ([E], [F], [G], [H]),
    dx: 1em,
    dy: 2em,
  )

  let dx = (1, -1, 1, -1)
  let dy = (1, 1, -1, -1)
  let border_x = (left, right, left, right)
  let border_y = (top, top, bottom, bottom)

  let column_width = page_width / num_columns

  let frame_vert_line = line(
    length: page_height - 2 * (frame.dy + frame_font_size),
    angle: 90deg,
    stroke: 1pt + nord3,
  )
  let frame_vert_line_dy = frame.dy + frame_font_size + .5em

  let frame_horiz_line = line(
    length: column_width - 2 * (frame.dx + frame_font_size) - .6em,
    stroke: 1pt + nord3,
  )
  let frame_horiz_line_dx = frame.dx + frame_font_size + .3em

  let separator_vert_line = line(
    length: page_height,
    angle: 90deg,
    stroke: (paint: nord0, thickness: .5pt, dash: "dashed"),
  )

  set page(
    fill: nord6,
    height: page_height,
    width: page_width,
    margin: (x: frame.dx + 2em, y: frame.dy + 4em),
    background: [
      // separator lines
      #for i in range(num_columns - 1) {
        place(
          top + left,
          dx: (i + 1) * column_width,
          separator_vert_line,
        )
      }
      
      // frame
      #for i in range(num_columns) {
        let offset_xl = i * column_width
        let offset_xr = (num_columns - i - 1) * column_width

        // frame characters
        for j in range(4) {
          place(
            border_x.at(j) + border_y.at(j),
            dx: dx.at(j) * (offset_xl + frame.dx),
            dy: dy.at(j) * frame.dy,
            frame_format(frame.chars.at(j)),
          )
        }

        // left frame line
        place(
          top + left,
          dx: offset_xl + frame.dx + 7pt,
          dy: frame_vert_line_dy,
          frame_vert_line,
        )

        // right frame line
        place(
          top + right,
          dx: -(offset_xr + 2 * frame.dx) + 4pt,
          dy: frame_vert_line_dy,
          frame_vert_line,
        )

        // top frame line
        place(
          top + left,
          dx: offset_xl + frame_horiz_line_dx,
          dy: frame.dy + 4pt,
          frame_horiz_line,
        )

        // bottom frame line
        place(
          bottom + left,
          dx: offset_xl + frame_horiz_line_dx,
          dy: -frame.dy + 4pt,
          frame_horiz_line,
        )

        // page numbering
        place(
          bottom + left,
          dx: offset_xl + 0.5 * column_width,
          dy: -frame.dy - 1em,
          context {
            let num = (counter(page).get().at(0) - 1) * 3 + i
            if num != 0 {
              en_text(10pt, style: "normal")[#numbering("I", num)]
            }
          },
        )
      }
    ],
  )

  let title_page = context {
    set align(center)
    let title_content = {
      title
      if cover_image != none {
        v(3em)
        let img_width = measure(cover_image).width
        let max_img_width = column_width - 2 * frame.dx - 6em
        if img_width.pt() > max_img_width.abs.pt() {
          set image(width: column_width - 2 * frame.dx - 6em)
          cover_image
        } else {
          cover_image
        }
      }
      if update_date != none {
        v(5em)
        zh_text(10pt)[
          更新于：#update_date.display("[year]年[month padding:none]月[day padding:none]日") ]
        linebreak()
        en_text(8pt)[
          Updated on #update_date.display("[month repr:long] [day], [year]")]
      }
    }
    let text_dy = (
      page_height - measure(title_content).height
    ) / 2 - frame.dy - 2em
    if title != none or cover_image != none or update_date != none {
      v(text_dy)
      title_content
    }
  }

  set list(marker: [#v(.7em)#en_text(16pt, fill: nord3)[☐]])
  columns(
    num_columns,
    gutter: frame.dx * 2 + 4em,
  )[#title_page #colbreak(weak: true) #body]
}
