/*
  File: hfdata.typ
  Author: neuralpain
  Date Modified: 2025-12-10

  Description: Handle header-footer position alignment.
*/

#let hfdata(hf, a, flex) = {
  if flex {
    if type(hf) == array and hf.len() > 1 {
      if hf.len() == 2 {
        if a == right {
          [#h(1fr) #hf.at(0) #h(1fr) #hf.at(1)]
        } else if a == left {
          [#hf.at(0) #h(1fr) #hf.at(1) #h(1fr)]
        } else {
          [#hf.at(0) #h(1fr) #hf.at(1)]
        }
      } else if hf.len() > 2 {
        [#hf.at(0) #h(1fr) #hf.at(1) #h(1fr) #hf.at(2)]
      } else {
        align(a)[#hf]
      }
    } else {
      align(a)[#hf]
    }
  } else {
    if type(hf) == array and hf.len() > 1 {
      set grid(columns: 3, column-gutter: 1fr)
      if hf.len() == 2 {
        if a == right {
          grid([], [#hf.at(0)], [#hf.at(1)])
        } else if a == left {
          grid([#hf.at(0)], [#hf.at(1)], [])
        } else {
          grid([#hf.at(0)], [], [#hf.at(1)])
        }
      } else if hf.len() > 2 {
        grid([#hf.at(0)], [#hf.at(1)], [#hf.at(2)])
      } else {
        align(a)[#hf]
      }
    } else {
      align(a)[#hf]
    }
  }
}
