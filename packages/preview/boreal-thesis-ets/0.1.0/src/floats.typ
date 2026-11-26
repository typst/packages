// ============================================================
// thETS — Figures, tableaux, extraits de code et algorithmes.
// Portage des environnements etsfigure, etstable, etslongtable,
// etslstlisting et de la commande \source (section 9b de thETS.cls).
// ============================================================

#import "config.typ" as cfg
#import "i18n.typ": tr
#import "state.typ": doc-lang, doc-part

// Genre partagé par les algorithmes et les extraits de code : le gabarit ÉTS
// les numérote dans une seule suite et les regroupe dans une seule liste.
#let algo-kind = "ets-algorithm"

// Genre des sous-figures, numérotées a), b), … dans chaque figure parente.
#let subfigure-kind = "ets-subfigure"

// ---------------------------------------------------------------------------
// Numérotation des flottants et des équations
// ---------------------------------------------------------------------------
// Les flottants sont numérotés « <chapitre><sép><n> » :
//   corps        → 1.3   (chapitre arabe, séparateur « . »)
//   annexes      → I-3   (chapitre romain, séparateur « - »)
//   appendices   → A.3   (chapitre alphabétique, séparateur « . »)
//
// Contrainte Typst : la fonction de numérotation d'un élément est évaluée à
// l'endroit où le numéro est AFFICHÉ (corps du texte, référence croisée, liste
// des figures), et non à l'endroit où l'élément se trouve. Lire le compteur de
// chapitre avec `context` à l'intérieur de cette fonction donnerait donc le
// chapitre de la référence, pas celui de la figure.
//
// Le gabarit contourne cela avec un registre : à l'ouverture de chaque
// chapitre, on note la valeur courante (globale, jamais remise à zéro) de
// chaque compteur de flottant. La fonction de numérotation retrouve ensuite le
// chapitre d'un flottant à partir de son seul numéro global, en consultant la
// valeur FINALE du registre — identique quel que soit le lieu d'affichage.

#let chapter-marks = state("thets-chapter-marks", (:))

// Clés du registre, une par compteur suivi.
#let mark-keys = ("image", "table", algo-kind, "equation")

#let counter-for(key) = {
  if key == "image" { counter(figure.where(kind: image)) } else if (
    key == "table"
  ) { counter(figure.where(kind: table)) } else if key == "equation" {
    counter(math.equation)
  } else { counter(figure.where(kind: algo-kind)) }
}

// Enregistre l'ouverture d'un chapitre. À appeler dans la règle show des
// titres de niveau 1, depuis un contexte.
//   chapter : numéro de chapitre déjà formaté (« 2 », « I », « A »…)
//   sep     : séparateur chapitre ↔ numéro de flottant
//   annex   : vrai dans les annexes (préfixe « A » des équations)
#let record-chapter(chapter, sep, annex) = context {
  let counts = (:)
  for key in mark-keys {
    counts.insert(key, counter-for(key).get().first())
  }
  chapter-marks.update(marks => {
    let updated = marks
    for key in mark-keys {
      let previous = updated.at(key, default: ())
      updated.insert(
        key,
        previous
          + (
            (count: counts.at(key), chapter: chapter, sep: sep, annex: annex),
          ),
      )
    }
    updated
  })
}

// Dernier chapitre ouvert avant le flottant n° `n` de la catégorie `key`.
#let mark-for(key, n) = {
  let marks = chapter-marks.final().at(key, default: ())
  marks.filter(m => m.count < n).at(-1, default: none)
}

#let float-numbering(key) = (..nums) => context {
  let n = nums.pos().last()
  let m = mark-for(key, n)
  if m == none { [#n] } else { [#m.chapter#m.sep#(n - m.count)] }
}

#let equation-numbering = (..nums) => context {
  let n = nums.pos().last()
  let m = mark-for("equation", n)
  if m == none {
    [(#n)]
  } else if m.annex {
    [(A #m.chapter#m.sep#(n - m.count))]
  } else {
    [(#m.chapter#m.sep#(n - m.count))]
  }
}

#let image-numbering = float-numbering("image")
#let table-numbering = float-numbering("table")
#let algo-numbering = float-numbering(algo-kind)

// ---------------------------------------------------------------------------
// Source d'une figure, d'un tableau ou d'un algorithme
// ---------------------------------------------------------------------------

// Rend la ligne « Tiré de X (2024) ». Interligne simple, centrée.
// La source n'apparaît jamais dans les listes : elle est ajoutée par une règle
// show locale à un seul flottant, et non dans le corps de la légende.
#let source-line(source, year) = context {
  let s = tr(doc-lang.get())
  set par(leading: cfg.leading-single, spacing: 0pt, justify: false)
  set align(center)
  s.taken-from + source + if year != none { " (" + str(year) + ")" } else { "" }
}

// Règle show appliquée localement : légende de largeur imposée, puis source.
#let caption-decorator(width: none, source: none, year: none) = {
  it => {
    set par(leading: cfg.leading-single, spacing: 0pt, justify: false)
    let rendered = if width == none { it } else { box(width: width, it) }
    align(center, rendered)
    if source != none {
      v(cfg.source-skip, weak: false)
      source-line(source, year)
    }
  }
}

// Attache une étiquette à un élément construit par code.
#let with-label(body, lbl) = if lbl == none { body } else { [#body#lbl] }

// ---------------------------------------------------------------------------
// Figures
// ---------------------------------------------------------------------------

// Figure au format ÉTS : image centrée, cadre optionnel, légende plus étroite
// que l'image (exigence du décanat) et attribution de source facultative.
//
//   #ets-figure(
//     image("Figures/vueEts.jpg"),
//     caption: [Exemple de figure],
//     label: <fig:vueEts>,
//     source: "Source de l'image", year: 2024,
//   )
#let ets-figure(
  body,
  caption: none,
  label: none,
  source: none,
  year: none,
  width: auto,
  frame: true,
  frame-sep: 0pt,
  caption-width-factor: cfg.figure-caption-width-factor,
  placement: none,
) = {
  let w = if width == auto { cfg.figure-default-width } else { width }
  let inner = block(width: w, {
    // Les sous-figures sont renumérotées a), b), … dans chaque figure parente.
    counter(figure.where(kind: subfigure-kind)).update(0)
    if frame {
      rect(width: 100%, inset: frame-sep, stroke: 0.4pt + black, body)
    } else {
      body
    }
  })
  [
    #show figure.caption: caption-decorator(
      width: caption-width-factor * w,
      source: source,
      year: year,
    )
    #with-label(
      figure(
        inner,
        caption: caption,
        kind: image,
        placement: placement,
      ),
      label,
    )
  ]
}

// Sous-figures : légendes « a) », « b) », … comme le format ÉTS.
// À placer dans une grille passée en corps de #ets-figure.
#let ets-subfigure(body, caption: none, label: none, width: 100%) = {
  [
    #show figure.caption: it => {
      set par(leading: cfg.leading-single, spacing: 0pt, justify: false)
      align(center, it)
    }
    #with-label(
      figure(
        block(width: width, body),
        caption: caption,
        kind: subfigure-kind,
        supplement: [],
        numbering: n => numbering("a", n) + ")",
        outlined: false,
      ),
      label,
    )
  ]
}

