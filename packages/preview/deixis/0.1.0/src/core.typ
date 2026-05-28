#import "states.typ": *
#import "layout.typ": *
#import "utils.typ" as deixis-utils

/// --------------------
/// Factory Defaults
/// --------------------

#let deixis-mark-types = ("inline-mark", "phantom-mark", "region-mark")
#let deixis-note-types = ("footnote", "endnote", "margin-note", "sidenote", "inset-note", "inline-note")
#let deixis-note-components = ("mark", "body", "link")

#let deixis-factory-defaults = (
  numbering: "1",
  // 1. Note Content Styling
  marker-style: (endnote: (mark: it => super(it), body: it => it), rest: it => super(it)),
  body-style: (inline-note: it => it, endnote: it => it, rest: deixis-default-footnote-style),
  backlink: false,
  // 2. Spacing
  separator: (footnote: line(length: 30%, stroke: 0.5pt), rest: none),
  clearance: 1em,
  indent: (footnote: 1em, rest: 0pt),
  gap: (endnote: 1em, rest: 0.5em),
  marker-gap: (endnote: 0.75em, rest: 0.05em),
  // 3. Styling
  marker-position: (inline-mark: right, region-mark: top + right, rest: none),
  inline-mode: "box",
  stroke: 0.5pt + red,
  fill: (inline-mark: red.transparentize(95%), region-mark: red.transparentize(95%), rest: none),
  radius: 0.2em,
  link: "none",
  link-marks: "none",
  // 4. Specific Layouts
  margin-layout: "adaptive",
  min-margin-width: 2cm,
  side-strategy: auto,
  mark-align: auto,
  mark-align-strictness: "none",
  spillover: true,
  region-shape: deixis-rect-region,
  layer: "foreground",
  // 5. Engines
  render-single: (
    footnote: deixis-default-render-single,
    endnote: deixis-default-render-single,
    rest: deixis-native-render-single,
  ),
  render-group: (
    footnote: deixis-default-render-group,
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
  backlink: (bool, "always", "none", "never", "multiple", auto),
  marker-position: ("left", "right", alignment, dictionary, auto),
  inline-mode: ("box", "highlight", "underline", "parentheses", "text-fill", "none", auto, none),
  margin-layout: ("adaptive", "flow", "exact", function, auto),
  side: ("inside", "outside", "left", "right", auto),
  side-strategy: ("nearest", "strict", auto),
  mark-align: ("top", "horizon", "bottom", alignment, dictionary, auto),
  mark-align-strictness: ("loose", "strict", "none", auto),
  spillover: (bool, auto),
  link: deixis-link-types + (none, auto),
  link-marks: ("mark", "body", "both", "none", none, auto),
  padding: ("text", auto, none, length, dictionary),
  layer: ("foreground", "background", "flow", auto),
)

#let deixis-auto-fallbacks = (
  marker-style: it => super(it),
  body-style: it => it,
  marker-position: top + right,
  inline-mode: "box",
  indent: 0pt,
  gap: 0.5em,
  marker-gap: 0.05em,
  clearance: 1em,
  stroke: none,
  fill: none,
  radius: 0pt,
  link: "none",
  link-marks: "none",
  margin-layout: "adaptive",
  side-strategy: "nearest",
  mark-align: "top",
  mark-align-strictness: "none",
  spillover: true,
  render-single: deixis-native-render-single,
  render-group: deixis-native-render-group,
)

#let _deixis-check-setup-state() = if not deixis-setup-state.get() {
  panic("deixis: You must wrap your document with #show: deixis-setup-notes(..) before declaring any notes!")
}

#let _deixis-validate-target(target) = if not (
  type(target) in (str, label, int) and (type(target) != int or target <= 0)
) {
  panic("deixis: Target must be a string ID, a label, 0, or a negative integer.")
}

// Centralized helper to resolve target strings, labels, or integers.
// Returns:
// - render-id: Where should the overlay engine draw this note? If it belongs to a minipage, this is the minipage's unique ID. If it goes on the page, this evaluates to "page".
// - count-id: Which numbering sequence does this note belong to? Usually, this is the same as the render-id. However, if you use sync-counters-with, the render-id might be block-B, but the count-id becomes block-A, allowing two physical blocks to share one continuous numbering sequence!
// - inst-id: This tracks the specific rendering pass of a block to prevent infinite loops and state-stuttering during concurrent evaluations.
#let _deixis-resolve-target(sys, target) = {
  let target = if target == auto { 0 } else { target }
  let is-named = type(target) in (str, label)
  let target-str = if is-named { str(target) } else { "" }

  if is-named and target-str == "page" { return (render-id: "page", count-id: "page", inst-id: "page") }

  if type(target) == int {
    if sys.stack.len() == 0 { return (render-id: "page", count-id: "page", inst-id: "page") }
    let idx = sys.stack.len() - 1 + target
    if idx >= 0 and idx < sys.stack.len() {
      let level = sys.stack.at(idx)
      return (render-id: level.render-id, count-id: level.count-id, inst-id: level.inst-id)
    }
    return (render-id: "page", count-id: "page", inst-id: "page")
  }

  if is-named {
    let c-id = target-str
    let i-id = target-str
    if target-str in sys.blocks {
      let b = sys.blocks.at(target-str)
      c-id = b.count-id
      i-id = b.at("inst-id", default: target-str)
    }
    return (render-id: target-str, count-id: c-id, inst-id: i-id)
  }

  return (render-id: "page", count-id: "page", inst-id: "page")
}

