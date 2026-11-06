#let flexwrap(
  flex: auto,
  main-dir: ltr,
  main-spacing: 0% + 0pt,
  cross-dir: ttb,
  cross-spacing: 0% + 0pt,
  ..children,
) = {
  if type(flex) != array {
    flex = children.pos().map(child => flex)
  }

  if (main-dir in (ltr, rtl)) == (cross-dir in (ltr, rtl)) {
    panic("The directions main-dir and cross-dir must be orthogonal.")
  }
  if flex.len() != children.pos().len() {
    panic("The given flex array's length does not match the number of children.")
  }

  let axis = if main-dir in (ltr, rtl) { "x" } else { "y" }

  let axis-box(size: 0pt, content) = if axis == "x" {
    box(width: size, content)
  } else {
    box(height: size, content)
  }

  return layout(((width, height)) => {
    let stacks = ()
    let items = children.pos()
    let remaining-flex = flex

    let main-size = if axis == "x" { width } else { height }
    let cross-size = if axis == "x" { height } else { width }

    let virtual-items = items
      .enumerate()
      .map(((index, item)) => {
        let item-flex = flex.at(index)

        if type(item-flex) == fraction {
          if item-flex <= 0fr {
            panic("Flex parameter can not be 0fr or less.")
          }
          return axis-box(size: 0pt, [])
        }
        if type(item-flex) == length {
          return axis-box(size: item-flex, [])
        }
        if type(item-flex) == ratio {
          let size = item-flex * main-size
          return axis-box(size: size, [])
        }
        if type(item-flex) == relative {
          let size = item-flex.ratio * main-size + item-flex.length
          return axis-box(size: size, [])
        }
        if item-flex == auto {
          return item
        }
        panic("Invalid flex parameter", item-flex)
      })

    while items.len() > 0 {
      let i = 1
      let remaining-size = main-size

      while i < items.len() {
        let test-stack = stack(
          dir: main-dir,
          spacing: main-spacing,
          ..virtual-items.slice(
            0,
            i + 1,
          ),
        )
        let test-measurement = measure(test-stack)
        let test-main-size = if axis == "x" { test-measurement.width } else {
          test-measurement.height
        }

        let test-remaining-size = main-size - test-main-size

        if test-remaining-size < 0pt { break }
        i += 1
        remaining-size = test-remaining-size
      }

      let total-fractional = remaining-flex
        .slice(0, i)
        .filter(v => type(v) == fraction)
        .sum(default: 1fr)

      let row-items = items
        .slice(0, i)
        .enumerate()
        .map(((index, item)) => {
          let item-flex = remaining-flex.at(index)
          if type(item-flex) == fraction {
            if item-flex <= 0fr {
              panic("Flex parameter can not be 0fr or less.")
            }
            let size = remaining-size * (item-flex / total-fractional)

            return axis-box(size: size, item)
          }
          if type(item-flex) == ratio {
            let size = item-flex * main-size
            return axis-box(size: size, item)
          }
          if type(item-flex) == length {
            return axis-box(size: item-flex, item)
          }
          if type(item-flex) == relative {
            let size = item-flex.ratio * main-size + item-flex.length
            return axis-box(size: size, item)
          }
          if item-flex == auto {
            return item
          }
          panic("Invalid flex parameter", item-flex)
        })

      stacks.push(stack(dir: main-dir, spacing: main-spacing, ..row-items))
      remaining-flex = remaining-flex.slice(i)
      items = items.slice(i)
      virtual-items = virtual-items.slice(i)
    }

    stack(
      dir: cross-dir,
      spacing: cross-spacing,
      ..stacks,
    )
  })
}
