#import "utils.typ"
#import "store.typ": is-kind, prefix, states
#import "indices.typ"
#import "animation.typ"
/// This file is use to render in mark up mode [content output] only.

#let pause(body, hider: hide, update: true) = {
  context {
    animation.pause(states.get() + (auto,), hider: hider, {
      if update { states.update(s => if update { s + (auto,) } else { s + ((auto,),) }) }
      body
    })
  }
}

#let uncover(..n, body, from: (), to: (), hider: hide, update-pause: false) = {
  context {
    states.update(s => {
      let n = n.pos()
      if update-pause {
        s + (..n, from, to)
      } else {
        s + ((..n, from, to),)
      }
    })
    animation.uncover(states.get(), ..n, hider: hider, from: from, to: to, {
      body
    })
  }
}

#let only(..n, body, from: (), to: (), hider: it => none, update-pause: false) = {
  uncover(..n, body, from: from, to: to, hider: hider, update-pause: update-pause)
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

        animation.uncover(s, from: start + i, body, hider: hider)
      }
    }
  } else {
    context {
      animation.fragments(states.get(), start: start, ..bodies, hider: hider, item-wrapper: item-wrapper)
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

#let transform(
  start: auto,
  body,
  ..funcs,
  repeat-last: true,
  hider: hide,
  update-pause: true,
  before-func: hide,
) = {
  context animation.transform(
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

#let alert(..n, from: (), to: (), body, func: emph, update-pause: false) = {
  let kwargs = n.named()
  let n = n.pos()
  if n.len() == 0 {
    n = (auto,)
  }
  context {
    states.update(s => {
      if update-pause {
        s + (..n, from, to)
      } else {
        s + ((..n, from, to),)
      }
    })
    animation.alert(states.get(), ..n, body, from: from, to: to, func: func)
  }
}

#let render(start: auto, func) = {
  states.update(s => s + (start,))
  // func must return two things: display content and updated states.
  assert(
    type(func) == function,
    message: "`render` accepts only a function that returns an array of length two consisting of body and updated states.",
  )

  context {
    let result = func(states.get())

    let message = "Returning value from the render function must be an array of length 2: one for the content, and the other for updated states."

    assert(type(result) == array, message: message)
    assert(result.len() == 2, message: message)
    assert(
      type(result.at(-1)) == array and type(result.at(-1).at(0)) == dictionary,
      message: "Invalid State Modification. The state `s` is an array of indices. You must update the array with the array methods.",
    )
    result.at(0)
  }

  states.update(s => func(s).at(-1, default: s))
}

#let tag = animation.tag

#let motion(
  // contains the tags.
  func,
  /// This is an array of motion control.
  /// (A, B, C) means show A then B then C.
  /// (A, (B, C), C) means shown A, then B + C, and then C.
  controls: (),
  hider: hide,
  start: none,
  update-pause: false,
  is-shown: false,
) = {
  let n = controls.len()
  if n == 0 { n = 1 }
  context {
    states.update(s => {
      if update-pause {
        s + (start,) + (auto,) * (n - 1)
      } else {
        s + ((start,) + (auto,) * (n - 1),)
      }
    })
    animation.motion(
      states.get(),
      func,
      controls: controls,
      hider: hider,
      start: start,
      is-shown: is-shown,
    )
  }
}

