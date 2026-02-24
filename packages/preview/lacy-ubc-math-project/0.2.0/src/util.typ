/// The doc-wide config.
#let config-state = state("lacy-ubc-math-project-config", (:))

/// Compose a series of functions with a body.
///
/// - body (any): The body to execute things on.
/// - funcs (arguments): The functions to be composed, left-to-right.
/// -> any
#let compose(body, ..funcs) = (body, ..funcs.pos()).reduce((it, func) => if type(func) == function {
  func(it)
} else {
  it
})

/// Convert `data` to a dictionary, panic on fail.
///
/// - data (dictionary, module, function, arguments): The data to convert to dictionary.
/// -> dictionary
#let to-dict(data) = {
  let t = type(data)
  if t == dictionary {
    return data
  }
  if t == module {
    return dictionary(data)
  }
  if t == function {
    return to-dict(t())
  }
  if t == arguments {
    return data.named()
  }
  panic("Cannot convert a " + t + " to a dictionary!")
}

/// Merge dictionaries, left-to-right.
/// On merge, values of existing keys are replaced, and values of new keys are added.
/// Values of type `dictionary` are not merged, instead their own pairs are merged.
///
/// - dicts (arguments): The `dictionary`s to be merged.
/// -> dictionary
#let merge-dicts(..dicts) = (
  dicts
    .pos()
    .reduce((orig, cand) => cand
      .keys()
      .fold(
        orig,
        (acc, k) => if k in orig.keys() and type(orig.at(k)) == dictionary and type(cand.at(k)) == dictionary {
          acc + ((k): merge-dicts(orig.at(k), cand.at(k)))
        } else {
          acc + ((k): cand.at(k))
        },
      ))
)

/// Merge dictionaries, but non-`dictionary` arguments are first converted to `dictionary` and the value of the "config" key is taken.
///
/// - conf (arguments): The `dictionary`s a/o `module`s to be merged. Can also be `arguments` or anything accepted by `util.to-dict`.
/// -> dictionary
#let merge-configs(..conf) = merge-dicts(
  ..conf.pos().map(c => if type(c) == module { to-dict(c).at("config", default: (:)) } else { to-dict(c) }),
)

