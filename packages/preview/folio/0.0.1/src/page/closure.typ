#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": section-title, signature-block

/// Generates the Formal Closure Document
#let closure(project) = {
  show: body => project-page(
    project: project,
    title: "Documento de Cierre",
    subtitle: "Aceptación Final y Conclusión",
    body,
  )

  section-title("Declaración de Cierre")
  text(
    "Por medio del presente documento, se hace constar que el proyecto '"
      + project.name
      + "' ha concluido sus fases operativas y entregables según lo estipulado en la planeación y alcance original, así como en las desviaciones debidamente autorizadas.",
  )
  v(12pt)

  section-title("Entregables Completados")
  if "completed_deliverables" in project {
    for del in project.completed_deliverables [
      - #del
    ]
  } else {
    text(style: "italic", "Todos los requerimientos listados en el plan original han sido entregados y aceptados.")
  }
  v(12pt)

  section-title("Lecciones Aprendidas")
  if "lessons_learned" in project {
    for lesson in project.lessons_learned [
      - #lesson
    ]
  } else {
    text(style: "italic", "No hay lecciones aprendidas documentadas explícitamente.")
  }
  v(12pt)

  section-title("Desviaciones o Notas de Cierre")
  if "closure_notes" in project {
    for note in project.closure_notes [
      - #note
    ]
  } else {
    text(style: "italic", "El proyecto se cerró conforme al plan sin desviaciones mayores.")
  }
  v(24pt)

  section-title("Aceptación Definitiva")
  grid(
    columns: (1fr, 1fr),
    gutter: 40pt,
    signature-block(project.owner, role: "Responsable / Gerente de Proyecto"),
    signature-block(project.client_signature, role: "Cliente / Receptor Conforme", date: project.acceptance_date),
  )
}
