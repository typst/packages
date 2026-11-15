#import "utils.typ"
#import "store.typ"
#import "indices.typ"

// show only when the number of pauses are less than or equal to the subslide number.
#let pause(s, body, hider: it => none) = {
  let (info, ..idx) = s
  let (pauses,) = indices.resolve(s)
  if pauses <= info.subslide or info.handout {
    body
  } else { hider(body) }
}


#let uncover(s, ..n, body, hider: hide, from: (), to: ()) = {
  let (info, ..x) = s
  let (pauses, results: (..n)) = indices.resolve(s, ..n)

  //  Show only when the subslides are in the specified indices, or in the range of from-to.
  // Minideck's original
  let logic(i) = {
    if i in n { return true }
    let tmp = ()
    if from != () { tmp.push(from) } else if to != () {
      panic("`from` must be specified in order to use `to`.")
    }
    if to != () { tmp.push(to) }

    let (results: tmp) = indices.resolve(s, ..tmp)

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
  let (results: (start,)) = indices.resolve(s, start)
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
  let (results: (start,)) = indices.resolve(s, start)
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

/// Modify the function so that it can react to the state variable `s`
/// Default behaviour is like `pause`
#let animate(
  /// The orignial functions
  /// -> function
  ..funcs,
  wrapper: pause,
  /// hiding function
  /// -> function
  hider: it => none,
  /// modifier for hiding the content.
  /// if it is not `none` then it must be `(func, ..args) => ..`
  /// -> function | none
  modifier: none,
) = {
  funcs
    .pos()
    .map(func => (s, ..args) => {
      if type(s) != array or type(s.at(0, default: none)) != dictionary {
        panic(
          "Did you forget to put the state `s` in the argument of the function `" + repr(func) + "` ?",
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
  // resolve hider
  if hider == auto {
    if display-info.hider == auto { hider = info.tag-hider } else { hider = display-info.hider }
  }
  // resolve modifier
  if display-info.func != auto {
    let funcs = display-info.func
    if type(funcs) != array {
      funcs = (funcs,)
    }
    func = utils.pipe(..funcs.map(f => if f == auto { func } else { f }))
  }

  if display-info.visible { func(body) } else { hider(body) }
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
  let (pauses, results: (start,)) = indices.resolve(s, start)
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


  // `active` means ability to change the showing status of an element,
  // `inherited` means ability to receive the previous modifiers
  // `leftover` means ability to send the modifiers to next steps
  let command-info = (
    "start": (active: true, inherited: true, leftover: true),
    "stop": (active: false, inherited: false, leftover: false),
    "revert": (active: auto, inherited: false, leftover: true),
    "apply": (active: auto, inherited: true, leftover: true),
    "clear": (active: true, inherited: false, leftover: true),
    "once": (active: true, inherited: true, leftover: false),
  )

  let default-command-info = (
    target: str,
    name: str,
    func: auto,
    hider: auto,
    active: bool,
    inherited: bool,
    leftover: bool,
  )

  let parse-str-command(string, default: default-command-info) = {
    let command = default
    command.target = string
    if not string.contains(".") {
      command.name = "once"
    } else {
      (command.target, command.name) = string.split(".")
      assert(
        command.name in command-info.keys(),
        message: "Unknown command `"
          + command.name
          + "`, the available statuses are "
          + command-info.keys().map(k => "`" + k + "`").join(", "),
      )
    }
    return command + command-info.at(command.name)
  }

  // controls: (..rules)
  // rule = (..commands)
  // command -> info
  let generate-command(raw-command, default: default-command-info) = {
    assert(
      is-command(raw-command),
      message: "The command should be either a `name`, a `name.command`, or an array. The array command must be in the form `(command-name, function)`.",
    )
    let command = default
    if type(raw-command) == str {
      command = parse-str-command(raw-command, default: default)
    } else {
      command = parse-str-command(raw-command.first(), default: default)
      // handle the function from `stop` command
      if command.name == "stop" {
        command.hider = raw-command.last()
      } else {
        command.func = raw-command.last()
      }
    }

    return command
  }

  let parse-a-rule(commands, default: default-command-info) = {
    if is-command(commands) {
      commands = (commands,)
    }
    commands.map(generate-command.with(default: default))
  }

  let status(
    // whether to show the element
    visible: is-shown,
    // keep track of previous modifiers
    history: (),
    // current modifier to use
    func: auto,
    // current hider to use
    hider: auto,
  ) = (
    visible: visible,
    history: history,
    func: func,
    hider: hider,
  )

  // Expected result:
  // (
  //  (:),
  //  ("element-1": (..properties)),
  //  ("element-1": (..properties), "element-2": (..properties)),
  // )
  let resolve(rules) = {
    let rules = rules.map(parse-a-rule)
    let result = ()
    let element-status = (:)

    for rule in rules {
      let current-status = element-status
      for command in rule {
        // initialize the status
        if command.target not in element-status {
          element-status.insert(command.target, status())
        }
        // resolve visibility
        if command.active != auto {
          element-status.at(command.target).visible = command.active
        }
        // clear the history
        if command.name == "clear" {
          element-status.at(command.target).history = ()
        }
        // inherit the modifier
        if command.inherited {
          element-status.at(command.target).func = element-status.at(command.target).history + (command.func,)
        }
        // reset the appearance when calling `revert`
        if command.name == "revert" {
          element-status.at(command.target).func = auto
        }
        // send the animation to other steps
        if command.leftover {
          element-status.at(command.target).history += (command.func,)
        }
        // process the current animation
        current-status = element-status
        // reset the visibility if there is nothing to show when `once` is called
        if command.name == "once" and element-status.at(command.target).history == () {
          element-status.at(command.target).visible = false
        }
      }

      result.push(current-status)
    }


    return result
  }

  let resolved-rules = resolve(controls)

  let current-rule = if n < start { (:) } else if n - start >= controls.len() {
    resolved-rules.at(-1, default: (:))
  } else {
    resolved-rules.at(n - start)
  }

  info.tag-hider = hider
  if info.handout { info.tag-hider = it => it }
  info.motion = (:)
  info.motion.rule = current-rule
  info.motion.default-info = status()
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

