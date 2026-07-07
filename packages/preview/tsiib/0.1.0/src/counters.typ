// ==========================================
// UTILIDADES DE CONTADORES Y PREFIJOS DE SECCIÓN
// Numeración homogénea: sección principal (1.x)
// ==========================================

// Numbering para figures/tablas/código
#let numbering-seccion = n => {
  context {
    let h = counter(heading).get()
    if h.len() > 0 and h.at(0) > 0 {
      str(h.at(0)) + "." + str(n)
    } else {
      str(n)
    }
  }
}

// Numbering para ecuaciones
#let numbering-ecuacion = n => {
  context {
    let h = counter(heading).get()
    if h.len() > 0 and h.at(0) > 0 {
      "(" + str(h.at(0)) + "." + str(n) + ")"
    } else {
      "(" + str(n) + ")"
    }
  }
}
