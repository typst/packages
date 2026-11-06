#import "utils.typ"
#import "store.typ": prefix
#import "element.typ" as element: applier, getter, updater
#import "indices.typ"
#import "animation.typ"

#let jump(idx, hider: auto, mode: "content") = updater(mode: mode, s => {
  s.push(idx)
  let (pauses,) = indices.resolve(s)
  if hider != auto { s.at(0).pause-state.hider = hider }
  s.at(0).hidden-leader = "pause"
  s.at(0).pause-state.hidden = pauses > s.at(0).subslide
  return s
})

#let pause = jump(auto)

#let meanwhile = jump(1)

#let marker(name, mode: "content", at: none) = updater(mode: mode, s => {
  s + ((name: name, at: at),)
})


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
  hider: auto,
  /// whether to update the current number of pauses.
  /// -> bool
  update: false,
  /// mode of using this function
  /// -> "content" | "array"
  mode: "content",
) = applier(
  {
    updater(mode: mode, s => {
      // Detect whether the content inside is shown or not
      let shown-state = animation.uncover(s, ..n, hider: hider, from: from, to: to, body, _return-state: true)
      s.at(0).uncover-state.hidden = not shown-state
      s.at(0).hidden-leader = "uncover"
      // Update state
      let n = n.pos()
      if update {
        s + (..n, from, to)
      } else {
        s + ((..n, from, to),)
      }
    })
    body
    // Revert hidden hierachy
    updater(mode: mode, s => {
      s.at(0).hidden-leader = "pause"
      s
    })
  },
  mode: mode,
  contextual: true,
  hidable: false,
  (s, body) => animation.uncover(s, ..n, hider: hider, from: from, to: to, body),
)

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
  update: false,
  /// mode of using this function
  /// -> "content" | "array"
  mode: "content",
) = uncover(..n, body, from: from, to: to, hider: hider, update: update, mode: mode)

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
  update: true,
  /// whether to update the current number of pauses for each content inside.
  /// -> bool
  update-increment: true,
  /// A function wrapper that can wrap the content.
  item-wrapper: it => it,
  /// mode of using this function
  /// -> "content" | "array"
  mode: "content",
) = {
  let bodies = bodies.pos().map(item-wrapper)
  let n = bodies.len()
  if update and update-increment {
    for (i, body) in bodies.enumerate() {
      if i == 0 {
        uncover(from: start, body, hider: hider, update: update, mode: mode)
      } else {
        uncover(from: auto, body, hider: hider, update: update, mode: mode)
      }
    }
  } else {
    applier(
      mode: mode,
      template: element.collect,
      contexual: true,
      {
        updater(mode: "array", s => {
          let shown-state = animation
            .fragments(s, start: start, ..bodies, hider: hider, item-wrapper: item-wrapper, _return-state: true)
            .any(it => it)
          s.at(0).uncover-state.hidden = not shown-state
          s.at(0).hidden-leader = "uncover"
          s
        })
        bodies
        updater(mode: "array", s => {
          s.at(0).hidden-leader = "pause"
          if update {
            s + (start,) + (auto,) * (n - 1)
          } else {
            s + ((start,) + (auto,) * (n - 1),)
          }
        })
      },
      (s, ..children) => { animation.fragments(s, start: start, ..bodies, hider: hider, item-wrapper: item-wrapper) },
    )
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
  update: true,
  /// mode of using this function
  /// -> "content" | "array"
  mode: "content",
) = {
  applier(
    mode: mode,
    contextual: true,
    {
      updater(mode: mode, s => {
        let shown-state = animation.transform(
          s,
          start: start,
          body,
          ..funcs,
          hider: hider,
          repeat-last: repeat-last,
          _return-state: true,
        )
        s.at(0).uncover-state.hidden = not shown-state
        s.at(0).hidden-leader = "uncover"
        if update {
          s + ((to: start, rel: funcs.pos().len() - 1),)
        } else {
          s + (((to: start, rel: funcs.pos().len() - 1),),)
        }
      })
      body
      updater(mode: mode, s => {
        s.at(0).hidden-leader = "pause"
        s
      })
    },
    (s, body) => animation.transform(
      s,
      start: start,
      body,
      ..funcs,
      hider: hider,
      repeat-last: repeat-last,
    ),
  )
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
  update: false,
  /// mode of using this function
  /// -> "content" | "array"
  mode: "content",
) = {
  let kwargs = n.named()
  let n = n.pos()
  if n.len() == 0 {
    n = (auto,)
  }
  applier(
    mode: mode,
    contextual: true,
    {
      updater(mode: mode, s => {
        if update {
          s + (..n, from, to)
        } else {
          s + ((..n, from, to),)
        }
      })
      body
    },
    (s, body) => { animation.alert(s, ..n, body, from: from, to: to, func: func) },
  )
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
  let mode = "content" // Forced content mode...
  // func must return two things: display content and updated states.
  assert(
    type(func) == function,
    message: "`render` accepts only a function that returns an array of length two consisting of body and updated states.",
  )

  updater(mode: mode, s => s + (start,))
  getter(mode: mode, s => {
    let result = func(s)

    let message = "Returning value from the render function must be an array of length 2: one for the content, and the other for updated states."

    assert(type(result) == array, message: message)
    assert(result.len() == 2, message: message)
    assert(
      type(result.at(-1)) == array and type(result.at(-1).at(0)) == dictionary,
      message: "Invalid State Modification. The state `s` is an array of indices. You must update the array with the array methods.",
    )

    result.first()
  })
  updater(mode: mode, s => func(s).at(-1, default: s))
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
  update: false,
  /// whether to show the content in the tags by default
  /// -> bool
  is-shown: false,
  mode: "content",
) = {
  let n = controls.len()
  if n == 0 { n = 1 }

  applier(
    mode: mode,
    contextual: true,
    {
      updater(mode: mode, s => {
        if update {
          s + (start,) + (auto,) * (n - 1)
        } else {
          s + ((start,) + (auto,) * (n - 1),)
        }
      })
      []
    },
    (s, body) => {
      body
      animation.motion(
        s,
        func,
        controls: controls,
        hider: hider,
        start: start,
        is-shown: is-shown,
      )
    },
  )
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
  /// hider for the list/enums
  /// -> function
  hider: hide,
  /// other styling arguments will be passed to enum/list set rules.
  /// -> any
  ..args,
  lead-parbreak: false,
) = {
  let mode = "content"
  updater(mode: mode, s => s + ((rel: -1, to: start),))

  if body.func() not in ([].func(), [ ].func()) {
    panic("Styling in step-item function is not supported.")
  }

  let children = body.children
  let is-tight = not children.any(c => c == parbreak())
  let items = children.filter(c => c not in ([], [ ], parbreak()))
  let last-i = items.len() - 1

  set enum(numbering: numbering) if numbering != auto
  set list(marker: marker) if marker != auto

  set enum(..args)
  set list(..args)

  for (i, item) in items.enumerate() {
    uncover(mode: mode, from: auto, item, update: true, hider: body => context {
      if not is-tight { hider(block(body)) } else {
        if i == 0 {
          hider(block(
            body,
            above: if lead-parbreak { par.spacing } else { par.leading },
          ))
        } else if i < last-i {
          hider(block(spacing: par.leading, body))
        } else {
          hider(block(above: par.leading, body))
        }
      }
    })
    if not is-tight and i == 0 { parbreak() }
  }
}

#let display-item(
  ..indices,
  body,
  hider: hide,
  lead-parbreak: false,
) = {
  let mode = "content"

  indices = indices.pos()
  let covers = indices.map(i => {
    if type(i) not in (array, dictionary) { i = (i,) }
    uncover.with(..i, mode: mode, update: true)
  })

  let children = body.children
  let is-tight = not children.any(c => c == parbreak())
  let items = children.filter(c => c not in ([], [ ], parbreak()))
  let n-items = items.len()
  let n-covers = covers.len()

  if n-covers < n-items {
    // default cover is pause.
    if covers == () { covers = (uncover.with(from: auto),) * n-items } else {
      // broadcast the last function.
      covers += (n-items - n-covers) * (covers.last(),)
    }
  }

  for (i, (item, cover)) in items.zip(covers).enumerate() {
    if item.func() in (enum.item, list.item) {
      cover(item, hider: body => context {
        if not is-tight { hider(block(item)) } else {
          if i == 0 {
            hider(block(
              body,
              above: if lead-parbreak { par.spacing } else { par.leading },
            ))
          } else if i < n-items - 1 {
            hider(block(spacing: par.leading, item))
          } else {
            hider(block(above: par.leading, item))
          }
        }
      })
    } else {
      item
    }
    if not is-tight and i == 0 { parbreak() }
  }
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
  /// hider for the list/enums
  /// -> function
  hider: hide,
  /// whether to show the shown list/enum items. If set to `false`, each list/enum item will be shown only once per animation.
  /// -> bool
  accumulated: true,
  /// the enum/list
  /// -> enum | list
  ..args,
) = {
  let mode = "content"
  set enum(numbering: numbering) if numbering != auto
  set list(marker: marker) if marker != auto

  let bodies = args.pos()
  assert(
    bodies.all(body => body.func() in ([].func(), [ ].func())),
    message: "Styling in `reveal-item` function is not supported.",
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

  // panic(indices)

  set enum(numbering: numbering) if numbering != auto
  set list(marker: marker) if marker != auto

  set enum(..args.named())
  set list(..args.named())

  updater(mode: mode, s => s + ((rel: -1, to: start),))
  display-item(..indices, bodies.sum(), hider: hider)
}
