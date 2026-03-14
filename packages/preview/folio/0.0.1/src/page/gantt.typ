#import "../_lib/page.typ": project-page
#import "../_lib/components.typ": gantt-chart

/// Generates the Gantt Schedule document using preview/gantty
#let gantt(project) = {
  // Set custom page properties for Gantt to be wide
  set page(width: 35cm, height: auto, margin: 1cm)

  show: body => project-page(
    project: project,
    title: "Cronograma del Proyecto (Gantt)",
    subtitle: "Fases y Milestones",
    body,
  )

  let render_end = project.at("gantt_render_end", default: project.end_date)

  gantt-chart(
    project.phases,
    project.milestones,
    project.start_date,
    render_end,
  )
}
