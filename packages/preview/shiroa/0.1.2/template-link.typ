
#import "supports-text.typ": plain-text

#let make-unique-label(it, disambiguator: 1) = label({
  let k = plain-text(it).trim()
  if disambiguator > 1 {
    k + "_d" + str(disambiguator)
  } else {
    k
  }
})

#let label-disambiguator = state("label-disambiguator", (:))
#let update-label-disambiguator(k) = label-disambiguator.update(it => {
  it.insert(k, it.at(k, default: 0) + 1)
  it
})
#let get-label-disambiguator(loc, k) = make-unique-label(k, disambiguator: label-disambiguator.at(loc).at(k))

#let heading-reference(it, d: 1) = make-unique-label(it.body, disambiguator: d)

#let heading-hash(it, hash-color: blue) = {
  let title = plain-text(it.body)
  if title != none {
    let title = title.trim()
    update-label-disambiguator(title)
    context (
      {
        let loc = here()
        let dest = get-label-disambiguator(loc, title)
        let h = measure(it.body).height
        place(
          left,
          dx: -20pt,
          [
            #set text(fill: hash-color)
            #link(loc)[\#] #dest
          ],
        )
      }
    )
  }
}
