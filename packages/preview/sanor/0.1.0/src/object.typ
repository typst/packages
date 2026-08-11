#import "utils.typ"

#let object(
  func,
  ..modify-cases,
) = (..args) => {
  let modifiers = (__base__: (:)) + modify-cases.named()
  let info = (
    func: func,
    args: args,
    modifiers: modifiers,
  )
  return (..case, debug: false, show-all: false) => {
    if debug or show-all { return info }
    let case = case.pos()
    assert(case.len() == 1, message: "Cases must be retrieved one at a time.")
    (
      func: func,
      args: args,
      modifier: modifiers.at(case.first(), default: (:)),
    )
  }
}

#let update-modifier(obj, ..modifiers) = {
  let original = obj(show-all: true)
  let modifiers = utils.merge-dicts(base: original.modifiers, modifiers.named())
  return object(original.func, ..modifiers)(..original.args)
}

#let call-object(obj, case) = {
  let info = obj(case)
  if type(info.modifier) == function {
    (info.modifier)((info.func)(..info.args))
  } else if (
    type(info.modifier) == array and info.modifier.len() > 0 and type(info.modifier.first()) == function
  ) {
    let base = (info.func)(..info.args)
    utils.pipe(base, ..info.modifier)
  } else {
    return (info.func)(..info.args, ..info.modifier)
  }
}

#let make-object(
  func,
  ..modify-cases,
) = (..args) => {
  let obj = object(func, ..modify-cases)(..args)
  let cases = obj(show-all: true).modifiers
  let base = func(..args)
  let result = (__base__: base)
  for case in cases.keys() {
    result.insert(case, call-object(obj, case))
  }
  return (..m) => {
    let out = (object(func, ..result)(..args)(..m))
    out.at("modifier", default: out)
  }
}