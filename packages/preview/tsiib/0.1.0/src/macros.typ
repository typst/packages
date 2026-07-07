// ==========================================
// ENTORNOS MATEMÁTICOS
// ==========================================

#import "counters.typ": numbering-ecuacion

// Fábrica de entornos numerados — contadores planos sin context anidado
#let entorno-numerado(kind, nombre, cuerpo, titulo: none) = {
  figure(
    block(
      width: 100%,
      above: 1.5em,
      below: 1.5em,
      breakable: true,
      {
        set align(left)
        set par(justify: true, leading: 0.6em, first-line-indent: 1.5em)
        context {
          let n = counter(figure.where(kind: kind)).get().at(0)
          let h = counter(heading).get()
          let sec = if h.len() > 0 and h.at(0) > 0 { str(h.at(0)) } else { none }
          let num = if sec != none { sec + "." + str(n) } else { str(n) }
          if titulo != none {
            [ #text(weight: "bold")[#nombre #num (#titulo).] #cuerpo ]
          } else {
            [ #text(weight: "bold")[#nombre #num.] #cuerpo ]
          }
        }
      }
    ),
    kind: kind,
    supplement: [#nombre],
    numbering: "1",
    caption: none,
    placement: none,
    outlined: false,
  )
}

// Entorno no numerado genérico
#let entorno-no-numerado(nombre, cuerpo, qed: false) = {
  block(
    width: 100%,
    above: 1.5em,
    below: 1.5em,
    breakable: true,
    {
      set align(left)
      set par(justify: true, leading: 0.6em, first-line-indent: 1.5em)
      if qed {
        [*#nombre.* #cuerpo #h(1fr) $square$]
      } else {
        [*#nombre.* #cuerpo]
      }
    }
  )
}

// ── Macros públicas ──

#let teorema(titulo: none, cuerpo) = entorno-numerado("teo", "Teorema", cuerpo, titulo: titulo)
#let proposicion(titulo: none, cuerpo) = entorno-numerado("teo", "Proposición", cuerpo, titulo: titulo)
#let corolario(titulo: none, cuerpo) = entorno-numerado("teo", "Corolario", cuerpo, titulo: titulo)
#let axioma(titulo: none, cuerpo) = entorno-numerado("teo", "Axioma", cuerpo, titulo: titulo)

#let problema(titulo: none, cuerpo) = entorno-numerado("prob", "Problema", cuerpo, titulo: titulo)
#let ejemplo(titulo: none, cuerpo) = entorno-numerado("ej", "Ejemplo", cuerpo, titulo: titulo)
#let definicion(titulo: none, cuerpo) = entorno-numerado("def", "Definición", cuerpo, titulo: titulo)
#let lema(titulo: none, cuerpo) = entorno-numerado("lema", "Lema", cuerpo, titulo: titulo)

#let demostracion(cuerpo) = entorno-no-numerado("Demostración", cuerpo, qed: true)
#let solucion(cuerpo) = entorno-no-numerado("Solución", cuerpo)

#let ecuacion(cuerpo) = {
  math.equation(block: true, numbering: numbering-ecuacion, cuerpo)
}
