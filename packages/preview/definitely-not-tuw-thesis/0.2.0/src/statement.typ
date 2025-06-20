#import "translations/translations.typ": translate
#import "utils.typ": name-with-titles

#let statement = (author, date) => {
  heading(translate("statement"), outlined: false)

  name-with-titles(author)
  v(2em)

  translate("statement-own-work")
  linebreak()
  linebreak()
  translate("statement-ai-tools")

  v(8em)

  grid(
    columns: (1fr, 1fr),
    align: (left, center),
    [Wien, #date.display("[day].[month].[year]")], [#line(length: 60%, stroke: 0.5pt) #author.at("name", default: "")],
  )
}