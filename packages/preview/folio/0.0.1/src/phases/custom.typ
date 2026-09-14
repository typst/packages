#import "../core/phase-runner.typ": render-phase
#import "../core/pipeline.typ": pmbok-pipeline

#let custom(pipeline: pmbok-pipeline) = render-phase(
  pipeline,
  "custom",
  "Custom Sections",
)
