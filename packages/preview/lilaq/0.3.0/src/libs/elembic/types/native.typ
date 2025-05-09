// Typst-native types.
#import "../data.typ": type-key
#import "base.typ": base-typeinfo, ok, err

// Tiling type (renamed in Typst 0.13.0)
#let tiling = if sys.version < version(0, 13, 0) { pattern } else { tiling }

#let native-base = (
  ..base-typeinfo,
  type-kind: "native",
)

// Generic typeinfo for a native type.
// PROPERTY: if type key is native, then output has the native type,
// and input has a list of native types that can be cast to it.
#let generic-typeinfo(native-type) = {
  assert(type(native-type) == type(str), message: "internal error: not a type")

  (
    ..native-base,
    name: str(native-type),
    input: (native-type,),
    output: (native-type,),
    data: native-type,
  )
}

// Castable types

#let content_ = (
  ..native-base,
  name: str(content),
  input: (content, str, symbol),
  output: (content,),
  data: content,
  cast: x => [#x],
  default: ([],),
)
#let float_ = (
  ..native-base,
  name: str(float),
  input: (float, int),
  output: (float,),
  data: float,
  cast: float,
  default: (0.0,),
)
#let stroke-keys = ("paint", "thickness", "cap", "join", "dash", "miter-limit")
#let stroke_ = (
  ..native-base,
  name: str(stroke),
  input: (stroke, length, color, gradient, tiling, dictionary),
  output: (stroke,),
  data: stroke,
  cast: stroke,
  check: v => type(v) != dictionary or v.keys().all(k => k in stroke-keys),
  default: (stroke(),),
  // Allow specifying e.g. 4pt in one set rule, red in the other => 4pt + red in the end
  fold: (outer, inner) => {
    // Can't sum stroke with stroke, so can't optimize with 'fold: auto' :(
    stroke(
      paint: if inner.paint == auto { outer.paint } else { inner.paint },
      thickness: if inner.thickness == auto { outer.thickness } else { inner.thickness },
      cap: if inner.cap == auto { outer.cap } else { inner.cap },
      join: if inner.join == auto { outer.join } else { inner.join },
      dash: if inner.dash == auto { outer.dash } else { inner.dash },
      miter-limit: if inner.miter-limit == auto { outer.miter-limit } else { inner.miter-limit },
    )
  },
)
#let relative_ = (
  ..native-base,
  name: str(relative),
  input: (relative, length, ratio),
  output: (relative,),
  data: relative,
  cast: x => x + 0% + 0pt,
  default: (0% + 0pt,),
)
#let function_ = (
  ..native-base,
  name: str(function),
  // Would add symbol as well, but missing a reliable way to check for callable symbols
  input: (type, function),
  output: (type, function,),
  data: function,
)

// Folding types (also includes stroke above)
#let array_ = (
  ..native-base,
  name: str(array),
  input: (array,),
  output: (array,),
  data: array,
  default: ((),),

  // Array fields are added together by default.
  fold: auto,
)

#let alignment_ = (
  ..native-base,
  name: str(alignment),
  input: (alignment,),
  output: (alignment,),
  data: alignment,
  fold: (outer, inner) => if inner.axis() == none or outer.axis() == inner.axis() {
    // If axis A == axis B, we override. For example, left -> right. (No sum)
    // Same if both are none (2D alignments), in which case inner fully overrides as well (left + top -> center + bottom).
    // In addition, if inner axis is none (it is a 2D alignment), it overrides in both ways (left -> right + top).
    inner
  } else if outer.axis() == none {
    // Here, we know that inner isn't 2D, so either outer is 2D or both have different axes.
    // If outer is 2D and inner is 1D, inner replaces its axis in outer, but the other axis is kept.
    if inner.axis() == "horizontal" {
      inner + outer.y
    } else {
      outer.x + inner
    }
  } else {
    // Both are 1D and have distinct axes, so we just sum.
    // left and top => left + top
    // bottom and right => right + bottom
    inner + outer
  }
)

// Simple types (no casting)

