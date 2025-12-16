#import "utils.typ"
#import "store.typ"
#import "indices.typ"

// show only when the number of pauses are less than or equal to the subslide number.
#let pause(s, body, hider: it => none) = {
  let (info, ..idx) = s
  let (pauses,) = indices.resolve-indices(s)
  if pauses <= info.subslide or info.handout {
    body
  } else { hider(body) }
}


#let uncover(s, ..n, body, hider: hide, from: (), to: ()) = {
  let (info, ..x) = s
  let (pauses, results: (..n)) = indices.resolve-indices(s, ..n)

  //  Show only when the subslides are in the specified indices, or in the range of from-to.
  // Minideck's original
  let logic(i) = {
    if i in n { return true }
    let tmp = ()
    if from != () { tmp.push(from) } else if to != () {
      panic("`from` must be specified in order to use `to`.")
    }
    if to != () { tmp.push(to) }

    let (results: tmp) = indices.resolve-indices(s, ..tmp)

    if tmp.len() == 1 {
      let (from,) = tmp
      return i >= from
    } else if tmp.len() == 2 {
      let (from, to) = tmp
      return from <= i and i <= to
    } else {
      false
    }
  }
  if logic(info.subslide) or info.handout {
    body
  } else { hider(body) }
}

#let only(s, ..n, body, hider: it => none, from: (), to: ()) = {
  uncover(s, ..n, body, hider: hider, from: from, to: to)
}



#let fragments(
  s,
  start: auto,
  ..bodies,
  hider: it => none,
  reveal-step: false,
  repeat-last: true,
  item-wrapper: it => it,
) = {
  let (info, ..x) = s
  let (results: (start,)) = indices.resolve-indices(s, start)
  bodies = bodies.pos().map(item-wrapper)
  let last-index = if not repeat-last { start + bodies.len() - 1 } else { () }

  // Very similar idea to Polylux's one-by-one and friends.
  for (i, v) in bodies.enumerate() {
    if reveal-step {
      uncover(s, start + i, v, hider: hider)
    } else {
      uncover(s, from: start + i, to: last-index, v, hider: hider)
    }
  }
}

#let transform(
  s,
  start: auto,
  body,
  ..funcs,
  before-func: it => none,
  repeat-last: true,
  hider: it => none,
) = {
  let (info, ..x) = s
  let (results: (start,)) = indices.resolve-indices(s, start)
  funcs = funcs
    .pos()
    .map(f => {
      if type(f) != function { x => f } else { f }
    })
  let last-index = start + funcs.len()

  if info.subslide < start {
    before-func(body)
  } else if info.subslide < last-index {
    (funcs.at(info.subslide - start))(body)
  } else {
    if repeat-last { (funcs.last())(body) } else { hider(body) }
  }
}

#let alert(s, ..n, from: auto, to: (), body, func: emph) = {
  let (info, ..x) = s
  if info.handout {
    func = it => it
  }
  uncover(s, ..n, func(body), hider: it => body, from: from, to: to)
}

// Modify the function so that it can react to the state variable `s`
// Default behaviour is like `pause`
#let animate(
  ..funcs,
  wrapper: pause,
  hider: it => none,
  modifier: none, // if it is not `none` then it must be `(func, ..args) => ..`
) = {
  funcs
    .pos()
    .map(func => (s, ..args) => {
      if type(s) != array or type(s.at(0, default: none)) != dictionary {
        panic(
          "Did you forget to put the state `s` in the argument of the function `"
            + repr(func)
            + "` ?",
        )
      }
      wrapper(
        s,
        hider: {
          if modifier != none {
            // modifier will replace `hider` if it is specified.
            it => modifier(func, ..args)
          } else { hider }
        },
        func(..args),
      )
    })
}

#let settings(hider: it => none, start: auto) = {
  (
    pause: pause.with(hider: hider),
    uncover: uncover.with(hider: hider),
    fragments: fragments.with(start: start, hider: hider),
    transform: transform.with(hider: hider, start: start),
  )
}

// Touying and Polylux's Idea.
#let pdfpc-slide-markers(i) = context [
  #let (info, ..x) = store.states.get()
  #if not info.logical-slide { info.add-page-index += 1 }
  #metadata((t: "NewSlide")) <pdfpc>
  #metadata((t: "Idx", v: here().page() - 1)) <pdfpc>
  #metadata((t: "Overlay", v: i - 1)) <pdfpc>
  #metadata((t: "LogicalSlide", v: counter(page).get().first() + info.add-page-index)) <pdfpc>
]

