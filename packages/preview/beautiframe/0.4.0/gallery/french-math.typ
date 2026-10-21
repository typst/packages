#import "@preview/beautiframe:0.4.0": *

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: "New Computer Modern", size: 10pt)

#align(center)[#text(size: 14pt, weight: "bold")[French Math Preset & New Features]]

#v(0.5em)

#preset-french-math-bw()
#beautiframe-setup(
  qr-renderer: url => block(
    width: 1.85cm, height: 1.85cm,
    stroke: 0.5pt,
    fill: luma(90%),
    inset: 3pt,
  )[#align(center + horizon)[#text(size: 5pt)[QR]]],
  qr-width: 1.85cm,
)
#beautiframe-reset-french-math()

// ── QR Sidebar ──────────────────────────────────────────────────────────────
*QR sidebar* (any env):

#theoreme(
  name: "Pythagore",
  qr: "https://example.com/pythagore",
)[
  Dans tout triangle rectangle: $a^2 + b^2 = c^2$.
]

// ── Fill Space: lines ────────────────────────────────────────────────────────
*Fill space* — `space: "lines"`:

#pratique(space: "lines", space-height: 3cm)[
  Résoudre l'équation $2x - 5 = 7$ et vérifier votre réponse.
]

// ── Fill Space: grid ─────────────────────────────────────────────────────────
*Fill space* — `space: "grid"`:

#exemple(space: "grid", space-height: 4cm)[
  Représenter graphiquement la fonction $f(x) = -x^2 + 4$ sur $[-3 ; 3]$.
]

// ── Formule ──────────────────────────────────────────────────────────────────
#formule(name: "Quadratique")[
  Les solutions de $a x^2 + b x + c = 0$ (avec $a != 0$) sont
  $x = display((-b plus.minus sqrt(b^2 - 4 a c)) / (2 a))$.
]

// ── Formules (plural) ────────────────────────────────────────────────────────
#formules[
  - $sin^2 theta + cos^2 theta = 1$
  - $tan theta = sin theta / cos theta$
]

// ── Méthode ──────────────────────────────────────────────────────────────────
#methode(name: "Résolution par factorisation")[
  + Identifier les termes à factoriser.
  + Poser $f(x) = 0$ et factoriser.
  + Lire les solutions comme zéros de chaque facteur.
]

// ── Notation ─────────────────────────────────────────────────────────────────
#notation[
  On note $f'$ la fonction dérivée de $f$, et $f''$ sa dérivée seconde.
]

// ── Discussion ───────────────────────────────────────────────────────────────
#discussion[
  Le discriminant $Delta = b^2 - 4 a c$ permet de déterminer le nombre de solutions réelles : deux si $Delta > 0$, une si $Delta = 0$, aucune si $Delta < 0$.
]
