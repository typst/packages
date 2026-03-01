#import "core/draw/delay.typ"
#import "core/draw/event.typ": render as evt-render
#import "core/draw/separator.typ"
#import "core/draw/sync.typ"
#import "core/utils.typ": set-ctx

#let _sep(name) = {
  return ((
    type: "sep",
    draw: separator.render,
    name: name
  ),)
}

#let _delay(name: none, size: 30) = {
  return ((
    type: "delay",
    draw: delay.render,
    name: name,
    size: size
  ),)
}

#let _sync(elmts) = {
  return ((
    type: "sync",
    draw: sync.render,
    elmts: elmts
  ),)
}

#let gap-render(gap) = set-ctx(ctx => {
  ctx.y -= gap.size
  return ctx
})

#let _gap(size: 20) = {
  return ((
    type: "gap",
    draw: gap-render,
    size: size
  ),)
}

#let _evt(participant, event, lifeline-style: auto) = {
  return ((
    type: "evt",
    draw: evt-render,
    participant: participant,
    event: event,
    lifeline-style: lifeline-style
  ),)
}

#let _col(p1, p2, width: auto, margin: 0, min-width: 0, max-width: none) = {
  return ((
    type: "col",
    p1: p1,
    p2: p2,
    width: width,
    margin: margin,
    min-width: min-width,
    max-width: max-width
  ),)
}