// The app's JSON export (Export data > JSON), in French.
#import "../lib.typ": *
#set document(title: "Déclaration CRediT")
#set text(lang: "fr")

#let team = json("team.json")

= Contributions des auteurs

#credit-statement(team, format: "by-role", levels: true)

#credit-table(team)

#credit-heatmap(team, levels: false)
