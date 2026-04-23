#import "../template/src/settings/name.typ": *
// Ajoute des signatures des auteurs

#show link: set text(fill: black)

#v(2cm)
#align(right)[
  Réalisé le: #config.date]

#v(0.5em)

// Calcul du nombre d'auteurs actifs
#let nb-auteurs = auteurs.filter(a => a.active).len()

// Alignement différent selon le nombre d'auteurs
#let align-sig = if nb-auteurs == 1 { right + bottom } else { center + bottom }

#grid(
  // Crée autant de colonnes (1fr) qu'il y a d'auteurs actifs
  columns: range(0, nb-auteurs).map(_ => 1fr),
  gutter: 1em,
  align: align-sig,

  ..{
    let sigs = ()

    // On prépare chaque bloc de signature pour les auteurs actifs
    for author in auteurs {
      if author.active {
        sigs.push([
          #box(height: 3cm, align(bottom + center, image("../template/src/assets/picture/" + author.signature, width: 3.5cm)))
          #v(1em)
          #author.prenom #author.nom \
          #text(fill: black, link("mailto:" + author.email, author.email))
        ])
      }
    }

    sigs
  }
)
