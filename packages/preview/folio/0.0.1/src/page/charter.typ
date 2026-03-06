#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": format-currency, info-pair, section-title, signature-block

/// Generates the Project Charter document
#let charter(project) = {
  show: body => project-page(
    project: project,
    title: "Acta de Constitución (Charter)",
    subtitle: "Aprobación y Lanzamiento Formal",
    body,
  )

  section-title("Resumen del Proyecto")
  text(project.description)
  v(12pt)

  section-title("Datos Principales")
  grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    info-pair("Nombre del Proyecto:", project.name), info-pair("Responsable:", project.owner),
    info-pair("Fecha de Inicio:", project.start_date), info-pair("Fecha Asignada de Fin:", project.end_date),
  )
  v(12pt)

  section-title("Objetivos y Beneficios Esperados")
  for ben in project.benefits [
    - #ben
  ]
  v(12pt)

  section-title("Resumen de Inversión")
  let req-total = project.requirements.map(r => r.qty * r.unit_cost).sum()
  let summary-text = (
    "El presupuesto preliminar estimado basado en requerimientos identificados es de "
      + format-currency(req-total)
      + ". Sujeto a variaciones por costos adicionales."
  )
  text(summary-text)
  v(24pt)

  section-title("Aprobación")
  grid(
    columns: (1fr, 1fr),
    gutter: 40pt,
    signature-block(project.owner, role: "Responsable del Proyecto"),
    signature-block(project.client_signature, role: "Cliente / Patrocinador Ejecutivo", date: project.acceptance_date),
  )
}
