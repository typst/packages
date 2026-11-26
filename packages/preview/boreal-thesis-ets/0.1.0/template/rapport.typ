// ============================================================
// GABARIT DE RÉDACTION ÉTS — VERSION TYPST
// Document en français. Voir GUIDE.md pour la documentation complète.
//
// Compilation :  typst compile rapport.typ
// Aperçu continu : typst watch rapport.typ
// ============================================================

#import "@preview/boreal-thesis-ets:0.1.0": *

#show: ets-document.with(
  // ---- Type de document (un seul) ----
  // these | thesepararticles | memoire | memoirepararticles | rapportprojet
  type: "these",
  lang: "fr",

  // ---- Licence : "reserved" (défaut) ou "creativecommons" ----
  licence: "creativecommons",

  // ---- Filigrane « CONFIDENTIEL » sur la page de titre ----
  confidential: true,

  // ---- Page de titre ----
  title: [Titre du document],
  author: (firstname: "Prénom", lastname: "Nom de famille"),
  // Optionnel : forcer un libellé des droits d'auteur différent.
  // copyright-holder: "Prénom Nom de famille",
  defense-date: datetime(year: 2026, month: 5, day: 15),
  deposit-date: datetime(year: 2025, month: 11, day: 30),

  // ---- Jury ----
  // Chaque membre : (name: ..., dept: ..., affiliation: ...)
  // `affiliation` est facultative (défaut : École de technologie supérieure).
  supervisor: (name: "Prénom Nom", dept: "Nom du département"),
  cosupervisor: (
    name: "Prénom Nom",
    dept: "Nom du département",
    affiliation: "à l'École XXX",
  ),
  chair: (name: "Prénom Nom", dept: "Nom du département"),
  jury: (
    (name: "Prénom Nom", dept: "Nom du département"),
    // (name: "Prénom Nom", dept: "Nom du département"), // deuxième membre du jury
  ),
  external-examiners: (
    (name: "Prénom Nom", affiliation: "Nom de la compagnie"),
    // (name: "Prénom Nom", affiliation: "Nom de la compagnie"), // deuxième examinateur externe
  ),
  independent-examiner: (
    name: "Prénom Nom",
    affiliation: "Nom de la compagnie",
  ),

  // ---- Intitulé du diplôme : concentration (facultatif) ----
  concentration: "génie logiciel",

  // ---- Cotutelle (facultatif) ----
  cotutorship: "ECOLE NATIONALE DE XXXX",
)

// Texte de remplissage utilisé dans les exemples ci-dessous.
#let exemple = lorem(90)

// ============================================================
// SECTIONS PRÉLIMINAIRES
// ============================================================

#foreword
#exemple

#acknowledgements
#exemple

#resume(keywords: "mot-clé1, mot-clé2")[
  #exemple
]

#abstract(title: [English title of the thesis], keywords: "keyword1, keyword2")[
  #exemple
]

#table-of-contents()

#list-of-tables()

#list-of-figures()

// Liste unifiée : algorithmes et extraits de code.
#list-of-algorithms()

#list-of-abbreviations((
  ("ETS", "École de technologie supérieure"),
  ("ASC", "Agence spatiale canadienne"),
))

// Variante triée automatiquement : ajouter `sorted: true`.
// #list-of-abbreviations(sorted: true, (
//   ("PDF", "Portable Document Format"),
//   ("API", "Interface de programmation applicative"),
// ))

#list-of-symbols((
  ($a$, "Première lettre de l'alphabet"),
  ($A$, "Première lettre de l'alphabet en majuscule"),
))

// ============================================================
// CORPS DU DOCUMENT
// ============================================================

#show: introduction

#exemple

#ets-figure(
  image("Figures/vueEts.jpg", width: 100%),
  caption: [Exemple de figure],
  label: <fig:vueEts>,
  source: "Source de l'image",
  year: 2024,
)

#exemple

#ets-figure(
  width: 0.975 * thets-config.text-width,
  frame: true,
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.02 * thets-config.text-width,
    ets-subfigure(
      image("Figures/vueEts.jpg", width: 100%),
      caption: [Première sous-figure],
      label: <fig:sub-a>,
    ),
    ets-subfigure(
      image("Figures/vueEts.jpg", width: 100%),
      caption: [Deuxième sous-figure],
      label: <fig:sub-b>,
    ),
  ),
  caption: [Exemple de figure avec sous-figures],
  label: <fig:grid>,
)

= Premier chapitre de démonstration

== Tests de mise en page

Dans cette section, différents environnements de mise en page sont présentés.

=== Listes

Présentation des principales listes : les énumérations et les listes à puces.

==== Énumérations

+ test 1
+ test 2

==== Listes à puces

- test 1
- test 2

=== Équations

Mise en page des équations.

$ beta = 8 $ <eq:beta>

$ bold(gamma) = alpha times 3 $

== Seconde section

Exemple de seconde section pour illustrer la mise en page de la table des matières.

