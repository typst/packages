// =========================================================================
// CAS Bridge Layer: Calculus
// =========================================================================
// Stable facade for calculus entry points.
// Consumers should import calculus APIs from this file instead of
// `src/calculus/*` implementation files directly.
// =========================================================================

#import "calculus/diff.typ": diff
#import "calculus/integrate.typ": integrate
#import "calculus/advanced.typ": diff-n, definite-integral, taylor, limit, implicit-diff
