// Composant de carte de résultat de vote
#import "src/translations.typ": translations

#let vote-card(
  numero: none,
  pour: 1,
  contre: 0,
  abstention: 0,
  connexions: 1,
  lang: "fr",
) = {
  let t = translations.at(lang, default: translations.fr)
  // Couleurs basées sur la capture d'écran
  let bar-color-bg = rgb("#f1f5f9")
  let color-pour = rgb("#147b3d") // Vert foncé
  let color-contre = rgb("#ad1d1d") // Rouge foncé
  let color-abs = rgb("#4a596e") // Bleu-gris
  let color-text-muted = rgb("#6b7280")
  let top-border-color = rgb("#102a4a") // Bleu très foncé

  let total = pour + contre + abstention
  let max-val = if total == 0 { 1 } else { total }

  // Calcul des pourcentages pour la largeur des barres
  let pct-pour = (pour / max-val) * 100%
  let pct-contre = (contre / max-val) * 100%
  let pct-abs = (abstention / max-val) * 100%

  // Détermination du résultat global
  let resultat = if pour > contre {
    (t.at("for"), color-pour)
  } else if contre > pour {
    (t.against, color-contre)
  } else if total == 0 {
    (t.pending, color-text-muted)
  } else {
    (t.tie, color-text-muted)
  }

  // Polices à espacement fixe pour supporter le zéro barré
  let fonts-mono = ("Consolas", "Fira Code", "Menlo", "Courier New", "monospace")

  let mono(t) = text(font: fonts-mono, fill: color-text-muted, size: 9pt)[#t]
  let mono-num(t) = text(font: fonts-mono, size: 15pt, weight: "bold", fill: rgb("#111827"))[#t]

  block(
    width: 100%,
    breakable: false,
    stroke: (
      top: 3pt + top-border-color,
      rest: 1pt + rgb("#e2e8f0"),
    ),
    inset: (top: 1.5em, bottom: 1.5em, left: 2em, right: 2em),
  )[
    #set align(center)

    #if numero != none [
      #text(size: 11pt, weight: "bold", fill: color-text-muted)[#t.vote_no#numero] \
      // #v(0.3em)
    ]

    #text(size: 18pt, weight: "bold", fill: resultat.at(1))[
      #t.result#resultat.at(0)
    ]

    // #v(0.6em)
    // #mono[#connexions connexion#if connexions > 1 { "s" } en ce moment]

    // #v(0.2em)
    #mono[#total #if total > 1 { t.voters } else { t.voter }]

    // #v(3em)

    #let row(label, value, color, pct) = {
      set align(left)
      grid(
        columns: (1fr, auto),
        align(left)[#text(weight: "bold", fill: color, size: 10pt)[#label]], align(right)[#mono-num(str(value))],
      )
      // v(0.2em)
      box(
        width: 100%,
        height: 3pt,
        fill: bar-color-bg,
        radius: 3pt,
      )[
        #if pct > 0% [
          #box(
            width: pct,
            height: 100%,
            fill: color,
            radius: 3pt,
          )
        ]
      ]
      // v(.5em)
    }

    #row(t.at("for"), pour, color-pour, pct-pour)
    #row(t.against, contre, color-contre, pct-contre)
    #row(t.abstention, abstention, color-abs, pct-abs)
  ]
}
