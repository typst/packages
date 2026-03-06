#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": section-title, team-card

/// Generates the Project Plan document
#let plan(project) = {
  show: body => project-page(
    project: project,
    title: "Plan de Proyecto",
    subtitle: "Guía de Ejecución y Operación",
    body,
  )

  section-title("Objetivos")
  for obj in project.objectives [
    - #obj
  ]

  section-title("Alcance del Proyecto")
  grid(
    columns: (1fr, 1fr),
    gutter: 20pt,
    [
      *Dentro del Alcance:*
      #for item in project.scope.included [
        - #item
      ]
    ],
    [
      *Fuera del Alcance:*
      #for item in project.scope.excluded [
        - #item
      ]
    ],
  )

  section-title("Criterios de Calidad")
  for criteria in project.quality_criteria [
    - #criteria
  ]

  section-title("Organización y Responsabilidades")
  grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    ..project.team.map(m => team-card(m))
  )

  section-title("Plan de Comunicación")
  table(
    columns: (auto, auto, 1fr, auto),
    inset: 8pt,
    table.header([*Audiencia*], [*Frecuencia*], [*Canal / Formato*], [*Responsable*]),
    ..project
      .communication_plan
      .map(c => (
        c.audience,
        c.frequency,
        c.channel,
        c.owner,
      ))
      .flatten(),
  )

  if project.notes.len() > 0 {
    pagebreak()
    section-title("Notas y Restricciones Técnicas")
    for note in project.notes [
      - #note
    ]
  }
}
