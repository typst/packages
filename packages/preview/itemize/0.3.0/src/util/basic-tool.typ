#import "identifier.typ": *
#import "func-type.typ": *
#import "../lib/parize-internal.typ": prevent-parize-recursion-label as parize-prevent-label

#let panic(message) = if type(message) == str { assert(false, message: message) } else {
  std.panic(message)
}

/// Test if arr1 contains all elements of arr2
///
/// - arr1 (array): The array to check against
/// - arr2 (array): The array containing elements to check for
/// -> bool
#let contains-all(arr1, arr2) = {
  for v in arr2 {
    if v not in arr1 {
      return false
    }
  }
  return true
}

/// Rebuild a label for an element, optionally adding a suffix.
#let rebuild-label(elem, _label) = {
  if _label == none {
    return elem
  } else {
    [#elem#_label]
  }
}


/// Define default arguments for text styling.
#let default-text-args = (
  alternates: false,
  baseline: 0pt,
  bottom-edge: "baseline",
  cjk-latin-spacing: auto,
  costs: (
    hyphenation: 100%,
    runt: 100%,
    widow: 100%,
    orphan: 100%,
  ),
  dir: auto,
  discretionary-ligatures: false,
  fallback: true,
  features: (:),
  fill: luma(0%),
  font: "libertinus serif",
  fractions: false,
  historical-ligatures: false,
  hyphenate: auto,
  kerning: true,
  lang: "en",
  ligatures: true,
  number-type: auto,
  number-width: auto,
  overhang: true,
  region: none,
  script: auto,
  size: 11pt,
  slashed-zero: false,
  spacing: 100% + 0pt,
  stretch: 100%,
  stroke: none,
  style: "normal",
  stylistic-set: (),
  top-edge: "cap-height",
  tracking: 0pt,
  weight: "regular",
)

/// Get the current text arguments
#let get_current-text-args(it) = (
  alternates: it.alternates,
  baseline: it.baseline,
  bottom-edge: it.bottom-edge,
  cjk-latin-spacing: it.cjk-latin-spacing,
  costs: it.costs,
  dir: it.dir,
  discretionary-ligatures: it.discretionary-ligatures,
  fallback: it.fallback,
  features: it.features,
  fill: it.fill,
  font: it.font,
  fractions: it.fractions,
  historical-ligatures: it.historical-ligatures,
  hyphenate: it.hyphenate,
  kerning: it.kerning,
  lang: it.lang,
  ligatures: it.ligatures,
  number-type: it.number-type,
  number-width: it.number-width,
  overhang: it.overhang,
  region: it.region,
  script: it.script,
  size: it.size,
  slashed-zero: it.slashed-zero,
  spacing: it.spacing,
  stretch: it.stretch,
  stroke: it.stroke,
  style: it.style,
  stylistic-set: it.stylistic-set,
  top-edge: it.top-edge,
  tracking: it.tracking,
  weight: it.weight,
)

/// Define default arguments for box elements.
#let default-box-args = (
  // width: auto,
  height: auto,
  baseline: 0pt,
  fill: none,
  stroke: none,
  radius: 0pt,
  inset: 0em,
  outset: 0pt,
  clip: false,
)


/// Default arguments of block.
#let default-block-args = (
  width: auto,
  height: auto,
  fill: none,
  stroke: none, /**/
  radius: 0pt,
  inset: 0pt,
  outset: 0pt,
  // spacing: 0pt,
  above: auto,
  below: auto,
  clip: false,
  sticky: false,
  breakable: true,
)





/// Get the current block arguments
#let get-current-block-args(it) = (
  width: it.width,
  height: it.height,
  fill: it.fill,
  stroke: it.stroke,
  radius: it.radius,
  inset: it.inset,
  outset: it.outset,
  // spacing: block.spacing, // through `above`, `below`
  above: it.above,
  below: it.below,
  clip: it.clip,
  sticky: it.sticky,
  breakable: it.breakable,
)


/// Wrap content in a box with default arguments
#let label-box(body, ..args) = {
  box(..default-box-args, ..args, body)
}


/// Creates a formatted block to wrap content.
#let make-format-box(body, format-args: (:), ..args) = {
  if format-args not in ((:), none, auto, ()) {
    block.with(..default-block-args, ..format-args, ..args)(
      body,
    )
  } else {
    body
  }
}

