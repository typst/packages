#import "utils.typ"
#import "store.typ": prefix, states
#import "indices.typ"
#import "animation.typ"
// This file is use to render in mark up mode [content output] only.

/// Content that are wrapped in this function will be revealed one after another.
/// -> content
#let pause(
  /// the content
  /// -> content
  body,
  /// hiding function
  /// -> function
  hider: hide,
  /// whether to update the number of pauses.
  /// -> bool
  update: true,
) = {
  context {
    animation.pause(states.get() + (auto,), hider: hider, {
      if update { states.update(s => if update { s + (auto,) } else { s + ((auto,),) }) }
      body
    })
  }
}

/// Reveal content on specific subslide, with space preserved.
/// -> content
#let uncover(
  /// indices to show the content.
  /// -> index
  ..n,
  /// the content.
  /// -> content
  body,
  /// index to start showing the content.
  /// -> index
  from: (),
  /// index to stop showing the content.
  /// -> index
  to: (),
  /// hiding function
  /// -> function
  hider: hide,
  /// whether to update the current number of pauses.
  /// -> bool
  update-pause: false,
) = {
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

/// Show content on specific subslide without preserving space.
/// -> content
#let only(
  /// indices to show the content.
  /// -> index
  ..n,
  /// the content.
  /// -> content
  body,
  /// index to start showing the content.
  /// -> index
  from: (),
  /// index to stop showing the content.
  /// -> index
  to: (),
  /// hiding function
  /// -> function
  hider: it => none,
  /// whether to update the current number of pauses.
  /// -> bool
  update-pause: false,
) = {
  uncover(..n, body, from: from, to: to, hider: hider, update-pause: update-pause)
}

/// Show the content one by one.
/// -> content
#let fragments(
  /// animation start index
  /// -> index
  start: auto,
  /// contents to be revealed.
  /// -> content
  ..bodies,
  /// hiding function
  /// -> function
  hider: hide,
  /// whether to update the current number of pauses.
  /// -> bool
  update-pause: true,
  /// whether to update the current number of pauses for each content inside.
  /// -> bool
  update-increment: true,
  /// A function wrapper that can wrap the content.
  item-wrapper: it => it,
) = {
  let bodies = bodies.pos().map(item-wrapper)
  let n = bodies.len()
  if update-pause and update-increment {
    context {
      states.update(s => s + (start,))
      let s = states.get()
      let (pauses, results: (start,)) = indices.resolve(s, start)
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

/// Transform a content by passing it to some functions.
/// -> content
#let transform(
  /// start showing index
  /// -> index
  start: auto,
  /// the content
  /// -> content
  body,
  /// the functions,
  /// -> function
  ..funcs,
  /// whether to keep the last animated result when all of the animation has been shown.
  /// -> bool
  repeat-last: true,
  /// hiding function
  /// -> function
  hider: hide,
  /// whether to update the current number of pauses.
  /// -> bool
  update-pause: true,
  /// A function to apply before the start index
  /// -> function
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
    let (pauses, results: (start,)) = indices.resolve(s, start)
    if update-pause {
      s + (start + funcs.pos().len() - 1,)
    } else {
      s + ((start + funcs.pos().len() - 1,),)
    }
  })
}

/// Alert a text to make it pop.
/// -> content
#let alert(
  /// indices to alert.
  /// -> index
  ..n,
  /// start index to alert
  /// -> index
  from: (),
  /// stop index to alert
  /// -> index
  to: (),
  /// the content
  /// -> content
  body,
  /// alerted function, default is Typst's emphasis function.
  /// -> function
  func: emph,
  /// whether to update the current number of pauses
  /// -> bool
  update-pause: false,
) = {
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

/// Workspace for creating animation by accessing Presentate's internal states. Use with the animation module.
/// ```typ
/// #render(s => ({
///   import animation: *
///   // your content
/// }, s))
/// ```
#let render(
  /// When to start showing the rendered content.
  /// -> index
  start: auto,
  /// A function that returns an array of length two consisting of the rendered content and the updated state `s`.
  /// -> function
  func,
) = {
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

/// Use with the `motion` function. Tagging the content into a group with a name for animating with `motion`'s `controls` rules.
/// -> any
#let tag(
  /// Presentate's state. Must be from `motion` workspace.
  /// -> presentate-state
  s,
  /// name of the group
  /// -> str
  name,
  /// the content 
  /// -> any 
  body,
  /// the hider used to hide the content. If this is set to `auto`, the hider will inherits from `motion` workspace. 
  /// -> function | auto 
  hider: auto,
  /// default content wrapper
  /// -> function
  func: it => it,
) = animation.tag(
  s,
  name,
  body,
  hider: hider,
  func: func,
)

