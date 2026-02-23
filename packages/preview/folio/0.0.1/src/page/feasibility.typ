#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": section-title

/// Generates the Feasibility Analysis document
#let feasibility(project) = {
  show: body => project-page(
    project: project,
    title: "Análisis de Viabilidad",
    subtitle: "Evaluación Técnica, Económica y Operativa",
    body,
  )

  section-title("Viabilidad Técnica")
  if "feasibility" in project and "technical" in project.feasibility {
    text(project.feasibility.technical)
  } else {
    text(
      "Evaluación sobre la tecnología, herramientas y equipo técnico requerido para llevar a cabo este proyecto con éxito en los plazos estipulados.",
    )
  }

  section-title("Viabilidad Económica")
  if "feasibility" in project and "economic" in project.feasibility {
    text(project.feasibility.economic)
  } else {
    text(
      "Análisis de costo-beneficio y evaluación del retorno de inversión (ROI). Justificación de los costos frente al valor agregado esperado del proyecto.",
    )
  }

  section-title("Viabilidad Operativa")
  if "feasibility" in project and "operative" in project.feasibility {
    text(project.feasibility.operative)
  } else {
    text(
      "Impacto del proyecto en las operaciones actuales. Disposición humana y adaptabilidad organizacional requerida para la adopción y el soporte futuro.",
    )
  }

  section-title("Conclusión General")
  text(weight: "bold", "Dictamen de Viabilidad:")
  text(
    " El proyecto ha sido evaluado como viable para su ejecución, sujeto a los riegos estipulados en la matriz correspondiente.",
  )
}
