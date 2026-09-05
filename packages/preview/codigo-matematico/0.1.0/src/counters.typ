// Counter helpers for numbered objects.

#import "./settings.typ": section-counter-names


#let reset-section-counters() = {
  for name in section-counter-names {
    counter(name).update(0)
    counter(figure.where(kind: name)).update(0)
  }
}

#let reset-figure-counters() = {
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
}

#let heading-number-of(heading-numbers, depth, fallback) = {
  if heading-numbers.len() >= depth {
    heading-numbers.at(depth - 1)
  } else {
    fallback
  }
}

// Heading number at the current position (requires context).
#let current-heading-number(depth, fallback: 1) = {
  heading-number-of(counter(heading).get(), depth, fallback)
}

// Heading number at a given location.
#let heading-number-at(loc, depth, fallback: 1) = {
  heading-number-of(counter(heading).at(loc), depth, fallback)
}
