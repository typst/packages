#import "numbering.typ": _deixis-check-page-numbering
#import "state.typ": *
#import "../render/body.typ": *
#import "../routing/path.typ": *
#import "../routing/spec.typ": _deixis-route-spec, _deixis-route-record
#import "utils.typ" as deixis-utils
#import "styles.typ": _deixis-normalize-stroke

/// --------------------
/// Factory Defaults
/// --------------------

#let deixis-mark-types = ("inline-mark", "phantom-mark", "region-mark")
#let deixis-note-types = ("footnote", "endnote", "margin-note", "inset-note", "inline-note", "connection")
#let deixis-note-components = ("mark", "body", "connector")

#let deixis-factory-defaults = (
  numbering: "1",
  // 1. Note Content Styling
  marker-style: (endnote: (mark: it => super(it), body: it => it), rest: it => super(it)),
  body-style: (inline-note: it => it, endnote: it => it, rest: _deixis-default-footnote-style),
  backlink: false,
  // 2. Spacing
  separator: (footnote: line(length: 30%, stroke: 0.5pt), rest: none),
  clearance: 1em,
  indent: (footnote: 1em, rest: 0pt),
  gap: (endnote: 1em, rest: 0.5em),
  marker-gap: (footnote: 0.05em, endnote: 0.75em, rest: 0.25em),
  // 3. Styling
  marker-position: (inline-mark: right, region-mark: top + right, rest: none),
  inline-mode: "box",
  stroke: 0.5pt + _deixis-default-accent,
  fill: (inline-mark: _deixis-default-accent.transparentize(94%), region-mark: _deixis-default-accent.transparentize(94%), rest: none),
  radius: 0.2em,
  // 4. Specific Layouts
  margin-layout: "adaptive",
  min-margin-width: 2cm,
  side-strategy: auto,
  mark-align: auto,
  mark-align-strictness: "none",
  spillover: true,
  overflow: "allow",
  region-shape: deixis-rect-region,
  layer: (inset-note: "flow", footnote: "flow", rest: "foreground"),
  z-index: 0,
  // 5. Engines
  render-single: (
    footnote: deixis-aligned-render-single,
    endnote: deixis-aligned-render-single,
    rest: deixis-native-render-single,
  ),
  render-group: (
    footnote: deixis-aligned-render-group,
    endnote: deixis-grid-render-group,
    rest: deixis-native-render-group,
  ),
  container-func: (
    inline-note: deixis-alert-container,
    inset-note: deixis-rect-container,
    rest: deixis-plain-container,
  ),
)

#let deixis-scoping-keys = deixis-mark-types + deixis-note-types + deixis-note-components + ("rest", "nodes")

#let deixis-param-schema = (
  render-single: (function,),
  render-group: (function,),
  container-func: (function, str),
  body-style: (function,),
  marker-style: (function,),
  body-marker-style: (function, auto),
  region-shape: (function,),
  backlink: (bool, "always", "none", "never", "multiple", auto),
  marker-position: ("left", "right", alignment, dictionary, auto),
  inline-mode: ("box", "highlight", "underline", "parentheses", "text-fill", "none", auto, none),
  margin-layout: ("adaptive", "flow", "exact", function, auto),
  side: ("inside", "outside", "left", "right", auto),
  side-strategy: ("nearest", "strict", auto),
  mark-align: ("top", "horizon", "bottom", alignment, dictionary, auto),
  mark-align-strictness: ("loose", "strict", "none", auto),
  spillover: (bool, auto),
  overflow: ("allow", "error", auto),
  padding: ("text", auto, none, length, dictionary),
  layer: ("foreground", "background", "flow", auto),
  z-index: (int, auto),
)

#let deixis-auto-fallbacks = (
  marker-style: it => super(it),
  body-style: it => it,
  marker-position: top + right,
  inline-mode: "box",
  indent: 0pt,
  gap: 0.5em,
  marker-gap: 0.25em,
  clearance: 1em,
  stroke: none,
  fill: none,
  radius: 0pt,
  margin-layout: "adaptive",
  side-strategy: "nearest",
  mark-align: "top",
  mark-align-strictness: "none",
  spillover: true,
  overflow: "allow",
  render-single: deixis-native-render-single,
  render-group: deixis-native-render-group,
)

/// --------------------
/// Parameter Resolvers
/// --------------------

#let _deixis-resolve-mark-type(mark-type, pins: none) = {
  let mark-type = if type(mark-type) == str and mark-type.ends-with("-mark") {
    mark-type.slice(0, -5)
  } else { mark-type }

  if mark-type == "region" or (mark-type == auto and type(pins) == array and pins.len() > 0) {
    "region"
  } else if mark-type == "phantom" {
    "phantom"
  } else if mark-type in ("inline", auto) {
    "inline"
  } else {
    panic("deixis: mark-type must be \"inline\", \"region\", \"phantom\". Got " + repr(mark-type))
  }
}

