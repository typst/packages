
#import "test.typ": all-of-type

// =================================
//  Dictionaries
// =================================

/// Create a new dictionary from #args[values].
///
/// All named arguments are stored in the new dictionary as is.
/// All positional arguments are grouped in key/value-pairs and
/// inserted into the dictionary:
/// #codesnippet[```typ
/// #get.dict("a", 1, "b", 2, "c", d:4, e:5)
///    // gives (a:1, b:2, c:none, d:4, e:5)
/// ```]
///
/// // Tests
/// #utest(
///   `get.dict("a", "b", "c") == (a:"b", c:none)`,
///   `get.dict("a", "b", "c", 4) == (a:"b", c:4)`,
///   `get.dict(a:"b", "c", 4) == (a:"b", c:4)`
/// )
///
/// - ..dicts (any): Values to merge into the dictionary.
/// -> dictionary
#let dict(..dicts) = {
  let d = (:)
  for i in range(1, dicts.pos().len(), step: 2) {
    d.insert(
      str(dicts.pos().at(i - 1)),
      dicts.pos().at(i),
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

/// Recursivley merges the passed in dictionaries.
/// #codesnippet[```typ
/// #get.dict-merge(
///     (a: 1, b: 2),
///     (a: (one: 1, two:2)),
///     (a: (two: 4, three:3))
/// )
///    // gives (a:(one:1, two:4, three:3), b: 2)
/// ```]
///
/// // Tests
/// #utest(
///   `get.dict-merge(
///     (a: 1, b: 2),
///     (a: (one: 1, two:2)),
///     (a: (two: 4, three:3))
///   ) == (a:(one:1, two:4, three:3), b: 2)`
/// )
///
/// Based on work by #{sym.at + "johannes-wolf"} for #link("https://github.com/johannes-wolf/typst-canvas/", "johannes-wolf/typst-canvas").
///
/// - ..dicts (dictionary): Dictionaries to merge.
/// -> dictionary
#let dict-merge(..dicts) = {
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

/// Creats a function to extract values from an argument sink #arg[args].
///
/// The resulting function takes any number of positional and
/// named arguments and creates a dictionary with values from
/// `args.named()`. Positional arguments to the function are
/// only present in the result, if they are present in `args.named()`.
/// Named arguments are always present, either with their value
/// from `args.named()` or with the provided value as a fallback.
///
/// If a #arg[prefix] is specified, only keys with that prefix will
/// be extracted from #arg[args]. The resulting dictionary will have
/// all keys with the prefix removed, though.
/// #sourcecode[```typ
/// #let my-func( ..options, title ) = block(
///     ..get.args(options)(
///         "spacing", "above", "below",
///         width:100%
///     )
/// )[
///     #text(..get.args(options, prefix:"text-")(
///         fill:black, size:0.8em
///     ), title)
/// ]
///
/// #my-func(
///     width: 50%,
///     text-fill: red, text-size: 1.2em
/// )[#lorem(5)]
/// ```]
///
/// // Tests
/// #utest(
///   scope:(
///     fun: (..args) => get.args(args)("a", b:4),
///     fun2: (..args) => get.args(args, prefix:"pre-")("a", b:4)
///   ),
///   `fun(a:1, b:2) == (a:1, b:2)`,
///   `fun(a:1) == (a:1, b:4)`,
///   `fun(b:2) == (b:2)`,
///   `fun2(pre-a:1, pre-b:2) == (a:1, b:2)`,
///   `fun2(pre-a:1, b:2) == (a:1, b:4)`,
///   `fun2(pre-b:2) == (b:2)`
/// )
///
/// - args (arguments): Argument of a function.
/// - prefix (str): A prefix for the argument keys to extract.
/// -> dictionary
#let args(
  args,
  prefix: "",
) = (
  (..keys) => {
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
)

/// Recursively extracts the text content of #arg[element].
///
/// If #arg[element] has children, all child elements are converted
/// to text and joined with #arg[sep].
///
/// // Tests
/// #utest(
///   `get.text([Hello World!]) == "Hello World!"`,
///   `get.text(list([Hello], [World!]), sep:"-") == "Hello-World!"`,
///   `get.text(5) == "5"`,
///   `get.text(5.3) == "5.3"`,
///   `get.text((:)) == ""`,
///   `get.text(()) == ""`,
/// )
///
/// - element (any)
/// - sep (str, content)
/// -> str
#let text(element, sep: "") = {
  if type(element) == content {
    if element.has("text") {
      element.text
    } else if element.has("children") {
      element.children.map(text).join(sep)
    } else if element.has("child") {
      text(element.child)
    } else if element.has("body") {
      text(element.body)
    } else if repr(element.func()) == "space" {
      " "
    } else {
      ""
    }
  } else if type(element) in ("array", "dictionary") {
    return ""
  } else {
    str(element)
  }
}

/// Returns the color of #arg[stroke].
/// If no color information is available, `default` is used.
///
/// Compared to `stroke.paint`, this function will return a
/// color for any possible stroke definition (length, dictionary ...).
///
/// Based on work by #{sym.at + "PgBiel"} for #link("https://github.com/PgBiel/typst-tablex", "PgBiel/typst-tablex").
///
/// // Tests
/// #utest(
///   `get.stroke-paint(2pt + green) == green`,
///   `get.stroke-paint(2pt) == black`,
///   `get.stroke-paint(red) == red`,
///   `get.stroke-paint((thickness:4pt), default:blue) == blue`,
///   `get.stroke-paint((paint:yellow), default:blue) == yellow`
/// )
///
/// - stroke (length, color, dictionary, stroke): The stroke value.
/// - default (color): A default color to use.
/// -> color
#let stroke-paint(stroke, default: black) = {
  let paint = std.stroke(stroke).paint
  if paint == auto {
    return default
  } else {
    return paint
  }
}

