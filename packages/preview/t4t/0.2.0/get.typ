// Dictionaries

#import "is.typ": all-of-type

#let dict( ..dicts ) = {
  let d = (:)
  for i in range(1, dicts.pos().len(), step:2) {
    d.insert(
      str(dicts.pos().at(i - 1)),
      dicts.pos().at(i)
    )
  }
  if calc.odd(dicts.pos().len()) {
    d.insert(dicts.pos().last(), none)
  }
  for (k, v) in dicts.named() {
    d.insert(k, v)
  }
  return d
}

// Based on work by @johannes-wolf for johannes-wolf/typst-canvas
// See: https://github.com/johannes-wolf/typst-canvas/
#let dict-merge( ..dicts ) = {
  if all-of-type("dictionary", ..dicts.pos()) {
    let c = (:)
    for dict in dicts.pos() {
      for (k, v) in dict {
        if k not in c {
          c.insert(k, v)
        } else {
          let d = c.at(k)
          c.insert(k, dict-merge(d, v))
        }
      }
    }
    return c
  } else {
    return dicts.pos().last()
  }
}

// Extract arguments from a sink
#let args(
	args,
	prefix: ""
) = (..keys) => {
	let vars = (:)
  for key in keys.pos() {
    let k = prefix + key
    if k in args.named() {
			vars.insert(key, args.named().at(k))
		}
  }
	for (key, value) in keys.named() {
	  let k = prefix + key
		if k in args.named() {
			vars.insert(key, args.named().at(k))
		} else {
			vars.insert(key, value)
		}
	}

	return vars
}

// Extract text from any element
#let text( element, sep: "" ) = {
	if type(element) == "content" {
		if element.has("text") {
			element.text
		} else if element.has("children") {
     element.children.map(text).join(sep)
		} else if element.has("child") {
			text(element.child)
		} else if element.has("body") {
			text(element.body)
		} else {
			""
		}
  } else if type(element) in ("array", "dict") {
    return ""
	} else {
		str(element)
	}
}

// Based on work by @PgBiel for PgBiel/typst-tablex
// See: https://github.com/PgBiel/typst-tablex
#let stroke-paint-regex = regex("\+ ((rgb|cmyk|luma)\(.+\))$")

#let stroke-paint( stroke, default: black ) = {
  if type(stroke) in ("length", "relative length") {
    return default
  } else if type(stroke) == "color" {
    return stroke
  } else if type(stroke) == "stroke" {  // 2em + blue
    let s = repr(stroke).find(stroke-paint-regex)

    if s == none { return default }
    else { return eval(s.slice(2)) }
  } else if type(stroke) == "dictionary" and "paint" in stroke {
    return stroke.paint
  } else {
    return default
  }
}

#let stroke-thickness-regex = regex("^\\d+(?:em|pt|cm|in|%)")

#let stroke-thickness( stroke, default: 1pt ) = {
  if type(stroke) in ("length", "relative length") {
    return stroke
  } else if type(stroke) == "color" {
    return 1pt
  } else if type(stroke) == "stroke" {  // 2em + blue
    let s = repr(stroke).find(stroke-thickness-regex)

    if s == none { return default }
    else { return eval(s) }
  } else if type(stroke) == "dictionary" and "thickness" in stroke {
    return stroke.thickness
  } else {
    return default
  }
}

#let stroke-dict( stroke, ..overrides ) = {
  let dict = (
    paint: stroke-paint(stroke),
    thickness: stroke-thickness(stroke),
    dash: "solid",
    cap: "round",
    join: "round"
  )
  if type(stroke) == "dictionary" {
    dict = dict + stroke
  }
  return dict + overrides.named()
}

#let inset-at( direction, inset, default: 0pt ) = {
  direction = repr(direction)   // allows use of alignment values
  if type(inset) == "dictionary" {
    if direction in inset {
      return inset.at(direction)
    } else if direction in ("left", "right") and "x" in inset {
      return inset.x
    } else if direction in ("top", "bottom") and "y" in inset {
      return inset.y
    } else if "rest" in inset {
      return inset.rest
    } else {
      return default
    }
  } else if inset == none {
    return default
  } else {
    return inset
  }
}

#let inset-dict( inset, ..overrides ) = {
  let dict = (
    top: inset-at(top, inset),
    bottom: inset-at(bottom, inset),
    left: inset-at(left, inset),
    right: inset-at(right, inset)
  )
  if type(inset) == "dictionary" {
    dict = dict + inset
  }
  return dict + overrides.named()
}

#let x-align( align, default:left ) = {
  if align in (left, right, center) {
    return align
  } else if type(align) == "2d alignment" {
    return eval(repr(align).split().first())
  } else {
    return default
  }
}

#let y-align( align, default:top ) = {
  if align in (top, bottom, horizon) {
    return align
  } else if type(align) == "2d alignment" {
    return eval(repr(align).split().last())
  } else {
    return default
  }
}