/// Get the label of an element if it exists.
#let get-elem-label(e) = {
  return if e.has("label") { e.label } else { none }
}

/// Get a label from a string, label, or object with a text property.
#let get-label(it) = {
  return if type(it) == str {
    label(it)
  } else if type(it) == label {
    it
  } else if it.has("text") {
    label(it.text)
  } else {
    panic("The argument should be a string or a label.")
  }
}

/// Helper function to get the dir's inset value from a dictionary or length
///
/// Parameters:
///   - inset: The inset value (can be length, relative, ratio, or dictionary)
///   - dir: The direction to get the inset value for
///
/// Returns:
///   Inset value for the given dir
#let get-dir-inset(inset, dir: "left") = {
  let left-inset = 0pt
  if type(inset) in length-type {
    //(length, relative, ratio)
    left-inset = inset
  } else if type(inset) == dictionary {
    // dictionary (not none)
    let left = inset.at(dir, default: none)
    if left == none {
      let two-dir = if dir in ("left", "right") { "x" } else { "y" }
      left = inset.at(two-dir, default: none)
      if left == none {
        left = inset.at("rest", default: none)
        if left == none {
          left = 0pt
        }
        left-inset = left
      } else {
        left-inset = left
      }
    } else {
      left-inset = left
    }
  }
  return left-inset
}


/// Parse inset values excluding the given dir's inset.
#let parse-inset-without-dir(inset, dir: "left") = {
  if type(inset) in length-type {
    return (rest: inset)
  } else if type(inset) == dictionary {
    let _ = inset.remove(dir, default: none)
    return inset
  } else {
    panic("Invalid arguments.")
  }
}

/// Get the ratio component of a relative length
#let get-relative-ratio(inset) = {
  if type(inset) == relative {
    return inset.ratio
  } else if type(inset) == ratio {
    return inset
  } else {
    return 0%
  }
}

/// Get the length component of a relative length
///
/// - inset (relative, length, any): The inset value to extract length from
/// -> length
#let get-relative-length(inset) = {
  if type(inset) == relative {
    return inset.length
  } else if type(inset) == length {
    return inset
  } else {
    return auto
  }
}

#let parse-relative(inset) = {
  let _type = type(inset)
  if _type == relative {
    return (inset.ratio, inset.length)
  } else if _type == length {
    return (0%, inset)
  } else if _type == ratio {
    return (inset, 0pt)
  } else {
    return (0%, 0pt)
  }
}

/// Check if a body is marked to prevent recursion
///
/// Determines if the body contains metadata indicating recursion prevention.
///
/// - body (content): The body to check
/// -> bool
#let is-prevent-recursion-body(body) = {
  return (
    body.func() == [].func()
      and {
        let flag = for e in body.children {
          if e.func() == metadata {
            if e.value == prevent-recursion-ID {
              true
              break
            }
          }
        }
        flag != none
      }
  )
}

/// Get the value at a specific index in an array, handling LOOP cases.
///
/// Supports cyclic array access when the last element is `LOOP`.
///
/// - arr (array): The array to access
/// - n (int): The index to retrieve
/// -> any
#let get-array-value(arr, n) = {
  // arr is an array
  if arr != () {
    let last = arr.last()
    if last == LOOP {
      let len = arr.len()
      if len == 1 {
        return ()
      } else {
        let m = calc.rem-euclid(n, len - 1)
        return arr.at(m)
      }
    } else {
      return arr.at(n, default: last)
    }
  } else {
    return arr
  }
}

/// Retrieves a value from an array based on the current nesting level.
///
/// - value: The value or array of values.
/// - level: The current nesting level.
/// -> any
#let get-depth-value(value, level) = {
  if type(value) == array {
    if value == () {
      return value
    } else {
      return get-array-value(value, level)
    }
  } else {
    return value
  }
}


/// Get the default value for a given parameter.
#let get-default-value(value, initial, default) = {
  if value == initial { default } else { value }
}

/// Get the auto value for a given parameter.
#let get-auto-value(value, default) = {
  return get-default-value(value, auto, default)
}

/// Get the value at a specific index in an array.
/// form: n => value
/// return : n => value
#let get-value-by-n(func, initial, default) = {
  if type(func) == function {
    // form: n => value
    return n => get-default-value(func(n + 1), initial, default)
  } else if type(func) == array {
    n => get-default-value(get-array-value(func, n), initial, default)
  } else {
    return _ => get-default-value(func, initial, default)
  }
}

