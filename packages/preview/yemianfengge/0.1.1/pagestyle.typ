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



#let __pagestyle_default = "plain"

#let __pagestyle_state = state("__pagestyle_state", (
  persistent-log: (),
  overrides: (:),
))

#let __pagestyle_resolve(s, pnum) = {
  let result = __pagestyle_default
  for entry in s.persistent-log {
    if entry.page <= pnum {
      result = entry.name
    }
  }
  let key = str(pnum)
  if key in s.overrides {
    result = s.overrides.at(key)
  }
  result
}

#let pagestyle(style-name) = {
  context {
    let pnum = here().page()
    __pagestyle_state.update(s => {
      s.persistent-log.push((page: pnum, name: style-name))
      s
    })
  }
}

#let thispagestyle(style-name) = {
  context {
    let pnum = here().page()
    __pagestyle_state.update(s => {
      s.overrides.insert(str(pnum), style-name)
      s
    })
  }
}

#let nextpagestyle(style-name) = {
  context {
    let pnum = here().page() + 1
    __pagestyle_state.update(s => {
      s.overrides.insert(str(pnum), style-name)
      s
    })
  }
}

#let getpagestyle(callback) = context {
  let s = __pagestyle_state.final()
  let pnum = here().page()
  callback(__pagestyle_resolve(s, pnum))
}

// The non-async version of the same thing. Might be dangerous. Use at your own risk!
#let getpagestyle-sync() = {
  let s = __pagestyle_state.final()
  let pnum = here().page()
  __pagestyle_resolve(s, pnum)
}
