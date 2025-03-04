#import "settings.typ": BUBBLE_COLORS as BC, FONT_SIZE, PAGE_MARGIN_OUTER

#let bubble(
  text-color: rgb("#975E10"),
  fill: rgb("#FFEFD6"),
  stroke: rgb("#F9D9AD"),
  body,
) = {
  let inset = 1.2em
  set text(fill: text-color)
  block(
    breakable: false,
    width: 100%,
    figure(
      kind: "todo",
      supplement: [TODO],
      block(
        inset: inset,
        width: 100%,
        radius: 4pt,
        stroke: 1pt + stroke,
        fill: fill,
        grid(
          columns: (48pt, 1fr),
          column-gutter: inset,
          align(
            center + horizon,
            image.decode(
              width: 60%,
              read("assets/warning.svg").replace("black", text-color.to-hex()),
            ),
          ),
          align(left + horizon, body),
        ),
      ),
    ),
  )
}

#let todo(body) = {
  bubble(
    text-color: BC.todo.text,
    fill: BC.todo.fill,
    stroke: BC.todo.stroke,
    body,
  )
}

#let info(body) = {
  bubble(
    text-color: BC.info.text,
    fill: BC.info.fill,
    stroke: BC.info.stroke,
    body,
  )
}

#let warn(body) = {
  bubble(
    text-color: BC.warn.text,
    fill: BC.warn.fill,
    stroke: BC.warn.stroke,
    body,
  )
}

#let inline(body) = {
  set text(fill: BC.todo.text)
  let outset = 2pt
  box(
    layout(page-size => {
      let page-width = page-size.width
      box(
        figure(
          kind: "todo",
          supplement: [TODO],
          context {
            let outset = 2pt
            let hint-height = 4pt
            let text_dimensions = measure(box(body))
            let height = text_dimensions.height + outset * 2
            let width = text_dimensions.width + outset * 2
            let x-position = here().position().x
            place(
              dy: -outset,
              dx: -x-position,
              polygon(
                fill: BC.todo.stroke,
                (0pt, height),
                (0pt, 0pt),
                (PAGE_MARGIN_OUTER - 1em, 0pt),
                (PAGE_MARGIN_OUTER - 0.5em, height / 2),
                (PAGE_MARGIN_OUTER - 1em, height),
              ),
            )
            h(outset)
            box(
              width: width,
              height: text_dimensions.height,
              {
                place(
                  dy: -outset,
                  polygon(
                    fill: BC.todo.fill,
                    (0pt, height),
                    (0pt, 0pt),
                    (width, 0pt),
                    (width, height),
                  ),
                )
                place(dy: 0pt, dx: outset, box(body))
              },
            )
            h(outset)
          },
        ),
      )
    }),
  )
}
