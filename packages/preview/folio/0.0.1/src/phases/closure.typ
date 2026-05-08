#import "../core/phase-runner.typ": render-phase
#import "../core/pipeline.typ": pmbok-pipeline
#import "../components/closure.typ": (
  acceptance, benefits-review, financial-closure, handover, lessons-learned,
  sign-off,
)

#let closure(pipeline: pmbok-pipeline) = render-phase(
  pipeline,
  "closure",
  "Closure",
)

// Re-export section fns for lib.typ
#let lessons-learned = lessons-learned
#let sign-off = sign-off
#let acceptance = acceptance
#let benefits-review = benefits-review
#let handover = handover
#let financial-closure = financial-closure
