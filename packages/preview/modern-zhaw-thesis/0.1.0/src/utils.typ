#import "styling/tokens.typ": tokens
#import "@preview/datify:1.0.0": *

// See https://github.com/typst/typst/issues/2953
#let show_if_heading_within_distance(
  it: none,
  distance: 1cm,
  look: "before",
  to-show: v(-1cm),
  if-not: false,
) = {
  if it == none {
    panic("Parameter \"it\" of \"show_if_neighbour_within_distance\" must be defined.")
  }

  // 1. Find neighbouring headings
  let sel = selector(heading)
  let neighbours = ()

  if look == "before" {
    neighbours = query(sel.before(here(), inclusive: false))
  } else if look == "after" {
    neighbours = query(sel.after(here(), inclusive: false))
  } else {
    panic("Parameter \"look\" of \"show_if_neighbour_within_distance\" must have value \"before\" or \"after\".")
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

#let today() = context {
  let current-date = datetime.today()
  [#custom-date-format(current-date, pattern: "long", lang: text.lang)]
}

#let ensure-array(unsafe-input) = {
  if unsafe-input != none and type(unsafe-input) != array {
    (unsafe-input,)
  } else {
    unsafe-input
  }
}

#let centered(title, content) = {
  pagebreak()
  set align(center + horizon)
  set par(first-line-indent: 0cm)
  align(start + horizon)[
    #text(font: tokens.font-families.headers, fill: tokens.colour.main, weight: "bold", size: 24pt, title)
    #content
  ]
}


#let deep-merge(base, override) = {
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

#let title-case(string) = {
  return str(string).replace(
    regex("[A-Za-z]+('[A-Za-z]+)?"),
    word => upper(word.text.first()) + lower(word.text.slice(1)),
  )
}
