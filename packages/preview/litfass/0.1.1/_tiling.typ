//#import "@preview/cetz:0.4.0"
#import "themes/lib.typ": basic as theme

#let _parse-pad-arg(pad) = {
  let tmp-pad = (t: 0pt, b: 0pt, l: 0pt, r: 0pt)
  
  if type(pad) == length { 
    tmp-pad.l = pad
    tmp-pad.r = pad
    tmp-pad.t = pad
    tmp-pad.b = pad
  }
  else if pad.keys().all(x => ("t", "b", "l", "r").contains(x)) {
    for (k, v) in pad.pairs() {
      tmp-pad.insert(k, v)
    }
  } else if pad.keys().all(x => ("w", "h").contains(x)) {
    let lr = pad.at("w", default: 0pt)
    let tb = pad.at("h", default: 0pt)
    tmp-pad.l = lr
    tmp-pad.r = lr
    tmp-pad.t = tb
    tmp-pad.b = tb
  } else {
    panic("invalid padding provided")
  }

  return tmp-pad
}

#let _parse-inset-arg(inset) = {
  let tmp-inset = (:)

  if type(inset) == length {
    tmp-inset.x = inset
    tmp-inset.y = inset
  } else if inset.keys().all(x => ("x", "y").contains(x)) {
    for (k, v) in inset.pairs() {
      tmp-inset.insert(k, v)
    }
  } else {
    panic("invalid inset provided")
  }

  return tmp-inset
}

#let _deep-update-dict(dict, update-dict, handle-nested: none) = {
  if handle-nested == none {
    handle-nested = (k, v1, v2) => _deep-update-dict(v1, v2)
  }

  for (k, v) in update-dict.pairs() {
    if type(v) == dictionary {
      dict.insert(k, handle-nested(k, dict.at(k, default: (:)), v))
    } else {
      dict.insert(k, v)
    }
  }

  return dict
}

#let _update-padding(p1, p2) = {
  let _ = _parse-pad-arg(p2) // parse p2 to check for valid format (a bit hacky but it works)
  let new-p = _parse-pad-arg(p1)

  if type(p2) == length {
    _parse-pad-arg(p2)
  } 
 
  new-p.insert("l", p2.at("w", default: new-p.l))
  new-p.insert("r", p2.at("w", default: new-p.r))

  new-p.insert("t", p2.at("h", default: new-p.t))
  new-p.insert("b", p2.at("h", default: new-p.b))

  new-p.insert("t", p2.at("t", default: new-p.t))
  new-p.insert("b", p2.at("b", default: new-p.b))
  new-p.insert("l", p2.at("l", default: new-p.l))
  new-p.insert("r", p2.at("r", default: new-p.r))

  return new-p
}

#let _deep-update-theme = _deep-update-dict.with(handle-nested: (k, d1, d2) => {
  if k == "padding" {
    //return _deep-update-dict(_parse-pad-arg(d1), _parse-pad-arg(d2))
    return _update-padding(d1, d2)
  } else if k == "inset" {
    return _deep-update-dict(_parse-inset-arg(d1), _parse-inset-arg(d2))
  } else {
    return _deep-update-dict(d1, d2) 
  }
})


#let _process-cut-arg(cut, len) = {
  if type(cut) == length {
    return cut
  } else if type(cut) == ratio {
    return cut * len
  } else {
    panic("invalid cut arg of type: " + str(type(cut)))
  }
}

#let vs(..actions, cut: 50%, theme: none) = (ctx) => {
  if type(theme) == dictionary {
    ctx.theme = _deep-update-theme(ctx.theme, theme)
  } else if theme != none {
    panic("invalid theme")
  }

  let dims = ctx.dims

  let new-width-left = _process-cut-arg(cut, dims.wh.width) 

  let new-width-right = dims.wh.width - new-width-left

  let ctx1 = ctx
  ctx1.dims = (pos: dims.pos, wh: (width: new-width-left, height: dims.wh.height))

  let ctx2 = ctx
  ctx2.dims = (
    pos: (x: dims.pos.x + new-width-left, y: dims.pos.y),
    wh: (width: new-width-right, height: dims.wh.height)
  )

  return (actions.at(0)(ctx1), actions.at(1)(ctx2))
}

#let hs(..actions, cut: 50%, theme: none) = (ctx) => {
  if type(theme) == dictionary {
    ctx.theme = _deep-update-theme(ctx.theme, theme)
  } else if theme != none {
    panic("invalid theme")
  }

  let dims = ctx.dims
  let new-height-top = _process-cut-arg(cut, dims.wh.height)
  let new-height-bot = dims.wh.height - new-height-top


  let ctx-t = ctx
  ctx-t.dims =(
    pos: dims.pos, 
    wh: (width: dims.wh.width, height: new-height-top)
  )

  let ctx-b = ctx 
  ctx-b.dims = (
    pos: (x: dims.pos.x, y: dims.pos.y + new-height-top), 
    wh: (width: dims.wh.width, height: new-height-bot)
  )

  return (actions.at(0)(ctx-t), actions.at(1)(ctx-b))
}


#let blank() = (ctx) => () => {}

#let pad(padding: (t: 0pt, b: 0pt, l: 0pt, r: 0pt), action, theme: none) = (ctx) => {
  if type(theme) == dictionary {
    ctx.theme = _deep-update-theme(ctx.theme, theme)
  } else if theme != none {
    panic("invalid theme")
  }
  
  let p = _parse-pad-arg(padding)
 
  let dims = ctx.dims
  let newDims = (
    pos: (x: dims.pos.x + p.l, y: dims.pos.y + p.t),
    wh: (width: dims.wh.width - p.r - p.l, height: dims.wh.height - p.t - p.b)
  )
  ctx.dims = newDims
  return action(ctx)
}

#let box-footnote(cnt) = {
  state("box-footnotes").update(s => {
    if s == none {
      return (cnt,)
    }
    s.push(cnt)
    s
  })
  context super([#state("box-footnotes").get().len()])
}

#let cbx(cnt, title: none, theme: none) = (ctx) => {
  if type(theme) == dictionary {
    ctx.theme = _deep-update-theme(ctx.theme, theme)
  } else if theme != none {
    panic("invalid theme")
  }
  
  () => pad(padding: ctx.theme.padding, (c) => {
    (ctx.theme.p-block)(
      c,
      {
        cnt

        let footnote-cnt() = {
          if ctx.box-footnotes.get().len() > 0 {
            set par(spacing: 0.25em, justify: false, leading: 0.30em)
            set text(..ctx.theme.box.footnote.text)
            line(length: 25%)
            for (i, e) in ctx.box-footnotes.get().enumerate() {
              [#super([#(i + 1)]) #e]
              parbreak()
            }
          }
        }
        context place(
          bottom + left,
          footnote-cnt()
        )
        ctx.box-footnotes.update(())
      },
      title: title
    )
  })(ctx)
}


