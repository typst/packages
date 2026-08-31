// `_brand.yml` parsing: semantic colour roles, palette alias chains,
// light/dark variants, and font families. brand.yml is a tool-independent
// standard (https://posit-dev.github.io/brand-yml/), not a Quarto feature.
//
// Reading the file is Typst's job (`yaml()` resolves relative paths against
// the calling file, so the library cannot do it on the caller's behalf). What
// lives here is the part Typst has no answer for: brand.yml lets a semantic
// role name a palette entry, lets a palette entry alias another entry, and
// lets any of them carry `light` / `dark` variants.
//
// `_walk-alias` is pure and returns a verdict record rather than panicking, so
// the alias walk (including the cycle guard) is unit-testable. Typst cannot
// catch a panic, so only pure builders can be asserted on.

#import "errors.typ": fail, fail-enum, fail-type, quote-each

// Every message names the public entry point, not this module.
#let _SCOPE = "theme-brand"

#let _HEX-RE = regex(
  "^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$",
)

// Roles read into the theme, in brand.yml's own declaration order.
#let _SEMANTIC-ROLES = (
  "foreground",
  "background",
  "primary",
  "secondary",
  "tertiary",
  "success",
  "info",
  "warning",
  "danger",
)

// Roles feeding the derived discrete palette. `foreground` / `background` are
// chrome, not data ink, so they stay out.
#let _PALETTE-ROLES = _SEMANTIC-ROLES.slice(2)

// Pick the `light` or `dark` side of a value. A plain value carries no
// variants and is used in both modes. A one-sided dictionary falls back to the
// side it does have: dropping the role would leave the plot unthemed, and a
// brand that declares only one side means it to apply.
//
// A dictionary carrying neither side is handed back whole. Raising it here
// would name no role, because the role is the caller's to know, and would make
// the walk below panic from inside a function documented not to.
#let _pick-variant(value, mode) = {
  if type(value) != dictionary { return value }
  if mode in value { return value.at(mode) }
  let other = if mode == "light" { "dark" } else { "light" }
  if other in value { return value.at(other) }
  value
}

// Walk a colour token to a concrete colour, following palette aliases.
//
// Pure: returns `(ok: true, colour: ...)` or `(ok: false, reason: ..., token:
// ..., chain: ...)` with `reason` one of "type", "variant", "empty", "hex",
// "cycle", "unknown". `_pick-variant` is re-applied at every hop because a
// palette entry may itself carry light/dark variants. `seen` grows by one per
// hop over a finite palette, so the walk terminates; membership in it is the
// cycle guard, and the chain it accumulates lets the caller name the actual
// cycle.
#let _walk-alias(token, palette, mode) = {
  let seen = ()
  let raw = token
  let cur = _pick-variant(raw, mode)
  while true {
    if type(cur) == color { return (ok: true, colour: cur) }
    if type(cur) == dictionary {
      // Which of the two mistakes this is turns on the value the pick was
      // handed, not on the one it answered.
      //
      // A value naming neither side is a variant block whose keys are
      // misspelled, and naming those keys is the whole of the advice. A value
      // that does name a side was read, so what came back is whatever that side
      // holds: the fault is its type, and asking for a `light` key would demand
      // the very key the role already has.
      let named-a-side = (
        type(raw) == dictionary and ("light" in raw or "dark" in raw)
      )
      return (
        ok: false,
        reason: if named-a-side { "type" } else { "variant" },
        token: cur,
        chain: seen,
      )
    }
    if type(cur) != str {
      return (ok: false, reason: "type", token: cur, chain: seen)
    }
    let t = cur.trim()
    if t == "" { return (ok: false, reason: "empty", token: cur, chain: seen) }
    // Validate before `rgb()` so a malformed value keeps the house grammar
    // instead of leaking Typst's own panic message.
    if t.match(_HEX-RE) != none { return (ok: true, colour: rgb(t)) }
    if t.starts-with("#") {
      return (ok: false, reason: "hex", token: t, chain: seen)
    }
    if seen.contains(t) {
      return (ok: false, reason: "cycle", token: t, chain: seen + (t,))
    }
    seen.push(t)
    let next = palette.at(t, default: none)
    if next == none {
      return (ok: false, reason: "unknown", token: t, chain: seen)
    }
    raw = next
    cur = _pick-variant(raw, mode)
  }
}

// The palette hops a role walked before it failed, or nothing when the role
// carried the offending value itself.
#let _through(chain) = if chain.len() == 0 { "" } else {
  ", reached through " + chain.map(repr).join(" -> ")
}

