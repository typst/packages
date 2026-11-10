// =======================================================================
//
// Git repository:
//      https://github.com/neruthes/typstpkg-pagestyle
//
//
// Copyright (c) 2026 Neruthes.
// Published with the MIT license.
//
// =======================================================================



#let __pagestyle_state = state("__pagestyle_state", (
  persistent: "plain",
  overrides: (:),
))

#let pagestyle(style-name) = {
  __pagestyle_state.update(s => {
    s.persistent = style-name
    s
  })
}

#let thispagestyle(style-name) = {
  context {
    let pnum = str(here().page())
    __pagestyle_state.update(s => {
      s.overrides.insert(pnum, style-name)
      s
    })
  }
}

#let getpagestyle(callback) = context {
  let s = __pagestyle_state.get()
  let pnum = str(here().page())
  let result = s.persistent
  if pnum in s.overrides {
    result = s.overrides.at(pnum)
  }
  callback(result)
}

// The non-async version of the same thing. Might be dangerous. Use at your own risk!
#let getpagestyle-sync() = {
  let s = __pagestyle_state.get()
  let pnum = str(here().page())
  let result = s.persistent
  if pnum in s.overrides {
    result = s.overrides.at(pnum)
  }
  return result
}

