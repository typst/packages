#import "core/draw/event.typ": render as evt-render
#import "core/renderer.typ": render
#import "core/setup.typ": setup
#import "core/utils.typ": fit-canvas, set-ctx

#let diagram(elements, width: auto) = {
  if elements == none {
    return
  }
  
  let (elmts, participants) = setup(elements)

  let canvas = render(participants, elmts)
  fit-canvas(canvas, width: width)
}

#let from-plantuml(code) = {
  let code = code.text
}