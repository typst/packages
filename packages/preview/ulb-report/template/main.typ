#import "@preview/ulb-report:0.1.0": report

#show: report.with(
  title: "Exemple de titre",
  studies: "Année d'étude",
  course: "Nom du cours",
  date: datetime.today().display("[day]/[month]/[year]"),
  authors: ("Nom 1", "Nom 2"),
  teachers: ("Prof 1", "Superviseur"),
)

// Table of content
#outline(depth: 2)

= Introduction

This is a citation: @Exemple

== Section 1

#lorem(100)

== Section 2
=== Subsection
==== Subsubsection

#bibliography("biblio.bib", style: "ieee")

#set heading(numbering: "A.1 -")
#counter(heading).update(0)
= Détail supplémentaire
== Section