#ets-algorithm(
  caption: [Exemple d'algorithme],
  label: <alg:example>,
  source: "Source de l'algorithme",
  year: 2024,
  {
    algo-reset()
    [#kw[Entrées :] Galerie de gabarits initiaux $cal(G) = {bold(r)_1, ..., bold(r)_J}$, \
      ensemble d'adaptation non étiqueté $cal(D) = {bold(d)_1, ..., bold(d)_L}$]
    parbreak()
    [#kw[Sorties :] Galerie mise à jour $cal(G)' = {bold(r)_1, ..., bold(r)_(J')}$, $J' >= J$]
    parbreak()
    algo-line[Estimer le seuil de mise à jour $gamma^u >= gamma^d$ à partir de $cal(G)$]
    algo-line[$cal(G) arrow.l cal(G)'$ #h(1em) #emph[mise à jour de la galerie]]
    algo-line[#kw[pour] tout échantillon $d_l in cal(D)$ #kw[faire]]
    algo-line[#h(1.5em) #kw[pour] toute référence $r_j in cal(G)$ #kw[faire]]
    algo-line[#h(
        3em,
      ) $s_j (bold(d)_l) arrow.l "similarite"(bold(d)_l, bold(r)_j)$]
    algo-line[$S(bold(d)_l) arrow.l max_(j in [1,J]) {s_j (bold(d)_l)}$]
    algo-line[#kw[si] $S(bold(d)_l) >= gamma_d$ #kw[alors] prédiction positive]
  },
)

Exemple d'extrait de code.

#ets-listing(
  ```python
  def bonjour_ets():
      return "ok"
  ```,
  caption: [Exemple Python (même liste que les algorithmes)],
  label: <lst:exemple>,
  source: "Dépôt d'exemple",
  year: 2024,
)

= Ajout d'un second chapitre

== Test de mise en page d'un tableau

Les tableaux sont soumis aux mêmes contraintes que les figures, en dehors de la
position de la légende qui doit être au-dessus.

#ets-table(
  caption: [Exemple de tableau],
  label: <tab:testTab>,
  source: "Source du tableau",
  year: 2024,
  table(
    columns: 8,
    align: center,
    ..([titre],) * 8,
    ..([blá],) * 48,
  ),
)

Exemple de tableau long qui se poursuit automatiquement sur plusieurs pages,
avec l'en-tête répété en haut de chaque page.

#ets-longtable(
  caption: [Exemple de tableau long avec en-tête répété],
  label: <tab:testLongTab>,
  source: "Source du tableau",
  year: 2024,
  table(
    columns: 2,
    align: center,
    table.header([Something], [something else]),
    ..(([Lots of lines], [like this]),).flatten() * 28,
  ),
)

== Tests de paragraphes et sous-paragraphes

===== Test d'un paragraphe
#exemple

====== Test d'un sous-paragraphe
#exemple

== Test des références

=== Références à la bibliographie

Citation d'une référence de la bibliographie @BookExample.

=== Références à un label du document

Référence à une figure associée à une étiquette : @fig:vueEts.
Référence à un tableau : @tab:testTab.
Référence à une équation : @eq:beta.

=== Références à des adresses

Utilisation de #link("https://www.etsmtl.ca/etudes/cycles-superieurs")[lien vers
  la page des gabarits de l'ÉTS] pour intégrer un lien dans une portion de texte,
ou affichage direct de l'adresse :
#link("https://www.etsmtl.ca/etudes/cycles-superieurs").

= Exemple de thèse par articles intégrés

#article-authors(
  authors: ([Prénom Nom#super[1]], [Prénom Nom#super[2]]),
  affiliations: (
    [#super[1] Département de génie mécanique, École de technologie supérieure,
      1100 Notre-Dame Ouest, Montréal, Québec, Canada H3C 1K3],
    [#super[2] HydroClimat TVT, Maison du Numérique et de l'Innovation,
      place Georges Pompidou, 83000 Toulon, France],
  ),
  status: article-submitted(datetime(year: 2010, month: 9, day: 1)),
)

#exemple

#conclusion

#exemple

#recommendations

#exemple

// ============================================================
// ANNEXES
// ============================================================

#show: annexes

= Exemple d'annexe

== Première section de l'annexe

== Deuxième section de l'annexe

Section d'annexe additionnelle pour illustrer la numérotation des chapitres
dans les annexes.

=== Figures dans les annexes

#ets-figure(
  image("Figures/vueEts.jpg", width: 100%),
  caption: [Exemple de figure dans une annexe],
  label: <fig:vueEtsAnnexe>,
  source: "Source de l'image",
  year: 2024,
)

Dans les annexes, les figures sont déclarées de la même manière. Leur
numérotation change automatiquement (par exemple, @fig:vueEtsAnnexe).

=== Tableaux dans les annexes

#ets-table(
  caption: [Exemple de tableau dans une annexe],
  label: <tab:testTabAnnex>,
  table(
    columns: 8,
    align: center,
    ..([titre],) * 8,
    ..([blá],) * 48,
  ),
)

Comportement identique pour les tableaux (par exemple, @tab:testTabAnnex).

= Exemple d'annexe 2

== Première section de l'annexe 2

#exemple

// ============================================================
// APPENDICES
// ============================================================

#show: appendices

= Exemple d'appendice

== Première section de l'appendice

Ce court appendice illustre la numérotation des chapitres en lettres.

=== Section de second niveau de l'appendice

== Deuxième section de l'appendice

= Exemple d'appendice 2

== Première section de l'appendice 2

// ============================================================
// BIBLIOGRAPHIE
// ============================================================

// `full: true` imprime toutes les entrées du fichier .bib, y compris celles
// qui ne sont pas citées (équivalent de \nocite{*}).
#ets-bibliography(read("biblio_fr.bib", encoding: none), full: true)

// Liste de références secondaire (facultative), intitulée « BIBLIOGRAPHIE ».
// Équivalent des commandes multibib « refs » du gabarit LaTeX ; ici, aucune
// passe BibTeX supplémentaire n'est nécessaire.
#ets-references(read("refs.bib", encoding: none), full: true)