// Queries the document metadata to find the mark data.
#let _deixis-query-mark-data(data) = {
  if type(data) != dictionary { return none }

  let internal-id = data.at("internal-id", default: none)
  if internal-id == none {
    if "mark-lbl" in data and data.mark-lbl != none {
      internal-id = str(data.mark-lbl).replace("deixis-mark-", "")
    } else if "body-lbl" in data and data.body-lbl != none {
      internal-id = str(data.body-lbl).replace("deixis-body-", "")
    }
  }

  if internal-id != none {
    let marks = query(
      selector(metadata).and(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>).or(<deixis-region-mark>)),
    )

    let match = marks.find(m => (
      type(m.value) == dictionary
        and m.value.at("internal-id", default: none) != none
        and str(m.value.internal-id) == str(internal-id)
    ))

    if match != none and match.value.at("marker-str", default: none) != none {
      return match.value
    }
  }
  return none
}

// Evaluates the final numbering string from a note registry.
// Safe to use inside context blocks for cross-module evaluation.
#let _deixis-evaluate-marker-str(reg) = {
  if type(reg) != dictionary { return none }

  // If the payload already has a computed string, use it
  if reg.at("marker-str", default: none) != none {
    return reg.marker-str
  }

  let c-marker = reg.at("marker", default: auto)
  if c-marker != auto {
    return c-marker
  }

  let c-numbering = reg.at("numbering", default: none)
  let count = reg.at("count", default: 0)

  if c-numbering != none and c-numbering != auto {
    return std.numbering(c-numbering, count)
  }

  return none
}

// Queries the document metadata to find the exact evaluated marker-str
// for a note. If the note is not yet fully compiled, it falls back to
// local evaluation using the raw global state registry.
// Must be called inside a context block.
#let _deixis-query-marker-str(data) = {
  if type(data) != dictionary { return none }

  let internal-id = data.at("internal-id", default: none)
  if internal-id == none {
    if "mark-lbl" in data and data.mark-lbl != none {
      internal-id = str(data.mark-lbl).replace("deixis-mark-", "")
    } else if "body-lbl" in data and data.body-lbl != none {
      internal-id = str(data.body-lbl).replace("deixis-body-", "")
    }
  }

  if internal-id != none {
    let marks = query(
      selector(metadata).and(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>).or(<deixis-region-mark>)),
    )

    let match = marks.find(m => (
      type(m.value) == dictionary
        and m.value.at("internal-id", default: none) != none
        and str(m.value.internal-id) == str(internal-id)
    ))

    if match != none and match.value.at("marker-str", default: none) != none {
      return match.value.marker-str
    }
  }

  // fallback
  let fallback-reg = data
  if "numbering" not in data and internal-id != none {
    let sys = deixis-system.final()
    for (uid, reg) in sys.at("notes", default: (:)) {
      if str(reg.at("internal-id", default: "")) == str(internal-id) {
        fallback-reg = reg
        break
      }
    }
  }

  return _deixis-evaluate-marker-str(fallback-reg)
}

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

#let _deixis-resolve-typed-param(sys, local-val, param-key, note-type, component: auto) = {
  let unroll(current-val, origin) = {
    if type(current-val) != dictionary { return current-val }

    let is-scoping = true
    let has-note-type = false
    let has-component = false
    let has-rest = false

    for k in current-val.keys() {
      if k == "inline" {
        panic("deixis: The 'inline' dictionary key has been renamed to 'mark'. Please update your styles!")
      }
      if k not in deixis-scoping-keys {
        is-scoping = false
        break
      }
      if k in deixis-note-types { has-note-type = true }
      if k in deixis-note-components { has-component = true }
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

        if note-type in current-val {
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
      if u != auto { return u }
    }

    // stack (#deixis-set)
    if sys != none and sys.stack.len() > 0 {
      for level in sys.stack.rev() {
        let sv = level.at(param-key, default: auto)
        if sv != auto {
          let u = unroll(sv, "stack")
          if u != auto { return u }
        }
      }
    }

    if sys != none {
      let gv = sys.at(param-key, default: auto)
      if gv != auto {
        let u = unroll(gv, "global")
        if u != auto { return u }
      }
    }

    // factory defaults (lowest priority)
    let fv = deixis-factory-defaults.at(param-key, default: auto)
    if fv != auto {
      let u = unroll(fv, "factory")
      if u != auto { return u }
    }

    return auto
  }

  let final-val = resolve-cascade()

  if final-val == auto and param-key in deixis-auto-fallbacks {
    final-val = deixis-auto-fallbacks.at(param-key)
  }

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

  return final-val
}

#let _deixis-resolve-component-styles(sys, note-type, component: auto, ..args) = {
  assert(args.pos().len() == 0)
  let resolved = (:)
  for (name, val) in args.named() {
    let resolved-val = _deixis-resolve-typed-param(sys, val, name, note-type, component: component)
    if name == "stroke" and resolved-val != none and resolved-val != auto {
      let s-obj = std.stroke(resolved-val)
      if s-obj.thickness == auto {
        resolved-val = std.stroke(
          cap: s-obj.cap,
          dash: s-obj.dash,
          join: s-obj.join,
          miter-limit: s-obj.miter-limit,
          paint: s-obj.paint,
          thickness: 1pt,
        )
      } else { resolved-val = s-obj }
    }
    resolved.insert(name, resolved-val)
  }

  return resolved
}

#let _deixis-resolve-mark-styles = _deixis-resolve-component-styles.with(component: "mark")

#let _deixis-resolve-body-styles = _deixis-resolve-component-styles.with(component: "body")

#let _deixis-resolve-link-styles = _deixis-resolve-component-styles.with(component: "link")

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
      let merged-sub = base.at(k)
      for (sub-k, sub-v) in v {
        if sub-v != auto {
          merged-sub.insert(sub-k, sub-v)
        }
      }
      result.insert(k, merged-sub)
    } else {
      result.insert(k, v)
    }
  }

  return result
}
