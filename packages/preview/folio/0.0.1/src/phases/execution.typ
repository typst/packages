#import "../core/phase-runner.typ": render-phase
#import "../core/pipeline.typ": pmbok-pipeline
#import "../components/execution.typ": (
  change-log, decision-log, deliverables-register, issue-log, risk-matrix,
  status-report,
)

#let execution(pipeline: pmbok-pipeline) = render-phase(
  pipeline,
  "execution",
  "Execution",
)

// Re-export section fns for lib.typ
#let status-report = status-report
#let risk-matrix = risk-matrix
#let issue-log = issue-log
#let change-log = change-log
#let decision-log = decision-log
#let deliverables-register = deliverables-register
