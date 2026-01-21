// https://github.com/typst/typst/issues/659
#import "template/acronyms.typ": acronyms

// The state which tracks the used acronyms
#let usedAcronyms = state("usedDic", (:))

#let acronyms-list() = {
  v(2em)
  heading(level: 1, numbering: none, "Acronyms")
  locate(loc => usedAcronyms.final(loc)
  .pairs()
  .filter(x => x.last())
  .map(pair => pair.first())
  .sorted()
  .map(key => grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    strong(key),acronyms.at(key) 
  )).join())
}

// The function which either shows the acronym or the full text for it
#let acro(body) = {
  if(acronyms.keys().contains(body) == false) {
    return rect(
      fill: red,
      inset: 8pt,
      radius: 4pt,
      [*Warning:\ #body*],
    )
  }
  usedAcronyms.display(usedDic => {
    if(usedDic.keys().contains(body)) {
      return body
    }
    return acronyms.at(body) + " (" + body + ")"
  });
  usedAcronyms.update(usedDic => {
    usedDic.insert(body, true)
    return usedDic
  })
}