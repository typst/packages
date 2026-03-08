// =========================================================================
// CAS Bridge Layer: Identities
// =========================================================================
// Stable facade for identity truth data and rewrite engine entry points.
// Consumers should import identity APIs from this file instead of
// `src/identity-engine.typ` or `src/truths/identities.typ` directly.
// =========================================================================

#import "truths/identities.typ": identity-rules
#import "identity-engine.typ": wild, apply-identities-once
