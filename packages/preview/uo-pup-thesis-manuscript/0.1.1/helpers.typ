/**
* This checks the page if it is the starting page for a chapter
* by looking at the heading level (chapter starts with level 1 heading)
*/
#let is-start-chapter(actual-page-num) = {
  return query(
    heading.where(level: 1)
  ).map(it => it.location().page()).contains(actual-page-num)
}

#let get-current-page-num() = {
  return [
    #let actual-page-num = here().page()
    #h(1fr)
    #if not is-start-chapter(actual-page-num) {
      counter(page).get().first()
    } else {
      none
    }
  ]
}

#let to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let chapter(number, title) = {
  pagebreak(weak: true)
  title = upper(title) // Rule: chapter title must be in uppercase
  align(center)[
    *Chapter #number*
    #v(-1em)
    #heading(title)
  ]
}

#let description(terms) = {
  show par: it => {
    block(inset: (left: 0.5in))[#it]
  }
  for term in terms [#par([#h(0.5in) *#term.term*. #term.desc])]
}

#let finding(number, title) = {
  table(
    columns: (0.5cm, 1fr),
    stroke: none,
    [*#number*.], [#heading(outlined: false, level: 2, title)]
  )
}
