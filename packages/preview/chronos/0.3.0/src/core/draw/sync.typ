#import "/src/core/utils.typ": get-ctx, is-elmt, set-ctx
#import "/src/cetz.typ": draw

#let render(sync) = get-ctx(ctx => {
  set-ctx(c => {
    c.sync = (
      ctx: ctx,
      bottoms: (),
      starts: (),
      start-y: ctx.y,
      align-y: ctx.y
    )
    c.in-sync = true
    return c
  })
})

#let in-sync-render(elmt) = {
  set-ctx(c => {
    c.y = c.sync.start-y
    return c
  })
  draw.hide({
    (elmt.draw)(elmt)
  })
  set-ctx(c => {
    c.sync.starts.push(c.last-drawn.start-info.y)
    c.sync.bottoms.push(c.y)
    return c
  })
}

#let render-end(sync) = get-ctx(ctx => {
  for e in sync.elmts {
    assert(is-elmt(e), message: "Sync element can only contain chronos elements, found " + repr(e))
    assert(
      e.type == "seq",
      message: "Sync element can only contain sequences, found '" + e.type + "'"
    )
  }

  set-ctx(c => {
    let new-sync = c.sync
    if new-sync.starts.len() != 0 {
      new-sync.align-y = calc.min(..new-sync.starts)
    }
    new-sync.remove("ctx")
    return c.sync.ctx + (sync: new-sync)
  })

  for (i, e) in sync.elmts.enumerate() {
    set-ctx(c => {
      let dy = c.sync.starts.at(i) - c.sync.start-y
      c.y = c.sync.align-y - dy
      return c
    })
    (e.draw)(e)
  }

  set-ctx(c => {
    let heights = c.sync.starts.zip(c.sync.bottoms).map(((s, b)) => b - s)
    c.y = c.sync.align-y + calc.min(..heights)
    c.remove("sync")
    return c
  })
})