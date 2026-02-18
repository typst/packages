#let auto-diff = (
  cover: (),
  preface: (),
  main: (),
  ending: (),
  content
) => {
  set page(
    background: context {
      let page-number = counter(page).get().first()
      let preface-start-label-array = query(metadata.where(label: <preface-start>).before(here()))
      let main-start-label-array = query(metadata.where(label: <main-start>).before(here()))
      let ending-start-label-array = query(metadata.where(label: <ending-start>).before(here()))
      if preface-start-label-array.len() == 0 {
        if page-number <= cover.len() {
          [#cover.at(page-number - 1)]
        }
      } else if main-start-label-array.len() == 0 {
        if page-number <= preface.len() {
          [#preface.at(page-number - 1)]
        }
      } else if ending-start-label-array.len() == 0 {
        if page-number <= main.len() {
          [#main.at(page-number - 1)]
        }
      } else {
        let ending-start-label = ending-start-label-array.at(0)
        let ending-start-label-page-count = counter(page).at(ending-start-label.location()).at(0)
        let ending-page-number = page-number - ending-start-label-page-count
        if ending-page-number <= ending.len() {
          [#ending.at(ending-page-number - 1)]
        }
      }
    }
  )

  content
}