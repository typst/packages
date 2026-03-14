#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": risk-badge, section-title
#import "../_lib/brand.typ": *

/// Generates the Risk Register document
#let risks(project) = {
  show: body => project-page(
    project: project,
    title: "Registro y Matriz de Riesgos",
    subtitle: "Identificación y Estrategias de Mitigación",
    body,
  )

  section-title("Registro de Riesgos Identificados")

  table(
    columns: (auto, 1fr, auto, auto, 2fr),
    fill: (col, row) => if row == 0 { azul-medio } else if calc.odd(row) { gris-claro } else { white },
    stroke: (x, y) => if y == 0 { (bottom: 0.5pt + rgb("#b0bec5")) } else { 0pt },
    inset: 8pt,

    // Header
    text(fill: white, weight: "bold", size: 9pt, "ID"),
    text(fill: white, weight: "bold", size: 9pt, "Descripción"),
    text(fill: white, weight: "bold", size: 9pt, "Prob."),
    text(fill: white, weight: "bold", size: 9pt, "Imp."),
    text(fill: white, weight: "bold", size: 9pt, "Mitigación"),

    // Rows
    ..project
      .risks
      .map(r => (
        text(weight: "bold", size: 9pt, r.id),
        text(size: 9pt, r.description),
        risk-badge(r.probability, r.impact), // Use unified badge to show Risk Score color
        text(size: 9pt, r.impact),
        text(size: 9pt, r.mitigation),
      ))
      .flatten(),
  )

  v(30pt)
  section-title("Matriz de Probabilidad / Impacto")
  text(
    size: 10pt,
    fill: gris-texto,
    "La clasificación en el registro se basa en la combinación de la probabilidad de ocurrencia y el nivel de impacto.",
  )
}
