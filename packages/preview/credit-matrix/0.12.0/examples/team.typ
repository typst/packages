// The app's JSON export (Export data > JSON), in French.
#import "@preview/credit-matrix:0.12.0": *
#set document(title: "Déclaration CRediT")
#set text(lang: "fr")

#let team = json("team.json")

= Contributions des auteurs

#credit-statement(team, format: "by-role", levels: true)

#credit-table(team)

#credit-heatmap(team, levels: false)
