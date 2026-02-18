#{
  // Page setup...
  import "../lib.typ": gantt
  set page(height: auto)

  // Load a yaml file containing our gantt chart
  let gantt_yaml = yaml("gantt.yaml")

  // Change, for instance, the colour of the milestones
  let style = (
    milestones: (
      normal: (stroke: (paint: blue), thickness: 0.7pt),
    ),
  )
  gantt_yaml.style = style

  // And render
  gantt(gantt_yaml)
}
