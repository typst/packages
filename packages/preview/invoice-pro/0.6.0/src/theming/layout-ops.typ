// Layout patching: areas are an OPEN map of CLOSED records. Area fields go
// through the same strict `merge` as everything else (inset folds as sides,
// text recurses, `auto` = untouched, `reset()` = schema default).
#import "../utils/patch.typ": (
  clean-auto, did-you-mean, fail-unknown, is-reset, merge,
)
#import "schema.typ": (
  area-defaults, area-rules, layout-defaults, rules, standard-areas,
)

#let _check-area-keys(r, path) = {
  if type(r) != dictionary {
    panic(
      path.join("::")
        + " must be a dictionary of area fields or `none`, found "
        + repr(r),
    )
  }
  for k in r.keys() {
    if k not in area-defaults { fail-unknown(path, k, area-defaults.keys()) }
  }
}

// Exclusive anchor pairs: setting one side clears the other (left <-> right, top <-> bottom).
#let _pairs = (left: "right", right: "left", top: "bottom", bottom: "top")

/// Merges an area patch (named fields, `auto` = untouched) onto a full area record.
#let patch-area(existing, rv, path) = {
  let rv = clean-auto(rv)
  _check-area-keys(rv, path)
  let r = existing
  for (k, v) in rv {
    let other = _pairs.at(k, default: none)
    if other != none and not is-reset(v) and other not in rv {
      r.insert(other, auto)
    }
    r.insert(k, merge(r.at(k), v, path + (k,), area-rules, key: k))
  }
  r
}

/// A new area: defaults + the given fields (must contain `place`).
#let new-area(rv, path) = patch-area(area-defaults, rv, path)

/// Applies one `layout` patch group to a layout dict.
/// -> dictionary
#let apply-layout-patch(layout, patch, path: ("theme", "layout")) = {
  let layout = layout
  for (k, v) in patch {
    if v == auto { continue }
    if k == "areas" {
      let areas = layout.areas
      for (name, rv) in v {
        let p = path + ("areas", name)
        let existing = areas.at(name, default: none)
        if rv == none {
          // removal is idempotent: removing an area the layout lacks is a no-op
          if name in areas { areas.insert(name, none) }
        } else if existing != none {
          areas.insert(name, patch-area(existing, rv, p))
        } else if (
          type(rv) == dictionary and "place" in rv and rv.place != auto
        ) {
          // a patch WITH `place` (re-)creates the area, also after a removal
          areas.insert(name, new-area(rv, p))
        } else if name in areas {
          // the area was removed earlier in the chain: removal is sticky, the patch is ignored
          continue
        } else {
          let live = areas
            .pairs()
            .filter(((n, r)) => r != none)
            .map(((n, r)) => n)
          panic(
            (path + ("areas",)).join("::")
              + " has no area `"
              + name
              + "` in layout `"
              + layout.name
              + "`."
              + did-you-mean(name, live)
              + " Existing areas: "
              + live.join(", ")
              + ". To ADD an area, give it a `place`.",
          )
        }
      }
      layout.insert("areas", areas)
    } else if k in layout {
      layout.insert(k, merge(
        layout.at(k),
        v,
        path + (k,),
        rules,
        key: "layout::" + k,
      ))
    } else {
      fail-unknown(path, k, layout.keys())
    }
  }
  layout
}

/// Normalises a layout value (a complete or partial layout dict) onto the defaults:
/// every area becomes a full record, and every STANDARD area name the layout
/// lacks is injected as an empty stub (appended, so the layout's order is kept).
#let complete-layout(l) = {
  if type(l) != dictionary {
    panic(
      "variable `theme::layout`("
        + repr(l)
        + ") must be of dictionary (a layout such as `theme.layout.din-5008-a`)",
    )
  }
  let areas = l.at("areas", default: (:))
  let rest = l
  let _ = rest.remove("areas", default: none)
  let base = apply-layout-patch(layout-defaults, rest)
  base.areas = (:)
  for (name, r) in areas {
    let p = ("theme", "layout", "areas", name)
    base.areas.insert(name, if r == none { none } else { new-area(r, p) })
  }
  for (name, stub) in standard-areas {
    if name not in base.areas {
      base.areas.insert(name, new-area(stub, (
        "theme",
        "layout",
        "areas",
        name,
      )))
    }
  }
  base
}

/// `theme.layout.derive(base, ..patches)`: a new layout from an existing one plus
/// layout patches (custom.page/marks/area/stationery results).
/// -> dictionary
#let derive(base, ..patches) = {
  let l = complete-layout(base)
  for p in patches.pos().flatten() {
    if p == none { continue }
    for (g, v) in p {
      if g != "layout" {
        panic(
          "theme::layout::derive accepts only layout patches, found group `"
            + g
            + "`",
        )
      }
      l = apply-layout-patch(l, v)
    }
  }
  l
}
