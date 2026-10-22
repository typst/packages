// exolombards.typ (farfadet-exo) — thème « exolombards » : feuilles du générateur d'exercices « exolombards ».
// En-têtes : skins.typ (_exolombards-tete, _exolombards-correction).
//
// Les options sont les clés de `setrdexo(pour: "exolombards", …)` ; le chargement est le modèle `exolombards`
// (ajout) : `#show: exolombards.with(pied: true)`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "reglages.typ": bf-exolombards-registre
#import "exo.typ": bf-setrdexo, bf-rdexocorrection
#import "skins.typ": bf-exolombards-etiquette-defaut, bf-exolombards-titre-defaut, bf-exolombards-bareme-defaut

/// Options du paquet (auto, pied, auteur, etablissement, decalage, correction) et présentation
/// (etiquette, titre, bareme : fonctions ; mot-correction : contenu).
#let _regler-exolombards(reinitialiser: false, ..cles) = reglages-regler(bf-exolombards-registre, reinitialiser: reinitialiser, ..cles)

/// \styleExoLombards[clés rdexo] : active le skin.
#let bf-styleExoLombards(..cles) = bf-setrdexo(
  skin: "exolombards",
  exo-header: "tcolorbox",
  display-level: false,
  display-tags: false,
  label: "Exercice",
  ..cles.named(),
)

/// \correctionsLombards{auto|suite|separee}
#let bf-correctionsLombards(mode) = _regler-exolombards(correction: mode)

/// \exolombardsEtiquette{texte} : \fbox{\textbf{…}} (ou la fonction réglée par `etiquette`).
#let bf-exolombardsEtiquette(texte) = context {
  let f = reglages-courants(bf-exolombards-registre).etiquette
  (if f == auto { bf-exolombards-etiquette-defaut } else { f })(texte)
}
/// \exolombardsTitre{titre} : titre discret en italique.
#let bf-exolombardsTitre(texte) = context {
  let f = reglages-courants(bf-exolombards-registre).titre
  (if f == auto { bf-exolombards-titre-defaut } else { f })(texte)
}
/// \exolombardsBareme{points} : « (5 points) ».
#let bf-exolombardsBareme(texte) = context {
  let f = reglages-courants(bf-exolombards-registre).bareme
  (if f == auto { bf-exolombards-bareme-defaut } else { f })(texte)
}
/// \exolombardsMotCorrection : « Correction : ».
#let bf-exolombardsMotCorrection() = context reglages-courants(bf-exolombards-registre).mot-correction

/// \corrigeLombards[référence]{n} : corrigé n façon document de correction d'origine,
/// ou « Pas de corrigé disponible pour cet exercice. ».
#let bf-corrigeLombards(n, reference: none) = context {
  let o = reglages-courants(bf-exolombards-registre)
  let existe = query(<bf-rdexo-correction>).any(c => c.value.n == n)
  if existe { return bf-rdexocorrection(str(n), reference: reference, mode-lombards: "separee") }
  let etiquette = if o.etiquette == auto { bf-exolombards-etiquette-defaut } else { o.etiquette }
  let ref = if reference != none [#h(0.5em)#[(Réf : #reference)]]
  block(width: 100%, above: 0.65em, below: 0.65em + 6pt, [#h(o.decalage)#etiquette([Exercice~#n])#ref#h(1em)#emph[Pas de corrigé disponible pour cet exercice.]])
}

/// Pied de page d'origine : auteur | page | établissement, filet de 0,2 pt.
#let bf-pied-exolombards() = context {
  let o = reglages-courants(bf-exolombards-registre)
  set text(weight: "regular")
  block(width: 100%, {
    line(length: 100%, stroke: ptl(0.2) + black)
    grid(columns: (1fr, auto, 1fr),
      align(left, text(size: taille-latex("small"), o.auteur)),
      counter(page).display(),
      align(right, text(size: taille-latex("small"), o.etablissement)),
    )
  })
}

/// \usepackage[options]{bfcours-exolombards-skin} : modèle (ajout) qui règle les options, active le
/// skin (auto) et pose le pied de page d'origine (pied).
#let bf-exolombards(..cles, doc) = {
  _regler-exolombards(..cles)
  let auto-actif = cles.named().at("auto", default: true)
  let pied = cles.named().at("pied", default: false)
  if auto-actif { bf-styleExoLombards() }
  if pied {
    // sous `modele` : pas de `set page` (il laisserait la page 1, qui porte le bandeau, vide) ; le pied passe par
    // l'état lu par le pied du modèle
    context {
      if bf-pied-modele.get() {
        bf-pied-surcharge.update(bf-pied-exolombards())
        doc
      } else {
        set page(footer: bf-pied-exolombards())
        doc
      }
    }
  } else { doc }
}
