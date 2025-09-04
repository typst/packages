#let showperson(person) = [
- #person.prefix #person.given-name #person.surname#{if person.suffix!=none [, #person.suffix]}, #person.affiliation
]

#set list(indent: 10mm, marker: none)


#v(0.5fr)

#text(size:14pt)[*Members of the examination board*]

// Jury members are listed in jury.yaml, but can also be set manually.

#text(size:14pt)[*Chair*]
#v(0.3em)
#showperson(yaml("jury.yaml").at("chair"))

#text(size:14pt)[*Other voting members*]
#v(0.3em)
#{
for member in yaml("jury.yaml").at("members") {showperson(member)}
}


#text(size:14pt)[*Supervisors*]
#v(0.3em)
#{
for member in yaml("jury.yaml").at("supervisors") {showperson(member)}
}
