// =========================================================================
// CAS Bridge Layer: Steps
// =========================================================================
// Stable facade for step-trace model, tracing, and rendering APIs.
// Consumers should import step APIs from this file instead of
// `src/steps/*` implementation files directly.
// =========================================================================

#import "steps/model.typ": _s-header, _s-note, _s-define, _s-apply
#import "steps/trace.typ": step-diff, step-integrate, step-simplify, step-solve
#import "steps/render.typ": display-steps
