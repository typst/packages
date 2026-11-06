#import "utils.typ"
#import "store.typ": is-kind, prefix, states
#import "indices.typ"
#import "animation.typ" as a
/// This file is use to render in mark up mode [content output] only.

#let pause(body, hider: hide, update: true) = {
  context {
    a.pause(states.get() + (auto,), hider: hider, {
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
    a.uncover(states.get(), ..n, hider: hider, from: from, to: to, {
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

#let transform(
  start: auto,
  body,
  ..funcs,
  repeat-last: true,
  hider: hide,
  update-pause: true,
  before-func: hide,
) = {
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

#let alert(..n, from: (), to: (), body, func: emph, update-pause: false) = {
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

#let step-item(
  body,
  numbering: auto,
  marker: auto,
  body-wrapper: it => it,
  marker-wrapper: it => it,
  ..args,
) = context {
  if body.func() != [].func() {
    panic("Styling in step-list function is not supported.")
  }

  let numbering = if numbering == auto { enum.numbering }
  let marker = if marker == auto { list.marker }

  let inside-wrapper = it => pause({
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
  let cover = it => pause(update: false, marker-wrapper(it))

  let new-marker = if type(marker) == array { marker.map(cover) } else { cover(marker) }
  let new-numbering = (..n) => cover(std.numbering(numbering, ..n))

  set enum(numbering: new-numbering, ..args)
  set list(marker: new-marker, ..args)

  children.sum()
}

#let next = metadata((kind: prefix + "_next-marker"))

#let make-cover(..funcs, modifier: (func, ..args) => func(..args)) = {
  funcs
    .pos()
    .map(func => {
      (..args) => metadata((
        kind: prefix + "_cover",
        func: func,
        modifier: modifier,
        args: arguments(..args),
      ))
    })
}

#let parser(
  arr,
  hider: it => none,
  start: auto,
  func: (arr, ..args) => arr.sum(),
  ..args,
  mapper: it => it,
) = {
  states.update(s => s + (start,))
  context {
    let s = states.get()
    let (info, ..x) = s
    let internal-s = ()
    let result = ()
    for elem in arr {
      if is-kind(elem, "_cover") {
        let (func, modifier, args) = elem.value
        result.push(mapper(a.pause(s, hider: it => modifier(func, ..args), func(..args))))
      } else if is-kind(elem, "_next-marker") {
        internal-s.push(auto)
        s.push(auto)
      } else {
        result.push(a.pause(s, hider: hider, mapper(elem)))
      }
    }
    states.update(s => s + internal-s)
    func(result, ..args)
  }
}

