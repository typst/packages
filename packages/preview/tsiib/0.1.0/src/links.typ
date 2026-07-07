// ==========================================
// CONFIGURACIÓN DE HIPERVÍNCULOS EN COLOR AZUL
// ==========================================

#let configurar-links() = {
  show link: it => link(it.dest, text(fill: rgb("#2563eb"))[#it.body])
  show cite: it => text(fill: rgb("#2563eb"))[#it]
}
