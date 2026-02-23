#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": section-title
#import "../_lib/brand.typ": *

/// Generates the Stakeholders / Influence Map Document
#let stakeholders(project) = {
  show: body => project-page(
    project: project,
    title: "Mapeo de Involucrados (Stakeholders)",
    subtitle: "Registro de Influencia e Interés",
    body,
  )

  section-title("Registro de Involucrados")

  table(
    columns: (auto, 1fr, auto, auto, auto, 1fr),
    fill: (col, row) => if row == 0 { azul-medio } else if calc.odd(row) { gris-claro } else { white },
    stroke: (x, y) => if y == 0 { (bottom: 0.5pt + azul-oscuro) } else { 0pt },
    inset: 8pt,

    // Header
    text(fill: white, weight: "bold", size: 9pt, "Nombre"),
    text(fill: white, weight: "bold", size: 9pt, "Organización"),
    text(fill: white, weight: "bold", size: 9pt, "Poder"),
    text(fill: white, weight: "bold", size: 9pt, "Interés"),
    text(fill: white, weight: "bold", size: 9pt, "Canal D."),
    text(fill: white, weight: "bold", size: 9pt, "Actitud Esperada"),

    // Rows
    ..project
      .stakeholders
      .map(s => (
        text(weight: "bold", size: 9pt, s.name),
        text(size: 9pt, s.organization),
        text(size: 9pt, s.power), // e.g., Alto/Medio/Bajo
        text(size: 9pt, s.interest),
        text(size: 9pt, s.channel),
        text(size: 9pt, s.attitude),
      ))
      .flatten(),
  )
}
