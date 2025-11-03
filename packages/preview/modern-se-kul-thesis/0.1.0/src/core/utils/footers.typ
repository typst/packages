// needs context
// custom footer, used in `set page(footer:...)`
#let custom-footer() = {
  let num = counter(page).get().at(0)
  let dir = if calc.odd(int(num)) {
    right
  } else {
    left
  }
  let num = if type(here().page-numbering()) == str {
    numbering(here().page-numbering(), counter(page).get().at(0))
  } else {
    here().page-numbering()(counter(page).get().at(0))
  }
  align(dir, num)
}
