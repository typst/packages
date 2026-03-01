#import "@preview/iut-orsay-report-flat:0.1.0": figure-list, iut-orsay-report, lexicon, prune, remark, summary, table-list

///////////////////////////////////////////
// 1/3 Si nécessaire, télécharger la police
//     "Open Sans" (cf. README)
///////////////////////////////////////////

///////////////////////////////////////////
// 2/3 Modifier les paramètres ci-dessous
//     pour modifier les deux premières pages.
//     La plupart des paramètres ont des valeurs
//     par défaut, et les champs manquants
//     seront mis en surbrillance.
///////////////////////////////////////////

#show: iut-orsay-report.with(
  student-names: (
    (
      last_name: [Patraque],
      first_name: [Typhaine],
    ),
    (
      last_name: [Hawkins],
      first_name: [Anagramma],
    ),
    // Mettre les autres étudiants
    // (rapport de groupe par exemple)
    // En suivant le même format
    // ATTENTION : s'il y a un seul nom,
    // il faut terminer par une virgule
  ),
  students-in-headers: false, // par défaut : true
  title: [Rapport d'apprentissage],
  subtitle: [Têtologie],
  keywords: ("Causse", "sorcellerie", "magie occulte", "têtologie"),
  abstract: lorem(200),
  show-abstract: true, // true par défaut, false permet de masque la page de résumé
  diploma: [BUT Sorcellerie],
  specialty: [Parcours A : magie des miroirs],
  level: [Troisième année],
  report-date: [16 février 2026],
  report-type: [apprentissage], // [stage] ou [apprentissage] ou ignorer
  company-name: [Cercle des Sorcières],
  report-examiners: (
    (
      name: [*Esmé Ciredutemps*],
      title: [Sorcière],
      status: [Maîtresse d'apprentissage],
    ),
    (
      name: [*Perspicacia Tique*],
      title: [Sorcière],
      status: [Tutrice],
    ),
    (
      name: [*Nac mac Feegle*],
      title: [Fées],
      status: [Tuteurs],
    ),
  ),
  // Les espacements sur ces deux pages peuvent être
  // ajustés en modifiant les valeurs de
  // `vertical-spacing-1` à `vertical-spacing-5`
  // et `horizontal-spacing-1` à `horizontal-spacing-2`
)

///////////////////////////////////////////
// 3/3 A partir d'ici, il n'y a plus de
//     formatage imposé.
//     Les modifications ci-dessous sont
//     proposées à titre indicatif.
///////////////////////////////////////////

// Affiche les références (bibliographie, section, figure...)
// en prune
// Cf. Eric Biedert https://github.com/typst/typst/discussions/4143

#show cite: it => {
  // Bibliographie -> couleur pour le nombre uniquement, pas les crochets ou le texte supplémentaire
  show regex("\["): set text(fill: black) // crochets noirs
  show regex("^\[(\d+)"): set text(fill: prune) // uniquement le premier nombre, pas les nombres qui seraient dans le supplement
  it
}
#show ref: it => {
  if it.element == none {
    // Référence vers une entrée de bibliographie -> `#show cite` précédent
    return it
  }
  // Référence vers une section ou figure
  show regex("[\d]+[\.]?[\d]*[\.]?[\d]*"): set text(fill: prune) // recherche le motif "1", "1.2" ou "1.3"...
  it
}

// Légende de figure en italique et taille de police réduite

#show figure.caption: it => [
  #text(size: 10pt, style: "italic")[#it]
]

// Justification du texte

#set par(
  linebreaks: "optimized",
  justify: true,
)

//////////////////////////////////////////////////
// Rédiger le rapport ci-dessous. Bon courage ! //
//////////////////////////////////////////////////

// Plan
#outline()

= Partie <p:partie>

#lorem(50)

#summary[
  #lorem(25)
]

== Sous-partie <p:sous-partie>

#lorem(25)

=== Sous-sous-partie <ch:sous-sous-partie>

#lorem(50) @bib:what-i-did-holidays

#remark[
  #lorem(25)
]

#remark(number: 1, [On peut aussi numéroter les remarques.])

#lorem(50)

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
  caption: [Mesures de temps],
)

#figure(numbering: "1")[
  ```py
  def my_func():
    print("Hello World")
  ```
]

#table-list()

#figure-list()

#lexicon(
  [
    / Ligature: A merged glyph.
    / Kerning: A spacing adjustment between two adjacent letters.
  ],
)

#bibliography("bib.yml", title: [Bibliographie])
