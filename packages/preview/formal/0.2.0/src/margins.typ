#let auto-page-margin(page-width, page-height) = 2.5 / 21 * calc.min(page-width, page-height)

#let page-margin-dict-entry(page-margin, side) = {
  if side in ("top", "bottom") {
    if side in page-margin.keys() {
      return page-margin.at(side)
    }
    if "y" in page-margin.keys() {
      return page-margin.y
    }
  } else {
    if side in page-margin.keys() {
      return page-margin.at(side)
    }
    if "x" in page-margin.keys() {
      return page-margin.x
    }
  }

  if "rest" in page-margin.keys() {
    return page-margin.rest
  }

  auto
}

#let effective-page-binding() = {
  if page.binding != auto {
    return page.binding
  }

  if text.dir == rtl {
    right
  } else {
    left
  }
}

#let page-margin-setting(page-margin) = {
  if page-margin == auto {
    return auto
  }

  if type(page-margin) != dictionary {
    return (
      top: page-margin,
      bottom: page-margin,
      inside: page-margin,
      outside: page-margin,
    )
  }

  let top = page-margin-dict-entry(page-margin, "top")
  let bottom = page-margin-dict-entry(page-margin, "bottom")

  if "left" in page-margin.keys() or "right" in page-margin.keys() {
    let left = page-margin-dict-entry(page-margin, "left")
    let right = page-margin-dict-entry(page-margin, "right")

    if left == right {
      return (
        top: top,
        bottom: bottom,
        inside: left,
        outside: right,
      )
    }

    return (
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    )
  }

  (
    top: top,
    bottom: bottom,
    inside: page-margin-dict-entry(page-margin, "inside"),
    outside: page-margin-dict-entry(page-margin, "outside"),
  )
}

#let resolve-page-margin-value(value, page-width, page-height) = {
  if value == auto {
    return auto-page-margin(page-width, page-height)
  }

  if type(value) == relative {
    return value.length
  }

  value
}

#let resolve-page-margin(page-margin, page-width, page-height, page-number) = {
  if type(page-margin) != dictionary {
    let margin = resolve-page-margin-value(page-margin, page-width, page-height)
    return (
      top: margin,
      right: margin,
      bottom: margin,
      left: margin,
    )
  }

  let binding = effective-page-binding()
  let top = resolve-page-margin-value(
    if "top" in page-margin.keys() { page-margin.top } else { auto },
    page-width,
    page-height,
  )
  let bottom = resolve-page-margin-value(
    if "bottom" in page-margin.keys() { page-margin.bottom } else { auto },
    page-width,
    page-height,
  )

  let (left, right) = if "left" in page-margin.keys() or "right" in page-margin.keys() {
    let left = resolve-page-margin-value(
      if "left" in page-margin.keys() { page-margin.left } else { auto },
      page-width,
      page-height,
    )
    let right = resolve-page-margin-value(
      if "right" in page-margin.keys() { page-margin.right } else { auto },
      page-width,
      page-height,
    )
    (left, right)
  } else {
    let is-bound-left = calc.odd(page-number) == (binding == left)
    let inside = resolve-page-margin-value(
      if "inside" in page-margin.keys() { page-margin.inside } else { auto },
      page-width,
      page-height,
    )
    let outside = resolve-page-margin-value(
      if "outside" in page-margin.keys() { page-margin.outside } else { auto },
      page-width,
      page-height,
    )

    if is-bound-left {
      (inside, outside)
    } else {
      (outside, inside)
    }
  }

  (
    top: top,
    right: right,
    bottom: bottom,
    left: left,
  )
}