// Panicking wrapper over `_walk-alias`, naming the role that failed.
#let _resolve-token(token, palette, mode, role) = {
  let res = _walk-alias(token, palette, mode)
  if res.ok { return res.colour }
  let name = "color." + role
  if res.reason == "type" {
    fail-type(
      _SCOPE,
      name,
      res.token,
      "a hex colour string or a `color.palette` entry name",
    )
  } else if res.reason == "variant" {
    // Bespoke rather than `fail-type`, whose "must be" reads as a demand for a
    // dictionary from a value that already is one. The chain is carried for the
    // same reason "cycle" carries it: the role points at the palette entry, and
    // the entry is what has to change.
    fail(
      _SCOPE,
      name
        + " declares variants but names neither `light` nor `dark`"
        + _through(res.chain)
        + "; got "
        + repr(res.token),
      hint: "A colour with no variants is written as the value itself, not as"
        + " a dictionary.",
    )
  } else if res.reason == "empty" {
    fail(
      _SCOPE,
      name + " is empty",
      hint: "Give it a hex colour such as \"#e94c3d\", or drop the key.",
    )
  } else if res.reason == "hex" {
    fail-type(
      _SCOPE,
      name,
      res.token,
      "a 3-, 4-, 6-, or 8-digit hex colour such as \"#e94c3d\"",
      hint: "CSS colour functions and named colours are not supported.",
    )
  } else if res.reason == "cycle" {
    fail(
      _SCOPE,
      name
        + " resolves through an alias cycle: "
        + res.chain.map(repr).join(" -> "),
      hint: "Point one entry in the cycle at a hex colour.",
    )
  } else {
    fail(
      _SCOPE,
      name
        + " names unknown palette entry "
        + repr(res.token)
        + "; available entries: "
        + quote-each(palette.keys()),
    )
  }
}

// Validate the top-level shape and return the `color` block and its palette.
#let _colour-block(brand, mode) = {
  if type(brand) != dictionary {
    fail-type(
      _SCOPE,
      "brand",
      brand,
      "a dictionary parsed from a _brand.yml",
      hint: "Pass yaml(\"_brand.yml\"); the path resolves against your own"
        + " file, not the package.",
    )
  }
  if mode not in ("light", "dark") {
    fail-enum(_SCOPE, "mode", mode, ("light", "dark"))
  }
  let block = brand.at("color", default: (:))
  if type(block) != dictionary {
    fail-type(_SCOPE, "color", block, "a dictionary")
  }
  let palette = block.at("palette", default: (:))
  if type(palette) != dictionary {
    fail-type(
      _SCOPE,
      "color.palette",
      palette,
      "a dictionary mapping names to colours",
    )
  }
  (block: block, palette: palette)
}

// Resolve every semantic colour role the brand declares.
//
// A role the brand omits is omitted from the result; the caller supplies its
// own default. A role that is present but malformed panics: absent is never an
// error, present-but-wrong always is.
#let brand-colours(brand, mode) = {
  let parts = _colour-block(brand, mode)
  let out = (:)
  for role in _SEMANTIC-ROLES {
    if role not in parts.block { continue }
    out.insert(
      role,
      _resolve-token(parts.block.at(role), parts.palette, mode, role),
    )
  }
  out
}

// Read a typographic role's font family, accepting both the plain-string and
// the `{family: ...}` object forms brand.yml allows.
//
// Returns `none` when the role is absent, and when it is an object that
// declares no `family` (a weight-only block is incomplete, not malformed).
// Everything else about the role -- size, line-height, weight, source, the
// `files` list -- is ignored: Typst can only use a family already available to
// the compiler, and the package has no rem-to-pt convention.
#let brand-font(brand, role) = {
  if type(brand) != dictionary {
    fail-type(
      _SCOPE,
      "brand",
      brand,
      "a dictionary parsed from a _brand.yml",
    )
  }
  let typo = brand.at("typography", default: (:))
  if type(typo) != dictionary {
    fail-type(_SCOPE, "typography", typo, "a dictionary")
  }
  if role not in typo { return none }
  let value = typo.at(role)
  if type(value) == str { return value }
  if type(value) == dictionary {
    if "family" not in value { return none }
    let family = value.at("family")
    if type(family) != str {
      fail-type(
        _SCOPE,
        "typography." + role + ".family",
        family,
        "a font family name string",
      )
    }
    return family
  }
  fail-type(
    _SCOPE,
    "typography." + role,
    value,
    "a font family name string, or a dictionary with a `family` key",
  )
}

// Derive a discrete palette from the brand's data-ink roles, over a colour
// block `brand-colours` has already resolved.
//
// De-duplication is load-bearing: brands routinely alias `info` to `secondary`
// and `warning` to `tertiary`, and a duplicate would paint two factor levels
// identically. Below two distinct colours the result is `none`, because
// `palette-at` wraps modulo, so a one-colour palette paints every level the
// same and is strictly worse than the library default.
#let brand-palette-from(cols) = {
  let out = ()
  for role in _PALETTE-ROLES {
    if role not in cols { continue }
    let colour = cols.at(role)
    if out.contains(colour) { continue }
    out.push(colour)
  }
  if out.len() < 2 { none } else { out }
}
