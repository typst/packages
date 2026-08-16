#let _positive(value, name) = {
  if value <= 0pt {
    panic("sheetwise: `" + name + "` must be greater than zero.")
  }
  value
}

#let _non-negative(value, name) = {
  if value < 0pt {
    panic("sheetwise: `" + name + "` must not be negative.")
  }
  value
}

#let _integer(value, name) = {
  if type(value) != int {
    panic("sheetwise: `" + name + "` must be an integer.")
  }
  value
}

#let _non-negative-int(value, name) = {
  let value = _integer(value, name)
  if value < 0 {
    panic("sheetwise: `" + name + "` must not be negative.")
  }
  value
}

#let _positive-int(value, name) = {
  let value = _integer(value, name)
  if value < 1 {
    panic("sheetwise: `" + name + "` must be at least 1.")
  }
  value
}

#let _one-of(value, allowed, message) = {
  if allowed.contains(value) {
    value
  } else {
    panic(message)
  }
}

#let _has-key(dict, key) = dict.keys().contains(key)

#let _get(dict, key, default) = {
  if _has-key(dict, key) {
    dict.at(key)
  } else {
    default
  }
}

#let _merge(defaults, overrides) = {
  let result = defaults
  for key in overrides.keys() {
    result.insert(key, overrides.at(key))
  }
  result
}

#let _checked-dimension(value, name, positive) = {
  if positive {
    _positive(value, name)
  } else {
    _non-negative(value, name)
  }
}

#let _size(value, name, positive: true) = {
  if type(value) == dictionary {
    if _has-key(value, "width") and _has-key(value, "height") {
      return (
        width: _checked-dimension(value.width, name + ".width", positive),
        height: _checked-dimension(value.height, name + ".height", positive),
      )
    }
  }

  if type(value) == array and value.len() == 2 {
    return (
      width: _checked-dimension(value.at(0), name + ".width", positive),
      height: _checked-dimension(value.at(1), name + ".height", positive),
    )
  }

  panic("sheetwise: `" + name + "` must be `(width: ..., height: ...)` or `(width, height)`.")
}

#let _pair(value, name, positive: false) = {
  if type(value) == dictionary or type(value) == array {
    _size(value, name, positive: positive)
  } else {
    (
      width: _checked-dimension(value, name + ".width", positive),
      height: _checked-dimension(value, name + ".height", positive),
    )
  }
}

#let _margin(value, name: "margin") = {
  let make = (left, right, top, bottom) => (
    left: _non-negative(left, name + ".left"),
    right: _non-negative(right, name + ".right"),
    top: _non-negative(top, name + ".top"),
    bottom: _non-negative(bottom, name + ".bottom"),
  )

  if type(value) == dictionary {
    let has-side = _has-key(value, "left") or _has-key(value, "right") or _has-key(value, "top") or _has-key(value, "bottom")
    if has-side {
      let x = if _has-key(value, "width") { value.width } else { 0pt }
      let y = if _has-key(value, "height") { value.height } else { 0pt }
      return make(
        _get(value, "left", x),
        _get(value, "right", x),
        _get(value, "top", y),
        _get(value, "bottom", y),
      )
    }

    if _has-key(value, "width") and _has-key(value, "height") {
      return make(value.width, value.width, value.height, value.height)
    }
  }

  if type(value) == array and value.len() == 2 {
    return make(value.at(0), value.at(0), value.at(1), value.at(1))
  }

  if type(value) == dictionary or type(value) == array {
    panic("sheetwise: `" + name + "` must be a length, `(x, y)`, `(width: ..., height: ...)`, or side margins.")
  }

  make(value, value, value, value)
}

#let _resolve-trim-size(trim-size, item-size: auto) = {
  if trim-size == auto and item-size == auto {
    panic("sheetwise: `trim-size` is required.")
  }

  if trim-size != auto and item-size != auto {
    let trim = _size(trim-size, "trim-size")
    let item = _size(item-size, "item-size")
    if trim.width != item.width or trim.height != item.height {
      panic("sheetwise: `trim-size` and `item-size` must match when both are provided.")
    }
    return trim
  }

  if trim-size != auto {
    _size(trim-size, "trim-size")
  } else {
    _size(item-size, "item-size")
  }
}

#let _validate-order(order) = {
  _one-of(order, ("forward", "reverse"), "sheetwise: `order` must be `forward` or `reverse`.")
}

#let _order-index(order, index, total) = {
  if order == "reverse" { total - 1 - index } else { index }
}

#let _validate-flip(flip) = {
  _one-of(flip, ("long-edge", "short-edge", "none"), "sheetwise: `flip` must be `long-edge`, `short-edge`, or `none`.")
}

#let _validate-duplex-back(duplex, back, back-name, job-name) = {
  if duplex and back == none {
    panic("sheetwise: `" + job-name + "` needs `" + back-name + "` when `duplex: true`.")
  }
  if not duplex and back != none {
    panic("sheetwise: `" + back-name + "` requires `duplex: true`.")
  }
}
