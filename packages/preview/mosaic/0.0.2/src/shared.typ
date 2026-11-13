// Values and helpers shared by all internal Mosaic modules.
#let tag = "mosaic:0.0.2"

// Every internal state, counter, and metadata key is built from `tag`, so the
// namespace and its version bump in one place. Spelling a key literally would
// let a partial bump leave two versions addressing the same deck, which reads
// as silently empty state rather than as an error.
#let key(name) = tag + ":" + name

#let fail(message) = assert(false, message: "mosaic: " + message)

// Typst's structural element functions have no public constructors.
#let typst-sequence = [].func()
#let typst-styled = text(red)[].func()
#let typst-space = [ ].func()

#let is-path(value) = type(value) == path or (
  type(value) == str and value != ""
)

// A canonical Mosaic record is a metadata element whose value is a dictionary
// tagged with `mosaic` and a `kind` and carrying exactly the declared keys.
// A foreign or differently-kinded value is merely not a record; a tagged
// record with the wrong key set is corrupt and fails.
#let is-record(value, kind, keys, name) = {
  if (
    type(value) != content
      or value.func() != metadata
      or type(value.value) != dictionary
      or value.value.at("mosaic", default: none) != tag
      or value.value.at("kind", default: none) != kind
  ) {
    return false
  }
  if value.value.keys().sorted() != keys {
    fail("invalid " + name + " record")
  }
  true
}

#let validate-choice(value, allowed, name) = {
  if value not in allowed {
    fail(name + " must be " + allowed.map(repr).join(", ", last: ", or "))
  }
  value
}

// A scrim is an ordinary Typst paint, so it accepts exactly what a `fill`
// accepts and needs no Mosaic-specific vocabulary of its own. One validator
// serves both the component and every layout that carries an image, so the
// spelling cannot drift between them.
#let is-paint(value) = type(value) in (color, gradient, tiling)

#let validate-scrim(value, name) = {
  if value != none and not is-paint(value) {
    fail(name + " scrim must be a color, gradient, or tiling")
  }
  value
}

#let validate-dictionary(value, name) = {
  if type(value) != dictionary {
    fail(name + " must be a dictionary")
  }
  value
}

#let validate-keys(value, allowed, name) = {
  let unknown = value.keys().filter(key => key not in allowed)
  if unknown.len() > 0 {
    fail(name + " does not accept " + repr(unknown.first()))
  }
  value
}

#let array-max(values) = if values.len() == 0 {
  1
} else {
  calc.max(..values)
}
