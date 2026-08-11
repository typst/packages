// axiomst/slides.typ - Minimal presentation slides

// Global state
#let _handout-mode = state("axiomst-handout", false)
#let _subslide = state("axiomst-subslide", 1)

// Helper: parse indices and return max subslide needed
#let _max-index(indices) = {
  if type(indices) == int { indices }
  else if type(indices) == array { calc.max(..indices) }
  else if type(indices) == dictionary {
    if "from" in indices { indices.from }
    else if "to" in indices { indices.to }
    else { 1 }
  }
  else { 1 }
}

// Helper: check visibility for uncover (cumulative - shows from index onwards)
#let _is-visible-uncover(indices, current) = {
  if type(indices) == int { current >= indices }
  else if type(indices) == array { indices.contains(current) }
  else if type(indices) == dictionary {
    if "from" in indices { current >= indices.from }
    else if "to" in indices { current <= indices.to }
    else { true }
  }
  else { true }
}

// Helper: check visibility for only (exact - shows only on specific indices)
#let _is-visible-only(indices, current) = {
  if type(indices) == int { current == indices }
  else if type(indices) == array { indices.contains(current) }
  else if type(indices) == dictionary {
    if "from" in indices { current >= indices.from }
    else if "to" in indices { current <= indices.to }
    else { true }
  }
  else { true }
}

// Uncover: always laid out, visible on specified subslides (cumulative)
#let uncover(indices, body) = {
  let max-sub = _max-index(indices)
  metadata(("axiomst-max-sub", max-sub))
  context {
    let current = _subslide.get()
    let handout = _handout-mode.get()
    if handout or _is-visible-uncover(indices, current) {
      body
    } else {
      hide(body)
    }
  }
}

// Only: only present on specified subslides (exact match, affects layout)
#let only(indices, body) = {
  let max-sub = _max-index(indices)
  metadata(("axiomst-max-sub", max-sub))
  context {
    let current = _subslide.get()
    let handout = _handout-mode.get()
    if handout or _is-visible-only(indices, current) {
      body
    }
  }
}

// Pause marker - increments subslide requirement
#let pause = metadata(("axiomst-pause", none))

// Count required subslides by traversing content
#let _count-subslides(elem) = {
  let max-sub = 1
  let pause-count = 0

  if type(elem) == content {
    // Check for pause or max-sub metadata
    if elem.func() == metadata {
      let val = elem.value
      if type(val) == array and val.len() >= 2 {
        if val.at(0) == "axiomst-pause" {
          pause-count += 1
        } else if val.at(0) == "axiomst-max-sub" {
          max-sub = calc.max(max-sub, val.at(1))
        }
      }
    }

    // Recurse into children
    if elem.has("children") {
      for child in elem.children {
        let (child-max, child-pauses) = _count-subslides(child)
        max-sub = calc.max(max-sub, child-max)
        pause-count += child-pauses
      }
    }
    if elem.has("body") {
      let (child-max, child-pauses) = _count-subslides(elem.body)
      max-sub = calc.max(max-sub, child-max)
      pause-count += child-pauses
    }
    if elem.has("child") {
      let (child-max, child-pauses) = _count-subslides(elem.child)
      max-sub = calc.max(max-sub, child-max)
      pause-count += child-pauses
    }
  }

  (calc.max(max-sub, pause-count + 1), pause-count)
}

