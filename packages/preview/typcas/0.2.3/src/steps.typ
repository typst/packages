// =========================================================================
// CAS Bridge Layer: Steps
// =========================================================================
// Stable facade for step-trace model, tracing, and rendering APIs.
// Consumers should import step APIs from this file instead of
// `src/steps/*` implementation files directly.
// =========================================================================

#import "steps/model.typ": _s-header, _s-equation, _s-note, _s-define, _s-group, _s-apply
#import "steps/trace.typ": step-diff, step-integrate, step-simplify, step-solve
#import "steps/render.typ": display-steps
#import "steps/style.typ": default-step-style, set-step-style, get-step-style
#import "steps/detail.typ": detail-valid, normalize-detail, detail-mode, detail-depth, resolve-detail-depth
