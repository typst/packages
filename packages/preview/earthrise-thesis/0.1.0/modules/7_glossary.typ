#import "@preview/glossarium:0.5.9": (
  gls, glspl, make-glossary, print-glossary, register-glossary,
)

#let glossary-page(entry-list, group-order: none) = {
  let order = if group-order == none { () } else { group-order }
  set par(spacing: 1.333em)
  align(left)[
    = Glossary <glossary>
    #print-glossary(
      entry-list,
      deduplicate-back-references: true,
      group-sortkey: g => {
        let i = order.position(x => x == g)
        if g == "" { "" } else if i == none { "1" + g } else {
          "0" + "0" * (4 - str(i).len()) + str(i)
        }
      },
    )
  ]
}
