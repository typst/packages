#import "/src/utils.typ": i18n

#let declaration-of-originality(doc) = {
  [
    #heading(i18n("declaration-of-originality"), outlined: false)
    
    #doc

    #context query(<vstl:submissionplace>).first().value,
    #context query(<vstl:submissiondate>).first().value.display("[day].[month].[year]")

    #v(8em)

    #align(right, [
      #set par(spacing: .5em)
      #line(length: 15em, stroke: (dash: "dotted"))
      #i18n("signature")
    ])
  ]
}