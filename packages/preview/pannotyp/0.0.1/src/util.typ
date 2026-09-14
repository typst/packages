#import "@preview/valkyrie:0.2.2" as v

#let getLabelCounterFirst(label) = {
  // array of matches for this label
  let matches = query(label)
  if matches.len() == 0 {
    panic("PannoTyp: label not found")
  } else {
    // label found
    let el = matches.first() // there should be only one match anyway
    if el.func() == heading {
      return counter(heading).at(label).first()
    } else if el.func() == math.equation {
      return counter(math.equation).at(label).first()
    } else {
      return el.counter.at(label).first()
    }
  }
}

#let LabelData = v.dictionary((
  counter: v.array(),
  numbering: v.either(v.string(), v.function()),
  supplement: v.content(),
))

#let getLabelData(label, form: "normal") = {
  // array of matches for this label
  let matches = query(label)
  if matches.len() == 0 {
    panic("PannoTyp: label not found")
  } else {
    // label found
    let el = matches.first() // there should be only one match anyway

    // counter
    let cnt = none
    if form == "page" {
      cnt = counter(page).at(label)
    } else {
      if el.func() == heading {
        cnt = counter(heading).at(label)
      } else if el.func() == math.equation {
        cnt = counter(math.equation).at(label)
      } else {
        cnt = el.counter.at(label)
      }
    }

    // numbering
    let nbring = el.numbering
    if form == "page" {
      if page.numbering == none {
        nbring = "1"
      } else {
        nbring = page.numbering
      }
    }

    return v.parse(
      (
        counter: cnt,
        numbering: nbring,
        supplement: el.supplement,
      ),
      LabelData,
    )
  }
}
