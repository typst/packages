#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": info-pair, section-title
#import "../_lib/utils.typ": format-currency

/// Generates the Executive Brief (One-Pager)
#let executive-brief(project) = {
  show: body => project-page(
    project: project,
    title: "Resumen Ejecutivo",
    subtitle: "Síntesis Administrativa",
    body,
  )

  section-title("Descripción General")
  text(project.description)
  v(12pt)

  grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    info-pair("Responsable:", project.owner), info-pair("Periodo:", project.start_date + " al " + project.end_date),
  )
  v(12pt)

  section-title("Valor Financiero")
  let reqs = project.requirements
  let req-total = reqs.map(r => r.qty * r.unit_cost).sum()
  let extras = project.at("budget_extras", default: ())
  let extras-total = extras.map(e => e.cost).sum()
  let grand-total = req-total + extras-total

  info-pair("Inversión Total Estimada:", format-currency(grand-total))
  v(12pt)

  section-title("Métricas de Éxito / Beneficios")
  for ben in project.benefits [
    - #ben
  ]
  v(12pt)

  section-title("Hitos Clave (Milestones)")
  for m in project.milestones [
    - *#m.name:* #m.date
  ]
}