/// Returns the thickness of #arg[stroke].
/// If no thickness information is available, `default` is used.
///
/// Compared to `stroke.thickness`, this function will return a
/// thickness for any possible stroke definition (length, dictionary ...).
///
/// // Tests
/// #utest(
///   `get.stroke-thickness(2pt + green) == 2pt`,
///   `get.stroke-thickness(2pt) == 2pt`,
///   `get.stroke-thickness(red) == 1pt`,
///   `get.stroke-thickness((thickness:4pt), default:5pt) == 4pt`,
///   `get.stroke-thickness((paint:yellow), default:5pt) == 5pt`
/// )
///
/// - stroke (length, color, dictionary, stroke): The stroke value.
/// - default (length): A default thickness to use.
/// -> length
#let stroke-thickness(stroke, default: 1pt) = {
  let thickness = std.stroke(stroke).thickness
  if thickness == auto {
    return default
  } else {
    return thickness
  }
}

/// Converts #arg[stroke] into a dictionary.
///
/// The dictionary will always have the keys `thickness`,
/// `paint`, `dash`, `cap` and `join`. If `stroke` is a dictionary
/// itself, all key/value-pairs are copied to the resulting stroke.
/// Any named arguments in `overrides` will override the previous values:
/// #codesnippet[```typ
/// #let stroke = get.stroke-dict(2pt + red, cap:"square")
/// ```]
///
/// // Tests
/// #utest(
///   `get.stroke-dict(2pt + green) == (
///     thickness: 2pt,
///     paint: green,
///     dash: "solid",
///     cap: "round",
///     join: "round"
///   )`,
/// )
///
/// - stroke (length, color, dictionary, stroke): A stroke value.
/// - ..overrides (any): Overrides for the stroke.
/// -> dictionary
#let stroke-dict(stroke, ..overrides) = {
  let dict = (
    paint: stroke-paint(stroke),
    thickness: stroke-thickness(stroke),
    dash: "solid",
    cap: "round",
    join: "round",
  )
  if type(stroke) == dictionary {
    dict = dict + stroke
  }
  return dict + overrides.named()
}

/// Returns the inset (or outset) in a given #arg[direction], ascertained from #arg[inset].
///
/// // Tests
/// #utest(
///   `get.inset-at(left, 4pt) == 4pt`,
///   `get.inset-at(left, (left: 4pt)) == 4pt`,
///   `get.inset-at(left, (x: 4pt)) == 4pt`,
///   `get.inset-at(left, (right: 4pt)) == 0pt`,
///   `get.inset-at(left, (right: 4pt), default:5pt) == 5pt`,
///   `get.inset-at(right, (right: 4pt), default:5pt) == 4pt`
/// )
///
/// - direction (str, alignment): The direction to get.
/// - inset (length, dictionary): The inset value.
/// - default (length): A default value.
/// -> length
#let inset-at(direction, inset, default: 0pt) = {
  direction = repr(direction) // allows use of alignment values
  if type(inset) == dictionary {
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

/// Creates a dictionary usable as an inset (or outset) argument.
///
/// The resulting dictionary is guaranteed to have the keys `top`,
/// `left`, `bottom` and `right`. If `inset` is a dictionary itself,
/// all key/value-pairs are copied to the resulting inset.
/// Any named arguments in `overrides` will override the previous values.
///
/// // Tests
/// #utest(
///   `get.inset-dict(4pt) == (right:4pt, left:4pt, top:4pt, bottom:4pt)`
/// )
///
/// - inset (length, dictionary): The base inset value.
/// - ..overrides (any): Overrides for the inset.
/// -> dictionary
#let inset-dict(inset, ..overrides) = {
  let dict = (
    top: inset-at(top, inset),
    bottom: inset-at(bottom, inset),
    left: inset-at(left, inset),
    right: inset-at(right, inset),
  )
  if type(inset) == dictionary {
    dict = dict + inset
  }
  return dict + overrides.named()
}

/// Returns the alignment along the x-axis from #arg[align].
///
/// If none is present, #arg[default] is returned.
/// #codesnippet[```typc
/// get.x-align(top + center) // center
/// ```]
///
/// // Tests
/// #utest(
///  `get.x-align(top + center) == center`,
///   `get.x-align(top) == left`,
///   `get.x-align(center) == center`
/// )
///
/// - align (alignment, 2d alignment): The alignment to get the x-alignment from.
/// - default (alignment): A default alignment.
/// -> alignment
#let x-align(align, default: left) = {
  if std.type(align) == alignment and align.x != none {
    return align.x
  } else {
    return default
  }
}

/// Returns the alignment along the y-axis from #arg[align].
///
/// If none is present, #arg[default] is returned.
/// #codesnippet[```typc
/// get.y-align(top + center) // top
/// ```]
///
/// // Tests
/// #utest(
///   `get.y-align(top + center) == top`,
///   `get.y-align(top) == top`,
///   `get.y-align(center) == top`
/// )
///
/// - align (alignment, 2d alignment): The alignment to get the y-alignment from.
/// - default (alignment): A default alignment.
/// -> alignment
#let y-align(align, default: top) = {
  if std.type(align) == alignment and align.y != none {
    return align.y
  } else {
    return default
  }
}