// A wrapper-created mark resolves numbering with its note family first, then
// its own mark type, then rest at each level: (footnote: "*") numbers footnotes.
#let _deixis-resolve-param-cascade(stack, global-val, accent, local-val, param-key, note-type, component: auto, with-origin: false, family: none) = {
  // Single-role options resolve their own component even when a call site has
  // no shared mark/body/connector value to split. Head maps and margin alignment
  // pairs are deliberately absent: their mark/body keys describe endpoints.
  let component = if component != auto { component }
    else if param-key in ("numbering", "marker-position", "inline-mode", "region-shape") { "mark" }
    else if param-key in ("body-style", "backlink", "separator", "clearance", "indent", "gap", "marker-gap",
      "margin-layout", "min-margin-width", "side", "side-strategy", "mark-align-strictness",
      "spillover", "overflow", "render-single", "render-group", "container-func") { "body" }
    else if param-key == "connector" { "connector" }
    else { auto }
  let unroll(current-val, origin) = {
    if type(current-val) != dictionary { return current-val }
    // An empty literal radius/position/head/connector record must not select
    // factory settings through the vacuous "all keys are scopes" condition.
    if current-val.len() == 0 and param-key in ("stroke", "radius", "marker-position", "mark-align", "connector") {
      return current-val
    }
    // 0.1 named the connector component `link`; nothing else uses that key
    // beside component/type scopes, so diagnose it instead of a native value.
    assert(not ("link" in current-val and current-val.keys().all(k => k == "link" or k in deixis-scoping-keys)),
      message: "deixis: The link component was renamed in 0.2; use connector, as in stroke: (body: ..., connector: ...).")
    assert("sidenote" not in current-val,
      message: "deixis: sidenote is a margin-note preset, not a configuration type. Use margin-note: (...) settings.")

    let is-scoping = true
    let has-note-type = false
    let has-component = false
    let has-rest = false

    for k in current-val.keys() {
      if k not in deixis-scoping-keys {
        is-scoping = false
        break
      }
      if k in (deixis-mark-types + deixis-note-types) { has-note-type = true }
      if k in deixis-note-components or k == "nodes" { has-component = true }
      if k == "rest" { has-rest = true }
    }

    if is-scoping {
      if has-note-type and has-component {
        panic(
          "deixis: You cannot mix note-type keys (e.g., 'margin-note') and component keys (e.g., 'mark') at the same level. Nest them: margin-note: (mark: ...)",
        )
      }

      if has-note-type and origin == "local" {
        panic("deixis: Note-type scoping is not allowed on local note calls. Use #deixis-set to configure note types.")
      }

      if has-rest and not has-note-type and not has-component {
        if origin == "local" {
          has-component = true // Locally, 'rest' means "the rest of the components"
        } else {
          has-note-type = true // On the stack/factory, 'rest' means "the rest of the note types"
        }
      }

      if has-component and not has-note-type and component == auto {
        return current-val
      } else {
        let match-found = false
        let specific-val = none

        if family != none and family in current-val {
          specific-val = current-val.at(family)
          match-found = true
        } else if note-type in current-val {
          specific-val = current-val.at(note-type)
          match-found = true
        } else if component != auto {
          if component in current-val {
            specific-val = current-val.at(component)
            match-found = true
          } else if component in ("mark", "body") and "nodes" in current-val {
            specific-val = current-val.at("nodes")
            match-found = true
          }
        }

        if not match-found and "rest" in current-val {
          specific-val = current-val.at("rest")
          match-found = true
        }

        if match-found { return unroll(specific-val, origin) } else { return auto }
      }
    }
    return current-val
  }

  let resolve-cascade() = {
    // local (highest priority)
    if local-val != auto {
      let u = unroll(local-val, "local")
      if u != auto { return (value: u, origin: "local") }
    }

    // stack (#deixis-set)
    if stack.len() > 0 {
      for sv in stack.rev() {
        if sv != auto {
          let u = unroll(sv, "stack")
          if u != auto { return (value: u, origin: "stack") }
        }
      }
    }

    if global-val != auto {
      let gv = global-val
      if gv != auto {
        let u = unroll(gv, "global")
        if u != auto { return (value: u, origin: "global") }
      }
    }

    // factory defaults (lowest priority)
    let fv = deixis-factory-defaults.at(param-key, default: auto)
    if fv != auto {
      let u = unroll(fv, "factory")
      if u != auto {
        if accent != none {
          if param-key == "stroke" { u = 0.5pt + accent }
          if param-key == "fill" and u != none { u = accent.transparentize(94%) }
          if param-key == "marker-style" {
            let original = u
            u = it => text(fill: accent, original(it))
          }
        }
        return (value: u, origin: "factory")
      }
    }

    (value: auto, origin: "fallback")
  }

  let resolution = resolve-cascade()
  let origin = resolution.origin
  let final-val = resolution.value

  if final-val == auto and param-key in deixis-auto-fallbacks {
    final-val = deixis-auto-fallbacks.at(param-key)
  }

  if param-key == "numbering" and type(final-val) == dictionary {
    _deixis-check-page-numbering(final-val)
  }

  if param-key == "container-func" { final-val = _deixis-resolve-container(final-val) }

  // type & schema validation
  if param-key in deixis-param-schema {
    let allowed = deixis-param-schema.at(param-key)
    let is-valid = allowed.any(a => if type(a) == type { type(final-val) == a } else { final-val == a })

    if not is-valid {
      panic(
        "deixis: Invalid value '"
          + repr(final-val)
          + "' for parameter '"
          + param-key
          + "'.\nAllowed values/types are: "
          + repr(allowed),
      )
    }
  }

  if with-origin { (value: final-val, origin: origin) } else { final-val }
}