/// Get the value at a specific depth in a nested structure.
/// form: level => n => value
/// return: n => vallue
#let get-depth-value-by-n(func, level, initial, default) = {
  if type(func) == function {
    // func: level => n => value; level => array; level => value;
    return get-value-by-n(func(level + 1), initial, default)
  } else {
    // func: array; value
    return get-value-by-n(get-depth-value(func, level), initial, default)
  }
}

/// Return a default 'none' value.
///
/// -> none
#let get-none-value(value1, value2) = {
  if value2 != none {
    return value2
  } else {
    return value1
  }
}

/// Display text with specified formatting.
#let show-text(args, body) = {
  if args not in (none, (:)) and body not in (none, [], [ ], auto) {
    set text(..args)
    body
  } else {
    body
  }
}

/// Measure the baseline height of the content (for first line)
///
/// - body (content): the content of the box
/// -> (length, length)
#let get-baseline-inset-in-box(body, height: auto) = {
  // improve when using: https://github.com/typst/typst/pull/8799
  let body-height = if height == auto { measure(body).height.to-absolute() } else { height }
  let box-body = box(baseline: auto, body)
  let all-height = measure([#box(baseline: bottom, body)#box-body]).height
  let below-height = all-height - body-height
  // TODO: if baseline is not in body, not correct
  return (
    (measure([#box(baseline: bottom, body)#box-body]).height.to-absolute() - body-height, body-height)
  )
}

#let get-first-line-height-in-box(body, width: auto) = {
  // improve when using: https://github.com/typst/typst/pull/8799
  let body-height = measure(body, width: width).height
  let box-body = box(width: width, body)
  let all-height = measure([#box(baseline: top, width: width, body)#box-body]).height
  let first-line-height = all-height - body-height
  let EPS = 0.0001pt
  if calc.abs(first-line-height - body-height) < EPS {
    // no baseline
    return (0pt, body-height)
  }
  // TODO: if baseline is not in body, not correct
  // TODO: if float-figure and place.float == true is in body, not correct
  return (
    (
      first-line-height,
      body-height,
    )
  )
}

#let move-block(height, ..args) = {
  [#block(
      height: height,
      spacing: 0pt,
      stroke: none,
      outset: 0pt,
      // outset: (left: 2pt),
      inset: 0pt,
      sticky: true,
      breakable: false,
      ..args,
    )#parize-prevent-label]
}

// #let sticky-block = {
//   [#block(spacing: 0pt, width: 0pt, height: 0pt, inset: 0pt, sticky: true)#parize-prevent-label]
// }

/// Create a hidden line with specified spacing
///
/// - below (length): spacing below the line
/// - above (length): spacing above the line
/// -> content
#let hide-line(below: 0pt, above: 0pt, ..args) = [#block(
    width: 0pt,
    height: 0pt,
    stroke: none,
    outset: 0pt,
    above: above,
    below: below,
    inset: 0pt,
    ..args,
  )#parize-prevent-label]


#let v-line-tag(height: 0pt, baseline: 0pt) = {
  box(
    height: height,
    baseline: baseline,
    width: 0pt,
    stroke: none,
    inset: 0pt,
    outset: 0pt,
    // outset: (right: 2pt),
  )
  h(0pt, weak: true)
}

#let get-baseline-at-auto(at: auto, height: 0pt, baseline: 0pt) = {
  // assert height >= 0pt
  // switch to `at: auto`
  let below-height
  let above-height
  if height >= 0pt {
    if at == auto {
      if baseline < 0pt {
        above-height = height - baseline
        below-height = 0pt
      } else if baseline > height {
        above-height = 0pt
        below-height = baseline
      } else {
        above-height = height - baseline
        below-height = baseline
      }
    } else if at == bottom {
      above-height = height
      below-height = 0pt
    } else if at == top {
      above-height = 0pt
      below-height = height
    } else if at == horizon {
      above-height = height * .5
      below-height = height * .5
    }
    return (above-height: above-height, below-height: below-height)
  } else {
    (above-height, below-height) = get-baseline-at-auto(at: at, height: -height, baseline: baseline)
    return (above-height: below-height, below-height: above-height)
  }
}
