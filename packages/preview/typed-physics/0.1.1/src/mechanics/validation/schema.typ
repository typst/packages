#let known-declaration-kinds = (
  "ground",
  "wall",
  "ceiling",
  "ramp",
  "arc",
  "body",
  "rod",
  "pivot",
  "support",
  "pendulum",
  "pulley",
  "rope",
  "spring",
  "force",
  "torque",
  "velocity",
  "angular-velocity",
)

#let allowed-fields(kind) = if kind == "ground" {
  ("kind", "name", "length", "from", "friction", "style")
} else if kind == "wall" {
  ("kind", "name", "side", "height", "from", "friction", "style")
} else if kind == "ceiling" {
  ("kind", "name", "length", "height", "from", "friction", "style")
} else if kind == "ramp" {
  (
    "kind", "name", "angle", "length", "facing", "from", "friction",
    "symbol", "style",
  )
} else if kind == "arc" {
  (
    "kind", "name", "radius", "start-angle", "end-angle", "side", "from",
    "friction", "style",
  )
} else if kind == "body" {
  (
    "kind", "shape", "name", "mass", "on", "at", "touching", "side",
    "hanging", "drop", "half-extent-along", "half-extent-normal",
    "friction", "label", "symbol", "style", "radius-mark", "orientation",
    "solver-supported",
  )
} else if kind == "rod" {
  (
    "kind", "name", "from", "to", "length", "angle", "thickness", "mass",
    "center-of-mass", "label", "symbol", "style",
  )
} else if kind in ("pivot", "pulley") {
  ("kind", "name", "at", "radius", "style")
} else if kind == "support" {
  ("kind", "name", "at", "support-kind", "angle", "size", "style")
} else if kind == "pendulum" {
  (
    "kind", "name", "from", "length", "angle", "mass", "radius",
    "angle-label", "label", "symbol", "style",
  )
} else if kind in ("rope", "spring") {
  if kind == "rope" {
    ("kind", "name", "from", "to", "over", "style")
  } else {
    ("kind", "name", "from", "to", "coils", "width", "style")
  }
} else if kind == "force" {
  ("kind", "on", "magnitude", "angle", "at", "label", "style")
} else if kind == "torque" {
  (
    "kind", "on", "at", "magnitude", "direction", "radius", "label",
    "style",
  )
} else if kind == "velocity" {
  ("kind", "on", "magnitude", "angle", "label", "style")
} else {
  (
    "kind", "on", "magnitude", "direction", "radius", "start-angle",
    "end-angle", "label", "style",
  )
}

#let required-fields(kind) = if kind == "ground" {
  ("name", "length", "from", "friction", "style")
} else if kind == "wall" {
  ("name", "side", "height", "from", "friction", "style")
} else if kind == "ceiling" {
  ("name", "length", "height", "from", "friction", "style")
} else if kind == "ramp" {
  ("name", "angle", "length", "facing", "from", "friction", "symbol", "style")
} else if kind == "arc" {
  (
    "name", "radius", "start-angle", "end-angle", "side", "from",
    "friction", "style",
  )
} else if kind == "body" {
  allowed-fields(kind).filter(field => field != "kind")
} else if kind == "rod" {
  allowed-fields(kind).filter(field => field != "kind")
} else if kind in ("pivot", "pulley", "support", "pendulum", "rope", "spring") {
  allowed-fields(kind).filter(field => field != "kind")
} else {
  allowed-fields(kind).filter(field => field != "kind")
}

#let named-kind(kind) = kind in (
  "ground", "wall", "ceiling", "ramp", "arc", "body", "rod", "pivot",
  "support", "pendulum", "pulley", "rope", "spring",
)

#let category-of-kind(kind) = if kind in (
  "ground", "wall", "ceiling", "ramp", "arc",
) {
  "surface"
} else if kind == "body" {
  "body"
} else if kind == "pulley" {
  "pulley"
} else if kind in ("rod", "pivot", "support", "pendulum") {
  "structure"
} else if kind in ("rope", "spring") {
  "connector"
} else {
  "annotation"
}

#let default-anchor(kind) = if kind in (
  "ground", "wall", "ceiling", "ramp", "arc",
) {
  "surface"
} else {
  "center"
}

#let anchors-for-kind(kind) = if kind in ("ground", "ceiling", "arc") {
  ("start", "end", "surface")
} else if kind == "wall" {
  ("start", "end", "surface")
} else if kind == "ramp" {
  ("start", "end", "surface", "foot", "apex", "base")
} else if kind == "body" {
  ("center", "contact", "top", "bottom", "left", "right")
} else if kind == "pulley" {
  ("center", "top", "bottom", "left", "right")
} else if kind == "rod" {
  ("start", "end", "center", "center-of-mass")
} else if kind == "pendulum" {
  ("pivot", "bob", "center")
} else if kind in ("pivot", "support") {
  ("center",)
} else if kind in ("rope", "spring") {
  ("start", "end", "center")
} else {
  ()
}