// Project settings before the pure cascade: no registry or unrelated options.
#let _deixis-resolve-typed-param(sys, local-val, param-key, note-type, component: auto, with-origin: false, family: none) = {
  let stack = if sys == none { () } else { sys.stack.map(level => level.at(param-key, default: auto)) }
  let global-val = if sys == none { auto } else { sys.at(param-key, default: auto) }
  let accent = if sys == none { none } else { sys.at("annotation-accent", default: none) }
  _deixis-resolve-param-cascade(stack, global-val, accent, local-val, param-key, note-type,
    component: component, with-origin: with-origin, family: family)
}

#let _deixis-resolve-component-styles(sys, note-type, component: auto, ..args) = {
  assert(args.pos().len() == 0)
  let resolved = (:)
  let origins = (:)
  for (name, val) in args.named() {
    let resolution = _deixis-resolve-typed-param(sys, val, name, note-type,
      component: component, with-origin: component == "body")
    let resolved-val = if component == "body" { resolution.value } else { resolution }
    if component == "body" { origins.insert(name, resolution.origin) }
    if name == "stroke" { resolved-val = _deixis-normalize-stroke(resolved-val) }
    resolved.insert(name, resolved-val)
  }
  // Preset defaults must distinguish explicit none from factory values. The
  // renderer removes this bookkeeping before passing native styles to callbacks.
  if component == "body" { resolved.insert("_deixis-origins", origins) }

  return resolved
}

#let _deixis-resolve-mark-styles = _deixis-resolve-component-styles.with(component: "mark")

#let _deixis-resolve-body-styles = _deixis-resolve-component-styles.with(component: "body")

#let _deixis-resolve-connector-styles = _deixis-resolve-component-styles.with(component: "connector")

// Preserve incremental updates within one dictionary representation, but never
// combine a native value with scope keys or note types with component keys.
// An explicit empty dictionary clears the previous value at that level.
#let _deixis-merge-config(old, new, skip-auto: false) = {
  if skip-auto and new == auto { return old }
  if type(old) != dictionary or type(new) != dictionary or new.len() == 0 { return new }
  // Complete route records replace atomically; changing algorithm must not
  // inherit another algorithm's settings or supply an omitted kind implicitly.
  if _deixis-route-record(old) or _deixis-route-record(new) { return new }
  // Page-numbering records are literal values: an omitted pattern means "1",
  // never the pattern of an enclosing record.
  if "restart" in old or "restart" in new { return new }
  let scopes(value) = (
    scoped: value.keys().all(k => k in deixis-scoping-keys),
    types: value.keys().any(k => k in (deixis-mark-types + deixis-note-types)),
    components: value.keys().any(k => k in deixis-note-components or k == "nodes"),
  )
  let a = scopes(old)
  let b = scopes(new)
  if a.scoped != b.scoped or (a.types and b.components) or (a.components and b.types) { return new }
  let result = old
  for (key, value) in new {
    if skip-auto and value == auto { continue }
    result.insert(key, _deixis-merge-config(old.at(key, default: auto), value, skip-auto: skip-auto))
  }
  result
}

// Merges a base style dictionary with an override local style dictionary.
// - non-auto values in `override` replace values in `base`.
// - `auto` values in `override` fall back to `base`.
// - Performs a deep merge for dictionaries to safely handle component-scoped arguments.
#let _deixis-merge-styles(base, override, allowed-keys: auto) = {
  let _is-allowed(k) = if type(allowed-keys) != array {
    true
  } else {
    k in allowed-keys
  }

  let result = if type(base) == dictionary {
    if type(allowed-keys) != array {
      base
    } else {
      let filtered-base = (:)
      for (k, v) in base {
        if _is-allowed(k) {
          filtered-base.insert(k, v)
        }
      }
      filtered-base
    }
  } else { (:) }
  if type(override) != dictionary { return result }

  for (k, v) in override {
    if not _is-allowed(k) {
      continue
    }
    if v == auto {
      if k not in base {
        result.insert(k, auto)
      }
    } else if type(v) == dictionary and k in base and type(base.at(k)) == dictionary {
      result.insert(k, _deixis-merge-config(base.at(k), v, skip-auto: true))
    } else {
      result.insert(k, v)
    }
  }

  return result
}
