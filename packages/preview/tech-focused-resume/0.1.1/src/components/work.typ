#import "../layout.typ": body-helper, generic-two-by-two

#let work(
  title: "",
  tech-stack: "",
  dates: "",
  company: "",
  company-category: "",
  modality: "",
  location: "",
  columns: (1fr, 1fr),
  body,
) = {
  generic-two-by-two(
    cols: columns,
    top-left: {
      strong(company)
      if company-category != "" [ #sym.dot.c #company-category]
    },
    top-right: strong(dates),
    bottom-left: [
      #emph(title)
      #if tech-stack != "" [
        | #emph(tech-stack)
      ]
    ],
    bottom-right: [
      #modality #sym.dash.em #location
    ],
  )
  body-helper(body)
}
