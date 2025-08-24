#let new-thm-func(
  group,
  subgroup,
  numbering: "1"
) = {
  return (name: none, numbering: numbering, content) => {
    figure(
      content,
      caption: name,
      kind: group,
      supplement: subgroup,
      numbering: numbering
    )
  }
}

// Applies theorem styling and theorem
// numbering functions to theorem.
#let thm-style(
  thm-styling,
  thm-numbering,
  fig
) = {
  thm-styling(
    if fig.has("caption") and fig.caption != none { fig.caption.body },
    thm-numbering(fig),
    fig.body
  )
}

// Applies reference styling to the
// theorems belonging to the specified
// group/subgroups.
#let thm-ref-style(
  group,
  subgroups: none,
  ref-styling,
  content
) = {
  show ref: it => {
    if it.element == none {
      return it
    }
    if it.element.func() != figure {
      return it
    }
    if it.element.kind != group {
      return it
    }

    let refd-subgroup = it.element.supplement.text
    if subgroups == none {
      ref-styling(it)
    } else if subgroups == refd-subgroup {
      ref-styling(it)
    } else if type(subgroups) == "array" and subgroups.contains(refd-subgroup) {
      ref-styling(it)
    } else {
      it
    }
  }
  content
}

// Utility function to display a counter
// at the given position.
#let display-heading-counter-at(loc, max-heading-level) = {
  let locations = query(selector(heading).before(loc), loc)
  if locations.len() == 0 {
    [0]
  } else {
    let numb = query(selector(heading).before(loc), loc).last().numbering
    if numb != none {
      let c = counter(heading).at(loc)
      if max-heading-level != none and c.len() > max-heading-level {
        c = c.slice(0, max-heading-level)
      }
      numbering(numb, ..c)
    } else {
      let current-level = locations.last().level
      for h in locations.rev() {
        if h.level < current-level {
          display-heading-counter-at(h.location(), max-heading-level)
          return
        }
      }
      panic("No numbering set for headings. Try setting the heading numbering or use a different thm-numbering")
    }
  }
}

// Create a concatenated function from
// a list of functions (with one argument)
// starting with the last function:
// concat-fold((f1, f2, fn))(x) = f1(f2(f3(x)))
#let concat-fold(functions) = {
  functions.fold((c => c), (f, g) => (c => f(g(c))))
}
