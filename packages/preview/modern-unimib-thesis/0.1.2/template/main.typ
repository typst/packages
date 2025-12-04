#import "@preview/modern-unimib-thesis:0.1.0": template

// Create bibliography object first
#let refs = bibliography("refs.bib")

#show: template.with(
  title: "Higher Order Quantum Theory, the \"Double-Ket\" notation", 
  candidate:(
    name: "Michelino Banfi",
    number: "123456"
  ),
  date: "2024/2025", 
  university: "Universitá degli studi Milano - Bicocca",
  school: "Scuola di Scienze",
  department: "Dipartimento di Fisica",
  course: "Master Degree in Artificial Intelligence for Science and Technology",
  logo: image("images/logo_unimib.png", width: 30%),
  supervisor: "Prof. Luca Manzi",
  co-supervisor: ("Saira Sanchez", "Prof. Annalisa Di Pasquali"),
  lang: "en",
  bib: refs, // Pass the bibliography object instead of a file path
)

= Introduction
#lorem(100)
== Subtitle
#underline[Generalized POVM]
$
pi_i equiv sum_(j=0)^i K_j^dagger PP_i K_j
$<POVM>

@POVM are Great!
= Preliminaries
@Yoder_2014

= Acknowledgments // Ringraziamenti This is a special title name
#lorem(100)