#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": budget-summary, section-title
#import "../_lib/brand.typ": *
#import "../_lib/utils.typ": format-currency

/// Generates the Financial Budget document
#let budget(project) = {
  show: body => project-page(
    project: project,
    title: "Presupuesto de Proyecto",
    subtitle: "Desglose Financiero y Costos Adicionales",
    body,
  )

  let reqs = project.requirements
  let req-total = reqs.map(r => r.qty * r.unit_cost).sum()

  let extras = project.at("budget_extras", default: ())
  let extras-total = extras.map(e => e.cost).sum()

  let grand-total = req-total + extras-total

  // Extract categories for char visualization
  let categories = ()
  for r in reqs {
    if r.category not in categories { categories.push(r.category) }
  }

  v(20pt)

  section-title("Distribución de Costos Directos")

  let category-costs = categories.map(cat => {
    let cat-items = reqs.filter(r => r.category == cat)
    let cost = cat-items.map(r => r.qty * r.unit_cost).sum()
    (name: cat, cost: cost)
  })

  // Add extras if they exist
  if extras-total > 0 { category-costs.push((name: "Servicios & Extras", cost: extras-total)) }

  let max-cost = calc.max(..category-costs.map(c => c.cost))

  stack(spacing: 8pt, ..category-costs.map(cat => {
    let bar-length = (cat.cost / max-cost) * 80%
    grid(
      columns: (150pt, 1fr, auto),
      gutter: 10pt,
      align(right + horizon, text(size: size-small, cat.name)),
      box(height: 12pt, width: 100%, {
        rect(height: 100%, width: bar-length, fill: azul-medio.lighten(30%), radius: 2pt)
      }),
      text(size: size-small, weight: "bold", format-currency(cat.cost)),
    )
  }))

  v(20pt)

  if extras.len() > 0 {
    block(breakable: false)[
      section-title("Servicios y Costos Adicionales")
      table(
      columns: (1fr, auto),
      fill: (col, row) => if calc.odd(row) { azul-fondo } else { white },
      stroke: (x, y) => if y == 0 { (bottom: 0.5pt + azul-oscuro.lighten(30%)) } else { 0pt },
      inset: 8pt,
      text(weight: "bold", "Concepto"), text(weight: "bold", align(right, "Monto")),
      ..extras.map(e => (
      e.description, align(right, format-currency(e.cost))
      )).flatten()
      )
    ]
    v(12pt)
  }

  // Summary box
  budget-summary(req-total, extras-total, grand-total)

  v(1fr)
  text(weight: "bold", size: 9pt, fill: gris-oscuro, "Términos y Condiciones Generales")
  v(4pt)
  text(size: size-small, fill: gris-texto)[
    #if "payment_terms" in project {
      for term in project.payment_terms [
        - #term \
      ]
    } else {
      "1. Precios en Moneda Nacional (MXN), no incluyen impuestos."
    }
  ]
}
