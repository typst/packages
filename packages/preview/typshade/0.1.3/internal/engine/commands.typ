// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#let _add-command(out, value) = {
  if value == none {
    return out
  }
  if type(value) == array {
    for item in value {
      out = _add-command(out, item)
    }
  } else {
    out.push(value)
  }
  out
}

#let command-pack(..items) = {
  let out = ()
  for item in items.pos() {
    out = _add-command(out, item)
  }
  out
}
