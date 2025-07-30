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