// ---------------------------------------------------------------------------
// Tableaux
// ---------------------------------------------------------------------------

// Tableau au format ÉTS : légende AU-DESSUS, source juste sous la légende.
#let ets-table(
  body,
  caption: none,
  label: none,
  source: none,
  year: none,
  caption-width: cfg.table-caption-width,
  placement: none,
) = {
  [
    #show figure.caption: caption-decorator(
      width: caption-width,
      source: source,
      year: year,
    )
    #show figure.where(kind: table): set figure.caption(position: top)
    #with-label(
      figure(
        body,
        caption: caption,
        kind: table,
        placement: placement,
      ),
      label,
    )
  ]
}

// Tableau long : se poursuit automatiquement sur plusieurs pages.
// L'en-tête passé à `table.header(repeat: true)` est répété en haut de chaque
// page, comme le faisait etslongtable.
#let ets-longtable(
  body,
  caption: none,
  label: none,
  source: none,
  year: none,
  caption-width: cfg.table-caption-width,
) = {
  [
    #show figure.caption: caption-decorator(
      width: caption-width,
      source: source,
      year: year,
    )
    #show figure.where(kind: table): set figure.caption(position: top)
    #show figure: set block(breakable: true)
    #with-label(
      figure(
        body,
        caption: caption,
        kind: table,
      ),
      label,
    )
  ]
}

// ---------------------------------------------------------------------------
// Extraits de code et algorithmes (liste et compteur unifiés)
// ---------------------------------------------------------------------------

// Extrait de code encadré, légende au-dessus.
//
//   #ets-listing(
//     ```python
//     def bonjour_ets():
//         return "ok"
//     ```,
//     caption: [Exemple Python], label: <lst:exemple>,
//   )
#let ets-listing(
  code,
  caption: none,
  label: none,
  source: none,
  year: none,
  caption-width: none,
) = {
  [
    #show figure.caption: caption-decorator(
      width: caption-width,
      source: source,
      year: year,
    )
    #show figure.where(kind: algo-kind): set figure.caption(position: top)
    #with-label(
      figure(
        rect(width: 100%, inset: 8pt, stroke: 0.4pt + black, align(left, code)),
        caption: caption,
        kind: algo-kind,
      ),
      label,
    )
  ]
}

// Algorithme encadré : même compteur et même liste que les extraits de code.
// Le corps est libre ; utiliser #algo-line pour numéroter les lignes.
#let ets-algorithm(
  body,
  caption: none,
  label: none,
  source: none,
  year: none,
  caption-width: none,
) = {
  [
    #show figure.caption: caption-decorator(
      width: caption-width,
      source: source,
      year: year,
    )
    #show figure.where(kind: algo-kind): set figure.caption(position: top)
    #with-label(
      figure(
        rect(
          width: 100%,
          inset: 8pt,
          stroke: 0.4pt + black,
          {
            set par(
              leading: cfg.leading-single,
              spacing: 0.35em,
              justify: false,
            )
            align(left, body)
          },
        ),
        caption: caption,
        kind: algo-kind,
      ),
      label,
    )
  ]
}

// Numérotation des lignes d'un algorithme : à remettre à zéro au début de
// chaque algorithme avec #algo-reset().
#let algo-line-counter = counter("thets-algo-line")
#let algo-reset() = algo-line-counter.update(0)
#let algo-line(body) = {
  algo-line-counter.step()
  grid(
    columns: (1.6em, 1fr),
    align: (right + top, left),
    context [#algo-line-counter.display()#h(0.4em)], body,
  )
}

// Mots-clés d'algorithme mis en forme comme algorithm2e.
#let kw(body) = strong(body)
