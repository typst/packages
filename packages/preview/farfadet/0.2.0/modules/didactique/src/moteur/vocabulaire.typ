// vocabulaire.typ — \voc et \printvocindex (bfcours-vocabulary.sty).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "../../../maths/lib.typ": interne as _maths
#import _maths: acc, bf-texte-brut

/// \voc{mot} : comme \acc, et première occurrence consignée dans l'index du vocabulaire.
#let voc(mot) = {
  [#metadata((mot: mot, cle: bf-texte-brut(mot).trim()))<bf-voc>]
  acc(mot)
}

// =====================================================================
// Index du vocabulaire : \printvocindex
// =====================================================================

/// \printvocindex : boîte « Vocabulaire utilisé », mots en gras sur trois colonnes, avec leur page.
/// Seule la première occurrence de chaque mot compte (même texte).
#let printvocindex(colonnes: 3, titre: [Vocabulaire utilisé], colframe: auto, colback: auto, coltitle: white) = context {
  let vus = ()
  let entrees = ()
  for m in query(<bf-voc>) {
    if m.value.cle in vus { continue }
    vus.push(m.value.cle)
    entrees.push((mot: m.value.mot, page: m.location().page(), lieu: m.location()))
  }
  let bleu = if colframe == auto { xmix(xc.blue, 50, autre: black) } else { bf-resoudre-couleur(colframe) }
  let fond = if colback != auto { bf-resoudre-couleur(colback) } else { xmix(xc.gray, if entrees.len() == 0 { 5 } else { 10 }) }
  let il = bf-lire(bf-interligne-p)
  let regle = 0.5mm
  let corps = if entrees.len() == 0 [Aucun mot de vocabulaire n'a été défini.] else {
    let par-colonne = calc.ceil(entrees.len() / colonnes)
    let cols = range(colonnes).map(k => entrees.slice(
      calc.min(k * par-colonne, entrees.len()),
      calc.min((k + 1) * par-colonne, entrees.len()),
    ))
    grid(
      columns: (1fr,) * colonnes,
      column-gutter: 10pt * 72 / 72.27,
      ..cols.map(liste => {
        set par(justify: false, leading: il.baselineskip - 11pt, spacing: il.baselineskip - 11pt + 2.35pt)
        for e in liste {
          block(below: 16.8pt - 11pt, above: 0pt, pad(left: 27.28pt, [#h(-27.28pt)#box(width: 27.28pt - 5.45pt, align(right, $bullet$))#h(5.45pt)#strong(e.mot) #link(e.lieu)[(p.~#e.page)]]))
        }
      }),
    )
  }
  let titre = box(
    fill: bleu,
    radius: (top: 1mm),
    inset: (x: 6.52pt, top: 3.65pt, bottom: 5.21pt - 1.42pt),
    text(fill: bf-resoudre-couleur(coltitle), weight: "bold", top-edge: "bounds", bottom-edge: "bounds", titre),
  )
  block(width: 100%, above: 1em, below: 1em, breakable: false, {
    block(below: 0pt, pad(left: 1.42pt + 2.83pt + 4mm - 6.52pt, titre))
    block(
      width: 100%,
      above: 0pt,
      fill: bleu,
      radius: 1mm,
      inset: regle,
      block(
        width: 100%,
        fill: fond,
        radius: 1mm - regle,
        inset: (x: 1mm + 4mm, top: 19.46pt - 8.25pt, bottom: 8.51pt - 2.75pt),
        corps,
      ),
    )
  })
}
