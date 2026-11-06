#import "place-in-page-margin.typ": place-in-page-margin

#let to-string(content) = {
  if type(content) == str {
    content
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let todo(body, position: auto) = box(context {
  assert(position in (auto, left, right), message: "Can only position todo on the left or right side currently")

  let text-position = here().position()

  place-in-page-margin(cur-pos: text-position, position: position)[
    // shift the box slightly upwards for styling reasons
    #let shift-y = .5em
    #move(dy: -shift-y)[

      #box(inset: 4pt, width: 100%)[
        #box(stroke: orange, width: 100%)[
          #place(
            layout(size => (
              context {
                let cur = here().position()
                let is-left = cur.x < page.width / 2

                // defaults for right side
                let line-size = cur.x - text-position.x
                let line-x = -line-size
                let tick-x = -line-size
                // overwrites for left side
                if is-left {
                  line-size = text-position.x - cur.x - size.width
                  line-x = size.width
                  tick-x = size.width + line-size
                }

                place(line(length: line-size, start: (line-x, shift-y), stroke: orange))
                place(line(length: 4pt, start: (tick-x, shift-y), angle: -90deg, stroke: orange))
              }
            )),
          )
          // the todo message
          #box(body, inset: 0.2em)
        ]
        // invisible figure, s.t. we can reference it in the outline
        // probably depends on https://github.com/typst/typst/issues/147 for a cleaner solution
        #hide(
          box(
            height: 0pt,
            width: 0pt,
            figure(
              none,
              kind: "todo",
              supplement: [TODO],
              caption: to-string(body),
              outlined: true,
            ),
          ),
        )
      ]
    ]
  ]
})