#let display-item(
  numbering: auto,
  marker: auto,
  body-wrapper: it => it,
  label-wrapper: it => it,
  // default hider
  hider: hide,
  // arguments and indices
  ..args,
  body,
) = context {
  if body.func() != [].func() {
    panic("Styling in step-list function is not supported.")
  }

  let styles = args.named()
  let indices = args.pos()
  let numbering = if numbering == auto { enum.numbering }
  let marker = if marker == auto { list.marker }
  let uncover = uncover.with(hider: hider)
  let covers = indices.map(i => {
    if type(i) not in (array, dictionary) { i = (i,) }
    uncover.with(..i)
  })

  let children = body.children
  let items = children.filter(i => i not in ([], [ ], parbreak()))
  let is-tight = children.any(c => c == parbreak())
  let n-child = children.len()
  let n-covers = covers.len()
  if n-covers < n-child {
    // default cover is pause.
    if covers == () { covers = (uncover.with(from: auto),) * n-child } else {
      // broadcast the last function.
      covers += (n-child - n-covers) * (covers.last(),)
    }
  }

  covers = covers.map(f => f.with(update-pause: false))
  let cover-state = state(prefix + "_step-item-cover-state", ())
  cover-state.update(c => c + (covers,))

  let inside-wrapper(it, func) = func(body-wrapper({
    // revert to default
    set enum(numbering: numbering, ..styles)
    set list(marker: marker, ..styles)
    it
  }))

  // parse the items
  let result = ()
  for (item, cover) in items.zip(covers) {
    cover = cover.with(update-pause: true)
    if item.func() == enum.item {
      let fields = item.fields()
      let body = item.body
      let number = fields.at("number", default: auto)
      if number == auto {
        result.push(enum.item(inside-wrapper(body, cover)))
      } else {
        result.push(enum.item(number, inside-wrapper(body, cover)))
      }
    } else if item.func() == list.item {
      let body = item.body
      result.push(list.item(inside-wrapper(body, cover)))
    } else { result.push(item) }
  }
  if is-tight { result.insert(1, parbreak()) }

  // HACK: a function that makes enum and list markers react to states.
  let react(it) = label-wrapper({
    context {
      let func = cover-state.get().last().first()
      func(it)
    }
    cover-state.update(c => {
      let _ = c.last().remove(0)
      return c
    })
  })

  let new-marker = if type(marker) == array { marker.map(react) } else { react(marker) }
  let new-numbering = (..n) => react(std.numbering(numbering, ..n))

  set enum(numbering: new-numbering, ..styles)
  set list(marker: new-marker, ..styles)

  result.sum()
  cover-state.update(c => {
    let _ = c.pop()
    c
  })
}


#let step-item(
  body,
  numbering: auto,
  marker: auto,
  body-wrapper: it => it,
  marker-wrapper: it => it,
  hider: hide,
  ..args,
) = context {
  if body.func() != [].func() {
    panic("Styling in step-list function is not supported.")
  }

  let pause = pause.with(hider: hider)

  let numbering = if numbering == auto { enum.numbering }
  let marker = if marker == auto { list.marker }

  let inside-wrapper(it) = pause({
    // revert to default
    set enum(numbering: numbering, ..args)
    set list(marker: marker, ..args)
    body-wrapper(it)
  })

  let children = body.children.map(i => {
    if i.func() == enum.item {
      let fields = i.fields()
      let body = i.body
      let number = fields.at("number", default: auto)
      if number == auto {
        enum.item(inside-wrapper(body))
      } else {
        enum.item(number, inside-wrapper(body))
      }
    } else if i.func() == list.item {
      let body = i.body
      list.item(inside-wrapper(body))
    } else { i }
  })
  let label-cover(it) = pause(update: false, marker-wrapper(it))

  let new-marker = if type(marker) == array { marker.map(label-cover) } else { label-cover(marker) }
  let new-numbering = (..n) => label-cover(std.numbering(numbering, ..n))

  set enum(numbering: new-numbering, ..args)
  set list(marker: new-marker, ..args)

  children.sum()
}

#let reveal-item(
  marker: auto,
  numbering: auto,
  body-wrapper: it => it,
  label-wrapper: it => it,
  hider: hide,
  accumulated: true,
  ..args,
) = context {
  let bodies = args.pos()
  assert(
    bodies.all(body => body.func() == [].func()),
    message: "Styling in `step-item` function is not supported.",
  )

  let indices = ()
  for body in bodies {
    let children = body.children
    let items = children.filter(c => c not in ([], [ ], parbreak()))
    if accumulated {
      indices += ((from: auto),) + ((from: none),) * (items.len() - 1)
    } else {
      indices += (auto,) + (none,) * (items.len() - 1)
    }
  }
  return display-item(..indices, bodies.sum())
}
