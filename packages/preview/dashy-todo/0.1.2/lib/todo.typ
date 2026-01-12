#import "box-placement.typ": calculate-box-positions
#import "side-margin.typ": calculate-page-margin-box

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
        preferred-pos: text-position.y - shift-y // Where is the ideal y-position for the box?
      ))
      return boxes
    })

    let boxes = boxes.final()

    if boxes.len() > box-index { // The typst compiler will skip state updates during initial layout, leaving the list empty, leading to boxes.len() < box-index. To avoid compiler errors, we'll wait for the states to be updated before placing the boxes
      let box-positions = calculate-box-positions(boxes)

      // This place will shift the coordinate system so (0, 0) will address the top left corner of the page
      place(dx: - text-position.x, dy: - text-position.y)[
        // Retrieve the calculated position for the current box & render it
        #let box-pos = box-positions.at(box-index)
        #place(dx: page-margin-box.x, dy: box-pos.top)[#todo-box]

        // Draw the tick mark within the text
        #let line-margin = page-margin-box.x - text-position.x
        #place[#line(start: (text-position.x, text-position.y), end: (text-position.x, text-position.y + shift-y), stroke: stroke)]

        // Horizontally connect the tick mark to the position of the box
        #let box-border-x = if side == left {
          page-margin-box.width - outer-box-inset
        } else {
          page-margin-box.x + outer-box-inset
        }
        #place[#line(start: (text-position.x, text-position.y + shift-y), end: (box-border-x, text-position.y + shift-y), stroke: stroke)]

        // If the box is above or below the line, connect it vertically
        #if text-position.y + shift-y.to-absolute() < box-pos.top + outer-box-inset {
          place[#line(start: (box-border-x, text-position.y + shift-y), end: (box-border-x, box-pos.top + outer-box-inset), stroke: stroke)]
        } else if text-position.y + shift-y.to-absolute() > box-pos.bottom - outer-box-inset {
          place[#line(start: (box-border-x, text-position.y + shift-y), end: (box-border-x, box-pos.bottom - outer-box-inset), stroke: stroke)]
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
  if position == "inline" {
    inline-todo(body, stroke)
  } else {
    side-todo(body, position, stroke)
  }
}
