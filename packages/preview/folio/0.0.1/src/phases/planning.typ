#import "../core/phase-runner.typ": render-phase
#import "../core/pipeline.typ": pmbok-pipeline
#import "../components/planning.typ": (
  boundaries, budget, communication, compliance, gantt, milestones, quality,
  requirements, risk-strategy, team,
)

#let planning(pipeline: pmbok-pipeline) = render-phase(
  pipeline,
  "planning",
  "Planning",
)

// Re-export section fns for lib.typ
#let boundaries = boundaries
#let requirements = requirements
#let milestones = milestones
#let budget = budget
#let gantt = gantt
#let quality = quality
#let communication = communication
#let risk-strategy = risk-strategy
#let compliance = compliance
#let team = team
