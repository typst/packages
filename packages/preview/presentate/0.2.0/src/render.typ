#import "utils.typ"
#import "store.typ": states
#import "indices.typ"
#import "animation.typ" as a
/// This file is use to render in mark up mode [content output] only.

#let pause(body, hider: hide, update: true) = {
  if update { states.update(s => if update { s + (auto,) } else { s + ((auto,),) }) }
  context a.pause(states.get(), body, hider: hider)
}

#let uncover(..n, body, from: (), to: (), hider: hide, update-pause: false) = {
  context a.uncover(states.get(), ..n, body, hider: hider, from: from, to: to)
  states.update(s => {
    let n = n.pos()
    if update-pause {
      s + (..n, from, to)
    } else {
      s + ((..n, from, to),)
    }
  })
}

#let only(..n, body, from: (), to: (), hider: it => none, update-pause: false) = {
  context a.only(states.get(), ..n, body, hider: hider, from: from, to: to)
  states.update(s => {
    let n = n.pos()
    if update-pause {
      s + (..n, from, to)
    } else {
      s + ((..n, from, to),)
    }
  })
}

#let fragments(
  start: auto,
  ..bodies,
  hider: hide,
  update-pause: true,
  update-increment: true,
  item-wrapper: it => it,
) = {
  let bodies = bodies.pos().map(item-wrapper)
  let n = bodies.len()
  if update-pause and update-increment {
    context {
      states.update(s => s + (start,))
      let s = states.get()
      let (pauses, results: (start,)) = indices.resolve-indices(s, start)
      for (i, body) in bodies.enumerate() {
        if i > 0 { states.update(s => s + (auto,)) }

        a.uncover(s, from: start + i, body, hider: hider)
      }
    }
  } else {
    context {
      a.fragments(states.get(), start: start, ..bodies, hider: hider, item-wrapper: item-wrapper)
    }
    states.update(s => {
      if update-pause {
        s + (start,) + (auto,) * (n - 1)
      } else {
        s + ((start,) + (auto,) * (n - 1),)
      }
    })
  }
}
}

#let transform(start: auto, body, ..funcs, repeat-last: true, hider: hide, update-pause: true, before-func: hide) = {
  context a.transform(
    states.get(),
    start: start,
    body,
    ..funcs,
    hider: hider,
    before-func: before-func,
    repeat-last: repeat-last,
  )
  states.update(s => {
    let (pauses, results: (start,)) = indices.resolve-indices(s, start)
    if update-pause {
      s + (start + funcs.pos().len() - 1,)
    } else {
      s + ((start + funcs.pos().len() - 1,),)
    }
  })
}

#let alert(..n, from: auto, to: (), body, func: emph, update-pause: false) = {
  context a.alert(states.get(), ..n, body, from: from, to: to, func: func)
  states.update(s => {
    let n = n.pos()
    if update-pause {
      s + (..n, from, to)
    } else {
      s + ((..n, from, to),)
    }
  })
}

#let render(start: auto, func) = {
  states.update(s => s + (start,))
  // func must return two things: display content and updated states.
  context {
    let result = func(states.get())

    assert(
      type(func) == function,
      message: "`render` accepts only a function that returns an array of length two consisting of body and updated states.",
    )

    let message = "Returning value from the render function must be an array of length 2: one for the content, and the other for updated states."

    assert(type(result) == array, message: message)
    assert(result.len() == 2, message: message)
    result.at(0)
  }
  states.update(s => func(s).at(-1, default: s))
}
