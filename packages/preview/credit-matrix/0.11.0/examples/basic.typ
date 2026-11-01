#import "../lib.typ": *
#set document(title: "CRediT statement")
#set page(height: auto, margin: 1.5cm)

#let team = (
  (name: "Marie Skłodowska-Curie", roles: (conceptualization: "lead", software: "supporting", writing-original-draft: true)),
  (name: "Antonie van Leeuwenhoek", roles: (investigation: true, formal-analysis: "equal", writing-review-editing: true)),
)

= CRediT authorship contribution statement

#credit-statement(team, levels: true)

#credit-table(team)

#credit-heatmap(team, caption: [Who did what.])
