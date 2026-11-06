/// A hacky way to get an independent label
#let impromptu-label(lbl, kind: auto, supplement: none) = {
  assert(type(lbl) == str, message: "Label must be of type string")
  place[#figure(kind: kind, supplement: supplement)[]#label(lbl)]
}

/// Internal wrapper of ref links.
///
/// This wraps the display implementation of the `ref` function.
/// Since we provide some custom labels kinds, we must ensure that they get displayed correctly.
#let ref-wrapper(it) = {
  let el = it.element

  if type(el) != content or el.func() != figure {
    return it
  }

  let kind = el.kind

  // Task labels
  if kind == "sheetstorm-task-label" {
    let task-count = counter("sheetstorm-task").at(el.location()).first()
    let supp = if it.supplement == auto { el.supplement } else { it.supplement }
    link(el.location())[#supp #task-count]

    // Subtask labels
  } else if kind == "sheetstorm-subtask-label" {
    let subtask-count = state("sheetstorm-subtask").at(el.location()).last()
    let subtask-pattern = state("sheetstorm-subtask-pattern").at(el.location())
    let supp = if it.supplement == auto { el.supplement } else { it.supplement }
    link(el.location())[#supp #numbering(subtask-pattern, subtask-count)]

    // Theorem labels
  } else if kind == "sheetstorm-theorem-label" {
    let theorem-id = state("sheetstorm-theorem-id").at(el.location())
    if theorem-id == auto {
      theorem-id = counter("sheetstorm-theorem-count").at(el.location()).first()
    }
    if theorem-id == none {
      panic(
        "This theorem is not referencable. Provide a name or numbering.",
      )
    }
    let supp = if it.supplement == auto { el.supplement } else { it.supplement }
    link(el.location())[#supp #theorem-id]

    // Everything else
  } else {
    it
  }
}

