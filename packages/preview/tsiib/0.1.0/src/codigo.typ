// ==========================================
// BLOQUES DE CÓDIGO FUENTE ACADÉMICO
// ==========================================

#import "counters.typ": numbering-seccion

#let codigo-formal(codigo, lang: "python", titulo: none) = {
  let texto = if type(codigo) == str { codigo } else { codigo.text }

  let bloque = block(
    width: 100%,
    fill: luma(250),
    stroke: 0.5pt + luma(200),
    inset: (x: 1em, y: 1em),
    radius: 2pt,
    breakable: true,
    [
      #set align(left)
      #set text(size: 10pt)

      #show raw.line: it => {
        box(
          width: 1.5em,
          align(right, text(fill: luma(150), size: 8pt)[#it.number])
        )
        h(1em)
        it.body
      }

      #raw(texto, block: true, lang: lang)
    ]
  )

  if titulo != none {
    figure(
      bloque,
      kind: "code",
      supplement: [Listado],
      numbering: numbering-seccion,
      caption: titulo,
    )
  } else {
    bloque
  }
}