// Slide function
#let slide(
  title: none,
  subtitle: none,
  header: none,
  footer: auto,
  body
) = {
  // Count subslides needed
  let (num-subslides, num-pauses) = _count-subslides(body)

  context {
    let handout = _handout-mode.get()
    let iterations = if handout { 1 } else { num-subslides }

    for sub in range(1, iterations + 1) {
      pagebreak(weak: true)
      _subslide.update(sub)

      // Header
      if header != none {
        header
        v(0.5em)
      } else if title != none {
        block(width: 100%)[
          #text(size: 1.5em, weight: "bold")[#title]
          #if subtitle != none [
            #linebreak()
            #text(size: 1.1em, fill: gray.darken(20%))[#subtitle]
          ]
        ]
        line(length: 100%, stroke: 0.5pt + gray)
        v(0.5em)
      }

      // Body with pause handling
      {
        // Track pause count with a counter unique to this subslide render
        let pause-ctr = counter("axiomst-p-" + str(sub))
        pause-ctr.update(0)

        // When we encounter a pause, increment counter
        show metadata: it => {
          if type(it.value) == array and it.value.len() >= 2 {
            if it.value.at(0) == "axiomst-pause" {
              pause-ctr.step()
            }
            // Hide max-sub markers
            if it.value.at(0) == "axiomst-max-sub" { }
          }
        }

        // Apply visibility rules to content elements
        let make-visible-rule(element) = {
          show element: it => context {
            let pauses-seen = pause-ctr.get().first()
            if handout or pauses-seen < sub {
              it
            } else {
              hide(it)
            }
          }
        }

        // Apply to block-level elements
        show par: it => context {
          let p = pause-ctr.get().first()
          if handout or p < sub { it } else { hide(it) }
        }
        show list.item: it => context {
          let p = pause-ctr.get().first()
          if handout or p < sub { it } else { hide(it) }
        }
        show enum.item: it => context {
          let p = pause-ctr.get().first()
          if handout or p < sub { it } else { hide(it) }
        }
        show heading: it => context {
          let p = pause-ctr.get().first()
          if handout or p < sub { it } else { hide(it) }
        }
        show math.equation.where(block: true): it => context {
          let p = pause-ctr.get().first()
          if handout or p < sub { it } else { hide(it) }
        }
        show raw.where(block: true): it => context {
          let p = pause-ctr.get().first()
          if handout or p < sub { it } else { hide(it) }
        }
        show table: it => context {
          let p = pause-ctr.get().first()
          if handout or p < sub { it } else { hide(it) }
        }
        show figure: it => context {
          let p = pause-ctr.get().first()
          if handout or p < sub { it } else { hide(it) }
        }
        show block: it => context {
          let p = pause-ctr.get().first()
          if handout or p < sub { it } else { hide(it) }
        }

        body
      }

      // Footer
      if footer == auto {
        v(1fr)
        line(length: 100%, stroke: 0.3pt + gray.lighten(50%))
        align(right)[
          #text(size: 0.8em, fill: gray)[
            #counter(page).display()
            #if not handout and num-subslides > 1 [
              #text(fill: gray.lighten(30%))[ | #sub / #num-subslides]
            ]
          ]
        ]
      } else if footer != none {
        v(1fr)
        footer
      }
    }
  }
}

// Title slide
#let title-slide(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  institution: none,
) = {
  pagebreak(weak: true)
  v(1fr)
  align(center)[
    #text(size: 2em, weight: "bold")[#title]
    #if subtitle != none [
      #v(0.5em)
      #text(size: 1.3em, fill: gray.darken(20%))[#subtitle]
    ]
    #v(2em)
    #if author != none [
      #text(size: 1.2em)[#author]
      #linebreak()
    ]
    #if institution != none [
      #text(size: 1em, fill: gray)[#institution]
      #linebreak()
    ]
    #if date != none [
      #v(0.5em)
      #text(size: 0.9em, style: "italic")[#date.display("[month repr:long] [day], [year]")]
    ]
  ]
  v(1fr)
}

// Section slide
#let section-slide(title) = {
  pagebreak(weak: true)
  v(1fr)
  align(center)[
    #text(size: 1.8em, weight: "bold")[#title]
  ]
  v(1fr)
}

// Main slides template
#let slides(
  title: "Presentation",
  author: none,
  date: datetime.today(),
  ratio: "16-9",
  handout: false,
  margin: 1.5cm,
  body
) = {
  _handout-mode.update(handout)
  _subslide.update(1)

  let paper = if ratio == "16-9" or ratio == "16:9" {
    "presentation-16-9"
  } else {
    "presentation-4-3"
  }

  set document(title: title, author: if author != none { author } else { "" })
  set page(paper: paper, margin: margin)
  set text(size: 20pt)

  show heading.where(level: 1): it => {
    text(size: 1.3em, weight: "bold")[#it.body]
    v(0.3em)
  }
  show heading.where(level: 2): it => {
    text(size: 1.1em, weight: "bold")[#it.body]
    v(0.2em)
  }

  set list(marker: ([--], [--]))
  set enum(numbering: "1.")

  body
}
