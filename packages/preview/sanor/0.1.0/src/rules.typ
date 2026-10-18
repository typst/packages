#import "object.typ": make-object,  object, update-modifier,  call-object

#let tag(
  // the context of animation
  // -> info
  s,
  // identifier
  // -> str
  name,
  // the body
  // -> any | object
  body,
  // hiding function or methods
  // -> any
  hider: auto,
  // the ways to manipulate the body.
  ..cases,
) = {
  let info = s.tag-info
  let default-case = if info.is-shown { "__base__" } else { "hidden" }
  let current-state = info.tags.at(name, default: (case: default-case, modifier: (:)))
  let defined-case = info.defined-states

  if hider == auto { hider = info.hider }
  // make all body be an object
  if type(body) != function {
    body = object(() => body, hidden: hider, ..defined-case, ..cases)()
  }
  body = update-modifier(body, ..defined-case)
  body = update-modifier(body, ..((current-state.case): current-state.modifier))
  return call-object(body, current-state.case)
}

// There are 3 types of state:
// 1. once
// 2. start-apply (apply)
// 3. stop-apply (clear)
// A state is in the form:
// (
//   type: "once",
//   name: {name},
//   case: {case},
//   modifier: {modifier},
// )
#let _apply(name, ..modifier-cases) = kind => {
  let styles-modifier = modifier-cases.named()
  let modifier-cases = modifier-cases.pos()
  let case = ()
  let modifier = ()
  for mc in modifier-cases {
    if type(mc) == str { case.push(mc) } else { modifier.push(mc) }
  }
  if modifier == () { modifier = styles-modifier }

  return (
    type: kind,
    name: name,
    case: if case.len() == 0 { "__applied__" } else { case.remove(0) },
    modifier: modifier,
  )
}

/// Apply the modifier to the content with the given name. If the content is not defined, it will be treated as if it is in the base state. If the content is already applied, the new modifier will be piped to the old one.
#let apply(
  name,
  ..modifier-cases,
) = _apply(name, ..modifier-cases)("apply")

/// Apply the modifier only once. If the content is not defined, it will be treated as if it is in the base state. If the content is already applied, the new modifier will be piped to the old one. After the modifier is applied, it will be removed from the context.
#let once(
  name,
  ..modifier-cases,
) = _apply(name, ..modifier-cases)("once")

/// Clear all modifiers of the content with the given name. If the content is not defined, this command will do nothing.
#let clear(name) = {
  return (
    type: "clear",
    name: name,
    case: "__base__",
    modifier: (:),
  )
}

#let cover(name) = apply(name, "hidden")
#let revert(name) = apply(name, "__base__")
