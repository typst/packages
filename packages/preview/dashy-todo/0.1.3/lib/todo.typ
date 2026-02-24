#import "box-placement.typ": calculate-box-positions
#import "side-margin.typ": calculate-page-margin-box

// set to true for additional debugging output
#let debug = false
#let debug-only(body) = { if debug { body } }

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

#let outline-entry(body) = {
  // invisible figure, s.t. we can reference it in the outline
  // probably depends on https://github.com/typst/typst/issues/147 for a cleaner solution
  hide(
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
}

#let inline-todo(body, stroke) = {
  box(stroke: stroke, width: 100%, inset: 4pt)[#body]
  outline-entry(body)
}

#let side-todo(body, position, stroke) = {
  box(context {
    let text-position = here().position()

    let side = position
    if position == auto {
      if text-position.x > page.width / 2 {
        side = right
      } else {
        side = left
      }
    }

    let page-margin-box = calculate-page-margin-box(side)
    let shift-y = .5em
    let outer-box-inset = 4pt

    // Create the todo box. It will later be measured to determine it's location
    let todo-box = box(inset: outer-box-inset, width: page-margin-box.width)[
      #box(stroke: stroke, width: 100%)[
        #box(body, inset: 0.2em)
        #outline-entry(body)
      ]
    ]

    // Create a state that accumulates all the todo box sizes of the current page
    // There are two states per page. One for the boxes on the left, one for the boxes on the right
    let boxes = state("dashy-todo-page-" + str(here().page()) + "-" + repr(side) + "-boxes", ())

    let box-size = measure(todo-box)

    // Register the box in the state and determine the index of the box within the state. This index will later be used to retrieve the final position for the box.
    let box-index = boxes.get().len()
    boxes.update(boxes => {
      boxes.push((
        height: box-size.height, // Height of the box in pt, including margins
        preferred-pos: text-position.y - shift-y, // Where is the ideal y-position for the box?
      ))
      return boxes
    })

    let boxes = boxes.final()

    if boxes.len() > box-index {
      // The typst compiler will skip state updates during initial layout, leaving the list empty, leading to boxes.len() < box-index. To avoid compiler errors, we'll wait for the states to be updated before placing the boxes
      let box-positions = calculate-box-positions(boxes)

      // This place will shift the coordinate system so (0, 0) will address the top left corner of the page
      place(dx: -text-position.x, dy: -text-position.y)[
        // Retrieve the calculated position for the current box & render it
        #let box-pos = box-positions.at(box-index)
        #let box-dx = if text.dir == ltr or text.dir == auto { page-margin-box.x } else {
          page-margin-box.x + page-margin-box.width
        }
        #place(dx: box-dx, dy: box-pos.top)[#todo-box]

        // for debugging output, set debug = true at the top of this file
        #let debug-dx-margin = if text.dir == ltr or text.dir == auto { page-margin-box.x } else {
          page-margin-box.x + page-margin-box.width
        }
        #debug-only(place(
          dx: debug-dx-margin,
          dy: page-margin-box.y,
          rect(
            width: page-margin-box.width,
            height: page-margin-box.height,
            stroke: (thickness: 1pt, paint: gray, dash: "dashed"),
          ),
        ))
        #let debug-line-dx = if text.dir == ltr or text.dir == auto { 0pt } else { page.width }
        #debug-only(place(dx: debug-line-dx, dy: box-pos.top, line(start: (0pt, 0pt), end: (page.width, 0pt), stroke: (
          thickness: 1pt,
          paint: blue,
          dash: "dotted",
        ))))
        #debug-only(place(dx: debug-line-dx, dy: box-pos.bottom, line(
          end: (page.width, 0pt),
          stroke: (
            thickness: 1pt,
            paint: blue,
            dash: "dotted",
          ),
        )))
        #let debug-circle-dx = if text.dir == ltr or text.dir == auto { -4pt } else { 4pt }
        #debug-only(place(
          dx: text-position.x + debug-circle-dx,
          dy: text-position.y - 4pt,
          circle(radius: 4pt, stroke: (thickness: 0.5pt, paint: blue)),
        ))

        // Draw the tick mark within the text
        #place(dx: text-position.x, dy: text-position.y)[#line(
          length: shift-y,
          angle: 90deg,
          stroke: stroke,
        )]

        // Horizontally connect the tick mark to the position of the box
        #let distance-tick-to-box-x = if side == left {
          text-position.x - page-margin-box.width + outer-box-inset
        } else {
          page-margin-box.x - text-position.x + outer-box-inset
        }
        #let tick-to-box-line-dx = if text.dir == ltr or text.dir == auto {
          if side == left { text-position.x - distance-tick-to-box-x } else { text-position.x }
        } else {
          if side == left { text-position.x } else { text-position.x + distance-tick-to-box-x }
        }

        #place(dx: tick-to-box-line-dx, dy: text-position.y + shift-y, line(
          length: distance-tick-to-box-x,
          stroke: stroke,
        ))

        // If the box is above or below the line, connect it vertically
        #let box-border-x = if side == left {
          page-margin-box.x + page-margin-box.width - outer-box-inset
        } else {
          page-margin-box.x + outer-box-inset
        }
        #if text-position.y + shift-y.to-absolute() < box-pos.top + outer-box-inset {
          place(dx: box-border-x)[#line(
            start: (0pt, text-position.y + shift-y),
            end: (0pt, box-pos.top + outer-box-inset),
            stroke: stroke,
          )]
        } else if text-position.y + shift-y.to-absolute() > box-pos.bottom - outer-box-inset {
          place(dx: box-border-x)[#line(
            start: (0pt, text-position.y + shift-y),
            end: (0pt, box-pos.bottom - outer-box-inset),
            stroke: stroke,
          )]
        }
      ]
    }
  })
}

#let todo(body, position: auto, stroke: orange) = {
  assert(
    position in (auto, left, right, "inline"),
    message: "Can only position todo either inline, or on the left or right side.",
  )
  // do not influence line numbering
  set par.line(numbering: none)
  if position == "inline" {
    inline-todo(body, stroke)
  } else {
    side-todo(body, position, stroke)
  }
}
