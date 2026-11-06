// =========================================================================
// CAS Truths Compatibility Bridge: Calculus Rules
// =========================================================================
// Backward-compatible bridge for unary calculus rules.
// Canonical function metadata lives in `src/truths/function-registry.typ`.
// This file exposes `calc-rules` for existing calculus consumers.
// =========================================================================

#import "function-registry.typ": fn-calc-rules

/// Public helper `calc-rules`.
#let calc-rules = fn-calc-rules
