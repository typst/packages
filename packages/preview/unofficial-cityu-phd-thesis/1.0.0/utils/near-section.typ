#let numbering_section(c, b)={
  if(c.numbering != none) {
    return numbering(c.numbering,..counter(heading).at(c.location())) + " " + b
  }
}

#let near-section = context {
  let headings_after = query(selector(heading.where(level: 2)).after(here()))
  let headings_before = query(selector(heading.where(level: 2)).before(here()))
  let chapter_headings_after = query(selector(heading.where(level: 1)).after(here()))
  let chapter_headings_before = query(selector(heading.where(level: 1)).before(here()))

  if headings_after.len() == 0 {
    return
  }

  // section header is not required when chapter number is empty
  if chapter_headings_after.len() == 0 {
    return
  }
  if chapter_headings_after.first().location().page() > here().page() {
    if chapter_headings_after.first().numbering == none {
      return
    }
  } else {
    if chapter_headings_before.len() != 0 {
      if chapter_headings_before.first().numbering == none {
        return
      }
    }
  }

  let heading = headings_after.first()
  if heading.location().page() > here().page() {
    if headings_before.len() == 0 {
      return
    }
    numbering_section(headings_before.last(), headings_before.last().body)
  } else {

    numbering_section(heading, heading.body)
  }
}
