#import "utils.typ"
#import "store.typ"
#import "freeze_counters.typ": default-frozen-counters


// animations
#let sequence = [].func()
#let style = [#set text(fill: red)].func()
// update marker
#let update-pause(s) = {
  s.pause += 1
  s.steps = calc.max(s.pause, s.steps)
  return s
}

#let update-meanwhile(s) = {
  s.pause = 1
  return s
}

#let is-kind(it, kind) = {
  if it.func() == metadata and type(it.value) == dictionary and "kind" in it.value.keys() {
    it.value.kind == store.prefix + kind
  } else { false }
}

#let pause = metadata((kind: store.prefix + "pause"))

#let meanwhile = metadata((kind: store.prefix + "meanwhile"))


// show content based on its environment. Idea from Polylux 0.3.*
#let paused-content(i, body, hider: hide) = context {
  if store.pauses(i).get() <= i or store.settings.get().handout {
    body
  } else {
    hider(body)
  }
}

#let conditional-display(
  ..args,
  from: auto,
  hider: it => none,
  marker: it => it,
  combine: (it, mark) => it + mark,
) = {
  let n = store.subslides.get()
  let (..idx, body) = args.pos()

  let cond = (
    n in idx or if type(from) == int { n >= from } else { false } or store.settings.get().handout
  )

  let output = if cond { body } else { hider(body) }

  if type(from) != int { from = 0 }

  let updater(s) = {
    s.steps = calc.max(s.pause, s.steps, ..idx, from)
    return s
  }
  combine(output, marker(store.dynamics.update(updater)))
}

#let only(..args) = { conditional-display(hider: it => none, ..args) }

#let uncover(..args) = { conditional-display(hider: hide, ..args) }

#let blink(
  body,
  cover: hide,
  clear: it => none,
  update-pause: true,
  marker: auto,
  reserve-space: true,
) = {
  let n = store.subslides.get()
  hider = if not reserve-space { clear } else if reserve-space {
    cover
  }
  if store.subslides.get() == store.dynamics.get().pause {
    body
  } else {
    hider(body)
  }
  //marker = get-option-if-auto(marker, "marker")
  if update-pause {
    marker(pause)
  }
}

#let step-transform(
  ..args,
  start: auto,
  update-pause: false,
  repeat-last: true,
  hider: it => none,
  marker: it => it,
  reserve-space: true,
  align: center,
) = {
  let n = store.subslides.get()
  let start-idx = if start == auto { store.dynamics.get().pause } else if type(start) == int {
    start
  } else { panic("start must be an integer.") }

  let bodies = args.pos()
  let kwargs = args.named()
  let last-idx = start-idx + bodies.len()

  //hider = get-option-if-auto(hider, "clear")

  let wrapper = if reserve-space {
    let w = calc.max(..bodies.map(body => measure(body).width))
    it => box(width: w, std.align(align, it))
  } else { it => it }

  // for space reservation, not wobbling around.
  wrapper(for (i, body) in bodies.enumerate() {
    let curr-idx = start-idx + i + 1
    if (
      curr-idx == n
        or if repeat-last {
          i == bodies.len() - 1 and n >= last-idx
        } else {
          false
        }
    ) {
      body
    } else {
      hider(body)
    }
  })

  let updater
  if not update-pause {
    updater = s => {
      if start == auto {
        let start = s.pause
      }
      s.steps = calc.max(start + bodies.len(), s.steps)
      return s
    }
  } else {
    updater = s => {
      if start == auto {
        let start = s.pause
      }
      s.pause = start + bodies.len()
      s.steps = calc.max(start + bodies.len(), s.steps)
      return s
    }
  }

  marker(store.dynamics.update(updater))
}

#let animate(cover: hide, clear: it => none, marker: it => it, combine: (it, mark) => it + mark) = (
  only: only.with(hider: clear, marker: marker, combine: combine),
  uncover: uncover.with(hider: cover, marker: marker, combine: combine),
  // blink: blink.with(cover: cover, clear: clear, marker: marker),
  // step-transform: step-transform.with(hider: clear, marker: marker),
)

// Ideas from Touying.
// These reconstruction functions work because of the label.
// show rule for sequence.children
#let reconstruct-sequence(i, it) = {
  let fields = it.fields()
  let children = fields.remove("children")
  if it.has("label") and it.label == label("_presentate_elem") {
    it
  } else {
    if it.has("label") {
      let _ = fields.remove("label")
    }
    let new-children = children.map(c => {
      if (
        c.func()
          in (
            enum.item,
            list.item,
            terms.item,
            linebreak,
            parbreak,
            block,
            box,
            par,
            sequence,
            style,
            metadata,
          )
          or c in (pause, meanwhile, [ ], [])
      ) { c } else {
        paused-content(i, c)
      }
    })
    [#(it.func())(new-children)<_presentate_elem>]
  }
}

#let reducer(func: it => it, cover: hide, ..args) = {
  let kwargs = args.named()
  let args = args.pos()
  metadata((kind: store.prefix + "reducer", func: func, kwargs: kwargs, args: args, cover: cover))
}

#let reconstruct-reducer(subslide, func: (..args) => none, kwargs: (:), args: (), cover: hide) = {
  context {
    let curr-pause = store.pauses(subslide).get()
    let meta-marks = ()
    let new-args = ()

    for arg in args {
      if arg == pause {
        curr-pause += 1
        continue
      }

      if arg == meanwhile {
        curr-pause = 1
        continue
      }

      if type(arg) == content and arg.func() == state(".").update(1).func() {
        continue
      }

      if curr-pause <= subslide {
        new-args.push(arg)
      } else {
        new-args.push(cover(arg))
      }
    }
    func(..kwargs, ..new-args)
  }
  let marks = args
    .filter(it => {
      type(it) == content
    })
    .join()
  marks
}


#let pdfpc-slide-markers(i) = context [
  #metadata((t: "NewSlide")) <pdfpc>
  #metadata((t: "Idx", v: here().page())) <pdfpc>
  #metadata((t: "Overlay", v: i - 1)) <pdfpc>
  #metadata((t: "LogicalSlide", v: counter(page).get().first())) <pdfpc>
]