#let str_ = (
  ..native-base,
  name: str(str),
  input: (str,),
  output: (str,),
  data: str,
  default: ("",)
)
#let bool_ = (
  ..native-base,
  name: str(bool),
  input: (bool,),
  output: (bool,),
  data: bool,
  default: (false,)
)
#let dict_ = (
  ..native-base,
  name: str(dictionary),
  input: (dictionary,),
  output: (dictionary,),
  data: dictionary,
  default: ((:),),
)
#let int_ = (
  ..native-base,
  name: str(int),
  input: (int,),
  output: (int,),
  data: int,
  default: (0,),
)
#let color_ = (
  ..native-base,
  name: str(color),
  input: (color,),
  output: (color,),
  data: color,
)
#let gradient_ = (
  ..native-base,
  name: str(gradient),
  input: (gradient,),
  output: (gradient,),
  data: gradient,
)
#let tiling_ = (
  ..native-base,
  name: str(tiling),
  input: (tiling,),
  output: (tiling,),
  data: tiling,
)
#let datetime_ = (
  ..native-base,
  name: str(datetime),
  input: (datetime,),
  output: (datetime,),
  data: datetime,
)
#let angle_ = (
  ..native-base,
  name: str(angle),
  input: (angle,),
  output: (angle,),
  data: angle,
  default: (0deg,),
)
#let ratio_ = (
  ..native-base,
  name: str(ratio),
  input: (ratio,),
  output: (ratio,),
  data: ratio,
  default: (0%,),
)
#let length_ = (
  ..native-base,
  name: str(length),
  input: (length,),
  output: (length,),
  data: length,
  default: (0pt,),
)
#let fraction_ = (
  ..native-base,
  name: str(fraction),
  input: (fraction,),
  output: (fraction,),
  data: fraction,
  default: (0fr,),
)
#let duration_ = (
  ..native-base,
  name: str(duration),
  input: (duration,),
  output: (duration,),
  data: duration,
  default: (duration(seconds: 0),),
)
#let type_ = (
  ..native-base,
  name: str(type),
  input: (type,),
  output: (type,),
  data: type,
)
#let arguments_ = (
  ..native-base,
  name: str(arguments),
  input: (arguments,),
  output: (arguments,),
  data: arguments,
  default: (arguments(),),
)
#let bytes_ = (
  ..native-base,
  name: str(bytes),
  input: (bytes,),
  output: (bytes,),
  data: bytes,
  default: (bytes(()),),
)
#let version_ = (
  ..native-base,
  name: str(version),
  input: (version,),
  output: (version,),
  data: version,
  default: (version(0, 0, 0),),
)

// None / auto

#let none_ = (
  ..native-base,
  name: "none",
  input: (type(none),),
  output: (type(none),),
  data: type(none),
  default: (none,)
)
#let auto_ = (
  ..native-base,
  name: "auto",
  input: (type(auto),),
  output: (type(auto),),
  data: type(auto),
  default: (auto,)
)

// Return the typeinfo for a native type.
#let typeinfo(t) = {
  let out = if t == content {
    content_
  } else if t == int {
    int_
  } else if t == bool {
    bool_
  } else if t == float {
    float_
  } else if t == type(none) {
    none_
  } else if t == type(auto) {
    auto_
  } else if t == dictionary {
    dict_
  } else if t == array {
    array_
  } else if t == str {
    str_
  } else if t == color {
    color_
  } else if t == gradient {
    gradient_
  } else if t == datetime {
    datetime_
  } else if t == duration {
    duration_
  } else if t == function {
    function_
  } else if t == relative {
    relative_
  } else if t == stroke {
    stroke_
  } else if t == tiling {
    tiling_
  } else if t == type {
    type_
  } else if t == angle {
    angle_
  } else if t == alignment {
    alignment_
  } else if t == ratio {
    ratio_
  } else if t == length {
    length_
  } else if t == fraction {
    fraction_
  } else if t == arguments {
    arguments_
  } else if t == bytes {
    bytes_
  } else if t == version {
    version_
  } else {
    generic-typeinfo(t)
  }

  (true, out)
}
