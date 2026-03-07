#import "/src/consts.typ": *
#import "/src/core/utils.typ": get-ctx, set-ctx

#let render(evt) = get-ctx(ctx => {
  let par-name = evt.participant
  let i = ctx.pars-i.at(par-name)
  let par = ctx.participants.at(i)
  let line = ctx.lifelines.at(i)
  let entry = (evt.event, ctx.y)

  if evt.event == "disable" {
    line.level -= 1
  } else if evt.event == "enable" {
    line.level += 1
    entry.push(evt.lifeline-style)
  } else if evt.event == "create" {
    ctx.y -= CREATE-OFFSET
    entry.at(1) = ctx.y
    (par.draw)(par, y: ctx.y)
  } else if evt.event == "destroy" {
  } else {
    panic("Unknown event '" + evt.event + "'")
  }

  line.lines.push(entry)
  set-ctx(c => {
    c.lifelines.at(i) = line
    c.y = ctx.y
    return c
  })
})