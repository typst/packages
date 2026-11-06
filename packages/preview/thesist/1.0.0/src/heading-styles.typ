// Short heading style
#let short-heading(it) = {
  counter(heading).display() + " - " + it.body
}

// Simple heading style
#let simple-heading(chapter-type: none, it) = {
  grid(
    rows: (2em, auto, 2em, auto, 1em),
    [],
    text(chapter-type + " " + counter(heading).display(), 21pt),
    [],
    it.body,
    []
  )
}

// Fancy heading style
#let fancy-heading(outline-title: none, it) = {

  // Title
  {
    set align(right+horizon)
    {
      set text(size: 6cm, font: "TeX Gyre Bonum")
      h(3cm)
      counter(heading).display()
    }
    {
      set text(size: 25pt)
      linebreak()
      v(1cm)
      it.body
    }
  }

  // Chapter outline
  align(bottom,
    context {
      let loc = here()
      let after = query(selector(heading.where(outlined: true)).before(loc)).last()
      let elems = query(selector(heading.where(outlined: true)).after(loc))
      let last_elem = none
      for e in elems {
        if e.level <= 1 { break }
        last_elem = e
      }

      if last_elem != none {

        block(text(outline-title, size: 21pt), above: 0pt, below: 0pt)

        set text(size: 10pt)
        block(line(length: 100%), below: 1.5em)

        outline(
          title: none,
          target: selector(heading.where(level: 2, outlined: true)).after(after.location()).before(last_elem.location())
        )

        block(line(length: 100%), above: 1.5em)

      }
    }
  )

  pagebreak()
}
