#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": req-table, section-title
#import "../_lib/brand.typ": *
#import "../_lib/utils.typ": format-currency

/// Helper logic for requirements tables
#let category-table(category, items) = {
  let subtotal = items.map(i => i.qty * i.unit_cost).sum()

  block(breakable: false)[
    #text(weight: "bold", size: 11pt, fill: azul-medio, category)
    #v(4pt)
    #req-table(items)
    #v(12pt)
  ]
}

/// Generates the Requirements (BOM) document
#let requirements(project) = {
  show: body => project-page(
    project: project,
    title: "Requerimientos Técnicos y Materiales",
    subtitle: "Lista de Materiales (BOM) y Servicios",
    body,
  )

  let reqs = project.requirements
  let categories = ()
  for r in reqs {
    if r.category not in categories {
      categories.push(r.category)
    }
  }

  section-title("Desglose por Categoría")

  for cat in categories {
    let cat-items = reqs.filter(r => r.category == cat)
    category-table(cat, cat-items)
  }

  if project.tech_requirements != none and project.tech_requirements.len() > 0 {
    v(20pt)
    section-title("Requisitos Técnicos No Costeados")
    for tr in project.tech_requirements [
      - #tr
    ]
  }

  v(1fr)
  text(size: size-small, fill: gris-texto, "* Documento generado para efectos técnicos y de proveeduría.")
}
