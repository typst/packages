#import "styling/tokens.typ": tokens
#import "@preview/datify:1.0.1": *

// See https://github.com/typst/typst/issues/2953
#let show_if_heading_within_distance(
  it: none,
  distance: 1cm,
  look: "before",
  to-show: v(-1cm),
  if-not: false,
) = {
  if it == none {
    panic("Parameter \"it\" of \"show_if_heading_within_distance\" must be defined.")
  }

  // 1. Find neighbouring headings
  let sel = selector(heading)
  let neighbours = ()

  if look == "before" {
    neighbours = query(sel.before(here(), inclusive: false))
  } else if look == "after" {
    neighbours = query(sel.after(here(), inclusive: false))
  } else {
    panic("Parameter \"look\" of \"show_if_heading_within_distance\" must have value \"before\" or \"after\".")
  }

  if neighbours.len() > 0 {
    // 2. Get the closest heading (last 'before' or first 'after').
    let neighbour = if look == "before" {
      neighbours.last()
    } else {
      neighbours.first()
    }

    // 3. Get the absolute positions of the current element and the neighbour.
    let iloc = it.location().position()
    let nloc = neighbour.location().position()

    // 4. Check if distance is within threshold
    if iloc.page == nloc.page and iloc.x == nloc.x {
      let vertical-distance = if look == "before" {
        iloc.y - nloc.y
      } else {
        nloc.y - iloc.y
      }

      if vertical-distance < distance {
        if (if-not) { return none }
        return to-show
      }
    }
  }

  if (if-not) { return to-show }
  return none
}

#let content-to-string(c) = {
  if type(c) == str { c }
  else if c == [ ] { " " }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(content-to-string).join("") }
  else if c.has("body") { content-to-string(c.body) }
  else { "" }
}

#let ellipsisise(max-width, text) = box(layout(size => context {
  let width(t) = measure(t).width
  let limit = if type(max-width) == ratio { max-width * size.width } else { max-width }
  let s = content-to-string(text)
  let s_orig = s
  let ellipsis = "..."

  while s.len() > 0 and width(s) + width(ellipsis) > limit {
    s = s.slice(0, calc.max(0, s.len() - 1))
  }

  if s == s_orig {
    s
  } else {
    s + ellipsis
  }
}))

#let v-after-numbered-chapter-heading(it) = context {
  if it == none {
    panic("Parameter \"it\" of \"v-after-numbered-chapter-heading\" must be defined.")
  }
  let loc = it.location()
  let heads-after = query(selector(heading).after(loc, inclusive: false))
  let pars-after = query(selector(par).after(loc, inclusive: false))
  let next-h = if heads-after.len() > 0 { heads-after.first() }
  let next-p = if pars-after.len() > 0 { pars-after.first() }

  if next-h == none {
    v(1cm)
  } else if next-p == none {
    v(0.5cm)
  } else {
    let h-pos = next-h.location().position()
    let p-pos = next-p.location().position()
    let heading-first = h-pos.page < p-pos.page or (h-pos.page == p-pos.page and h-pos.y < p-pos.y)
    if heading-first {
      v(0.5cm)
    } else {
      v(1cm)
    }
  }
}

#let today() = context {
  let current-date = datetime.today()
  [#custom-date-format(current-date, pattern: "long", lang: text.lang)]
}

#let ensure-array(unsafe-input) = {
  if unsafe-input == none {
    ()
  } else if type(unsafe-input) != array {
    (unsafe-input,)
  } else {
    unsafe-input
  }
}

// Same supervisor shapes as on the title page: plain array, or dict with main / secondary / external (each string or array).
#let flatten-supervisor-names(supervisors) = {
  if supervisors == none {
    ()
  } else if type(supervisors) == dictionary {
    let names = ()
    for key in ("main", "secondary", "external") {
      if key in supervisors {
        let value = supervisors.at(key)
        if value != none {
          names = names + ensure-array(value)
        }
      }
    }
    names
  } else {
    ensure-array(supervisors)
  }
}

#let centered(title, content) = {
  pagebreak()
  set align(center + horizon)
  set par(first-line-indent: 0cm)
  align(start + horizon)[
    #text(
      font: tokens.font-families.headers,
      fill: tokens.colour.main,
      weight: "bold",
      size: tokens.font-sizes.h1,
      title,
    )
    #content
  ]
}


// When `override` is `none`, the whole optional block is omitted (`none`), not replaced by defaults.
// For settings where `none` should mean "fall back to defaults" (e.g. bibliography), use `deep-merge-or-default`.
#let deep-merge(base, override) = {
  if override == none {
    return none
  }

  let result = (:)

  // Copy all keys from base
  for (key, value) in base {
    result.insert(key, value)
  }

  // Apply overrides
  for (key, value) in override {
    // Skip empty arrays - keep the base value
    if type(value) == array and value.len() == 0 {
      continue
    }

    if key in base and type(value) == dictionary and type(base.at(key)) == dictionary {
      result.insert(key, deep-merge(base.at(key), value))
    } else {
      result.insert(key, value)
    }
  }

  result
}

#let deep-merge-or-default(base, override) = {
  let merged = deep-merge(base, override)
  if merged == none {
    base
  } else {
    merged
  }
}

#let title-case(string) = {
  return str(string).replace(
    regex("[A-Za-z]+('[A-Za-z]+)?"),
    word => upper(word.text.first()) + lower(word.text.slice(1)),
  )
}
