#import "../core/phase-runner.typ": render-phase
#import "../core/pipeline.typ": pmbok-pipeline
#import "../components/initiation.typ": (
  assumptions-log, business-case, cover, objectives, pitch, stakeholders,
  success-criteria,
)

#let initiation(pipeline: pmbok-pipeline) = render-phase(
  pipeline,
  "initiation",
  "Initiation",
)

// Re-export section fns for lib.typ
#let pitch = pitch
#let business-case = business-case
#let objectives = objectives
#let success-criteria = success-criteria
#let stakeholders = stakeholders
#let assumptions-log = assumptions-log
#let cover = cover
