// ============================================================
//  Modèle de cours — démarrez ici
//  Remplacez le contenu (texte, images) par le vôtre.
// ============================================================

#import "@preview/coquille-st-jacques:0.1.0": *

#show: course-template.with(
  title: "Titre de votre cours",
  author: "Votre nom",

  eyebrow: [MATIÈRE — NIVEAU],
  cover-title: [Titre principal \ sur deux lignes],
  cover-subtitle: "Une phrase d'accroche",
  cover-metadata: [Contexte · classe · établissement],
  cover-background: image("cover.png", width: 100%, height: 100%, fit: "cover"),

  show-toc: true,
)

= Premier chapitre

Voici un paragraphe d'introduction. La syntaxe Typst est très proche
de ce qu'on écrit naturellement : *gras*, _italique_, `monospace`.

#def[
  *Terme nouveau* — la définition tient en une phrase claire et
  accessible au niveau visé.
]

#key[
  Le point essentiel à retenir, en une ou deux phrases.
]

== Une sous-partie

#warn[
  Attention à ne pas confondre ce concept avec un autre proche.
]

#ex[
  Un exemple concret tiré de la vie courante, qui ancre la notion.
]

#analogy[
  Une comparaison qui aide à comprendre, par image mentale.
]

= Deuxième chapitre

Pour insérer un schéma avec une légende :

#schema(
  image("schema.png", width: 100%),
  [Schéma — décrivez ici ce que l'on voit],
)

#keyhint[
  La clé de compréhension globale : ce qu'il faut « voir » pour que
  toute la suite devienne évidente.
]

= Auto-test

#qcm-q(1, [Une question avec choix multiple ?],
  options: ([Choix A], [Choix B], [Choix C]))

#qcm-q(2, [Une question à réponse libre.], lines: 3)

#qcm-q(3, [Une question d'observation, sans cadre de réponse.])
