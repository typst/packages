#import "core/draw/participant.typ"

#let PAR-SPECIALS = ("?", "[", "]")
#let SHAPES = (
  "participant",
  "actor",
  "boundary",
  "control",
  "entity",
  "database",
  "collections",
  "queue",
  "custom"
)
#let DEFAULT-COLOR = rgb("#E2E2F0")

#let _par(
  name,
  display-name: auto,
  from-start: true,
  invisible: false,
  shape: "participant",
  color: DEFAULT-COLOR,
  line-stroke: (
    dash: "dashed",
    paint: gray.darken(40%),
    thickness: .5pt
  ),
  custom-image: none,
  show-bottom: true,
  show-top: true,
) = {
  if color == auto {
    color = DEFAULT-COLOR
  }
  return ((
    type: "par",
    draw: participant.render,
    name: name,
    display-name: if display-name == auto {name} else {display-name},
    from-start: from-start,
    invisible: invisible,
    shape: shape,
    color: color,
    line-stroke: line-stroke,
    custom-image: custom-image,
    show-bottom: show-bottom,
    show-top: show-top
  ),)
}

#let _exists(participants, name) = {
  if name in PAR-SPECIALS {
    return true
  }

  for p in participants {
    if name == p.name {
      return true
    }
  }
  return false
}
