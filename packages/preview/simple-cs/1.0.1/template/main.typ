#import "@preview/simple-cs:1.0.1" : template, logo-list, set-heading-pagebreak, tuteurs, appendix, get-logos

// For the original file structure
#let root-path = "images/"
#let logos = (
  avec-protection: (
    horizontal: (
      noir : image(root-path + "Logos-avec-zone-protection/CentraleSup Logo H_noir-RVB.svg"),
      blanc: image(root-path + "Logos-avec-zone-protection/CentraleSup Logo H_blanc-RVB.svg"),
      rvb  : image(root-path + "Logos-avec-zone-protection/CentraleSup Logo H_RVB.svg"),
    ),
    vertical: (
      noir : image(root-path + "Logos-avec-zone-protection/CentraleSup Logo V_Noir RVB.svg"),
      blanc: image(root-path + "Logos-avec-zone-protection/CentraleSup Logo V_BlancRVB.svg"),
      rvb  : image(root-path + "Logos-avec-zone-protection/CentraleSup Logo V_RVB.svg"),
    )
  ),
  sans-protection: (
    horizontal: (
      noir : image(root-path + "Logos-sans-zone-protection/CentraleSupelec-Logo H_noir-RVB.svg"),
      blanc: image(root-path + "Logos-sans-zone-protection/CentraleSupelec-Logo H_blanc-RVB.svg"),
      rvb  : image(root-path + "Logos-sans-zone-protection/CentraleSupelec-Logo H_RVB.svg"),
    ),
    vertical: (
      noir : image(root-path + "Logos-sans-zone-protection/CentraleSupelec-Logo V_Noir RVB.svg"),
      blanc: image(root-path + "Logos-sans-zone-protection/CentraleSupelec-Logo V_blanc RVB.svg"),
      rvb  : image(root-path + "Logos-sans-zone-protection/CentraleSupelec-Logo V_RVB.svg"),
    )
  )
)

/*
// Or, for a more organized file structure
#let logos = {
  let logos = (:)
  let root-path = "images/"

  for protection in ("avec", "sans") {
    let prot = protection + "-protection"
    logos.insert(prot, ().to-dict())

    for orientation in ("horizontal", "vertical") {
      logos.at(prot).insert(orientation, ().to-dict())

      for couleur in ("noir", "blanc", "rvb") {
        logos.at(prot).at(orientation).insert(couleur, image(root-path + prot + "/" + orientation + "/" + couleur + ".svg"))
      }
    }
  }
  logos
}
*/



#show: template.with(
  title: strong[Rapport de stage de 1#super[ère] année],
  title-page-header: logo-list(logos.sans-protection.vertical.rvb),
  name: "Prenom NOM",
  dates: "01/01/2026 - 01/02/2026",
  logos: logos,


  title-page-bottom: tuteurs(
    tuteur-company: [
      Prenom NOM \
      #link("mailto:prenom.nom@example.fr")
    ],
    tuteur-school: [
      Prenom NOM \
      #link("mailto:prenom.nom@centralesupelec.fr")
    ]
  ),
)


= Introduction
#lorem(10)

== Foo
#lorem(20)
=== Foobarbaz
#lorem(20)

== Bar
#lorem(20)

#set-heading-pagebreak(false)
= Mes missions
#set-heading-pagebreak(true)
#lorem(100)

== Bar
#lorem(200)

== Baz
#lorem(300)


#show: appendix
= Abcd
== foobarbaz
