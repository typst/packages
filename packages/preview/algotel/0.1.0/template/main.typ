// AlgoTel/CoRes submission template
// Documentation: https://github.com/balouf/algotel

#import "@preview/algotel:0.1.0": algotel, qed
#import "@preview/algotel:0.1.0": theorem, lemma, proposition, corollary, definition, remark, example, proof

// Change lang: "fr" to lang: "en" for an English submission.
#show: algotel.with(
  title: [Titre de la soumission],
  short-title: [Titre court],
  authors: (
    (name: "Prénom Nom", affiliations: (1,)),
    (name: "Autre Auteur", affiliations: (1, 2)),
  ),
  affiliations: (
    (id: 1, name: "Laboratoire, Université, Ville, Pays"),
    (id: 2, name: "Autre Laboratoire, Ville, Pays"),
  ),
  abstract: [
    Résumé de l'article. Ce résumé doit être concis et refléter les contributions principales du travail.
  ],
  keywords: ("mot-clé 1", "mot-clé 2", "mot-clé 3"),
  lang: "fr",
)

= Introduction

Votre texte ici. Ce template est dérivé de la classe LaTeX `algotel.cls` pour les soumissions aux conférences AlgoTel et CoRes.

= Contributions

== Résultat principal

#theorem[
  Énoncé du théorème.
]

#proof[
  Preuve du théorème.
]

= Conclusion

Conclusion de l'article.

#bibliography("sample-algotel.bib")
