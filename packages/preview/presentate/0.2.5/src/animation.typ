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


#let tag(s, name, body, hider: auto, func: it => it) = {
  let (info, ..x) = s
  let display-info = info.motion.rule.at(name, default: info.motion.default-info)
  if hider == auto {
    if display-info.hider == auto { hider = info.tag-hider } else { hider = display-info.hider }
  }
  if display-info.func != auto { func = display-info.func }
  if display-info.status == "revealed" { func(body) } else { hider(body) }
}

#let motion(
  s,
  // contains the tags.
  func,
  // This is an array of motion control.
  // (A, B, C) means show A then B then C.
  // (A, (B, C), C) means shown A, then B + C, and then C.
  controls: (),
  hider: it => none,
  // Default show rules of the elements
  is-shown: false,
  start: none,
) = {
  let (info, ..x) = s
  let (pauses, results: (start,)) = indices.resolve-indices(s, start)
  let n = info.subslide

  // Rules
  // name = show once,
  // name.start = start showing
  // name.stop = stop showing
  // (name, func) = apply function once
  // (name.apply, func) = apply function from now on
  // (name.start, func) = apply function from now on, and change the shown state to true
  // (name.stop, func) = apply the function as hider from now on.
  // name.revert = revert back to identity function
  let is-command(command) = {
    (
      type(command) == str
        or {
          (
            type(command) == array
              and command.len() == 2
              and type(command.first()) == str
              and type(command.last()) == function
          )
        }
    )
  }

  let default-element-info = (
    name: none,
    status: if is-shown { "revealed" } else { "hidden" },
    func: auto,
    hider: auto,
  )

  let parse-str-status(string, info: default-element-info) = {
    info.name = string
    if not string.contains(".") {
      info.status = "once"
    } else {
      (info.name, info.status) = string.split(".")
      assert(
        info.status
          in (
            "start",
            "stop",
            "apply",
            "revert",
          ),
        message: "Unknown status `"
          + info.status
          + "`, the available statuses are `start`, `stop`, `apply`, and `revert`.",
      )
    }
    return info
  }
  // panic(parse-str-status("good"))
  // controls: (..rules)
  // rule = (..commands)
  // command -> info
  let generate-status(command, info: default-element-info) = {
    assert(
      is-command(command),
      message: "The array command must be in the form `(status, function)`.",
    )
    info.name = command
    if type(command) == str {
      info = parse-str-status(command, info: info)
      if info.status == "revert" {
        info.func = auto
      }
    } else {
      info = parse-str-status(command.first())
      if info.status == "stop" { info.hider = command.last() } else {
        info.func = command.last()
      }
    }
    return info
  }
  // panic(generate-status(("good", it => it)))

  let parse-a-rule(commands, info: default-element-info) = {
    if is-command(commands) {
      commands = (commands,)
    }
    commands.map(generate-status.with(info: info))
  }

  let resolve(rules, info: default-element-info) = {
    let raw-rules = rules.map(parse-a-rule.with(info: info))
    let result = ()
    let all-state = (:)
    let resolved-state = (:)
    for rule in raw-rules {
      // save the current resolved state 
      resolved-state = all-state
      for command in rule {
        let name = command.remove("name")
        if command.status == "stop" { command.status = "hidden" }
        if command.status == "start" { command.status = "revealed" }
        if command.status in ("revert", "apply") {
          if all-state.at(name, default: info).status == "revealed" {
            command.status = "revealed"
          } else {
            command.status = "hidden"
          }
        }
        // resolve the `once` status
        let resolved-command = command
        if command.status == "once" {
          if command.func == auto { resolved-command.status = "revealed" } else {
            resolved-command.status = all-state.at(name, default: info).status
          }
        }
        resolved-state.insert(name, resolved-command)
        if command.status == "once" {
          if command.func == auto { resolved-command.status = "hidden" } else {
            resolved-command.status = all-state.at(name, default: info).status
            resolved-command.func = auto
          }
        }
        // for resetting the `once` specification.
        all-state.insert(name, resolved-command)
      }
      result.push(resolved-state)
    }
    return result
  }

  let resolved-rules = resolve(controls, info: default-element-info)
  let current-rule = if n < start { () } else if n - start >= controls.len() {
    resolved-rules.at(-1, default: (:))
  } else {
    resolved-rules.at(n - start)
  }

  info.tag-hider = hider
  if info.handout { info.tag-hider = it => it }
  info.motion = (:)
  info.motion.rule = current-rule
  info.motion.default-info = default-element-info
  func((info,))
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