/// Motion workspace. This function allows user to control the presence and modify the content of each tags directly for each subslide. 
/// ```typ
/// #motion(s => [
///   // your content with tags 
/// ], controls: (
///   .. // an array of rules indicating what to be shown
/// ))
/// ```
/// -> content
#let motion(
  // contains the tags.
  /// A function that receives Presentate's state `s` and returns a content. 
  /// -> function 
  func,
  /// This is an array of motion control.
  /// `(A, B, C)` means show `A` then `B` then `C`.
  /// `(A, (B, C), C)` means show `A`, then `B` + `C`, and then `C`.
  /// -> array
  controls: (),
  /// default hider for contents in the tags
  /// -> function
  hider: hide,
  /// start index of the animation
  /// -> index
  start: none,
  /// whether to update the pauses after the animation
  /// -> bool
  update-pause: false,
  /// whether to show the content in the tags by default
  /// -> bool
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

/// Incrementally show items in enums/lists. 
/// This animation always update the current number of pauses. 
/// -> content 
#let step-item(
  /// The list/enum. Must not contains any set/show rules. 
  /// -> enum | list
  body,
  /// start index of the animation 
  /// -> index 
  start: auto,
  /// numbering for enums. `auto` means inherting from the current style of `enum`.
  /// -> function | str
  numbering: auto,
  /// marker for lists. `auto` means inheriting from the current style of `list`.
  marker: auto,
  body-wrapper: it => it,
  label-wrapper: it => it,
  /// hider for the list/enums 
  /// -> function
  hider: hide,
  /// other styling arguments will be passed to enum/list set rules.
  /// -> any 
  ..args,
) = context {
  if body.func() != [].func() {
    panic("Styling in step-list function is not supported.")
  }

  let uncover = uncover.with(hider: hider)
  let numbering = if numbering == auto { enum.numbering }
  let marker = if marker == auto { list.marker }

  let inside-wrapper(it) = uncover(from: auto, update-pause: true, {
    // revert to default
    set enum(numbering: numbering, ..args)
    set list(marker: marker, ..args)
    body-wrapper(it)
  })

  uncover((rel: -1, to: start), [], update-pause: true)
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
  let label-cover(it) = uncover(update-pause: false, from: auto, label-wrapper(it))

  let new-marker = if type(marker) == array { marker.map(label-cover) } else { label-cover(marker) }
  let new-numbering = (..n) => label-cover(std.numbering(numbering, ..n))

  set enum(numbering: new-numbering, ..args)
  set list(marker: new-marker, ..args)

  children.sum()
}

/// Reveal the item group by group.
/// -> content 
#let reveal-item(
  /// start index of the animation 
  /// -> index 
  start: auto,
  /// numbering for enums. `auto` means inherting from the current style of `enum`.
  /// -> function | str
  numbering: auto,
  /// marker for lists. `auto` means inheriting from the current style of `list`.
  marker: auto,
  body-wrapper: it => it,
  label-wrapper: it => it,
  /// hider for the list/enums 
  /// -> function
  hider: hide,
  /// whether to show the shown list/enum items. If set to `false`, each list/enum item will be shown only once per animation. 
  /// -> bool
  accumulated: true,
  /// the enum/list 
  /// -> enum | list
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
  uncover((rel: -1, to: start), [], update-pause: true)
  display-item(..indices, bodies.sum())
}