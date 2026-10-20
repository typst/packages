# Contributing to typcas

This document is the contributor contract for typcas.

It is not a style guide or inspiration piece. It defines non-negotiable engineering rules, review severity, and merge criteria so the CAS stays mathematically trustworthy as it evolves.

## 1) Purpose and Scope

This policy governs contributions to:

- symbolic math behavior (simplify, diff, integrate, solve, matrix/system/poly)
- assumptions/domain/restriction flow
- step/trace generation and rendering
- public API ergonomics and result contract behavior
- truths data (`src/truths/*`) and related registry-driven behavior
- user-facing docs for changed semantics

### Non-goals

This policy does not optimize for:

- style-only bikeshedding with no behavior impact
- large unscoped rewrites without regression evidence
- convenience transforms that weaken correctness guarantees

## 2) Philosophy Charter

The following principles are binding.

- `MUST` = merge blocker unless explicitly approved via exception process.
- `SHOULD` = strong default; violations require rationale in PR notes.

### P1. Mathematical Correctness First (`MUST`)

- Never ship a rewrite/solver path that can produce mathematically incorrect output for the declared field/domain mode.
- If tradeoffs exist: correctness > readability > performance.
- Convenience transformations must carry explicit domain assumptions or restriction metadata.

### P2. Canonical Truth in `src/truths/*` (`MUST`)

- Function semantics belong in `src/truths/function-registry.typ`.
- Identity data belongs in `src/truths/identities.typ`.
- Avoid introducing new hardcoded function-name ladders outside truths unless structurally unavoidable and documented in PR.

### P3. Determinism over Heuristics (`MUST`)

- Simplify/trace output must be stable for the same input + assumptions + detail/depth.
- Rule order and tie-break behavior must be explicit and reproducible.

### P4. Domain/Restriction Explicitness (`MUST`)

- Preserve restriction propagation and conflict visibility for new algebra/calculus behavior.
- Never silently erase known domain hazards.
- Strict-mode behavior must remain predictable (`ok: false` with structured errors where applicable).

### P5. Trace Honesty (`MUST`)

- Step traces must reflect actual transformation logic.
- Rule labels must match the math performed (especially chain rule, u-sub, identity labels).

### P6. UX-First API Evolution (`SHOULD`)

- Prefer task-first `cas.*` ergonomics.
- Add helpers to reduce client boilerplate.
- Maintain translation-layer parity when feasible, without violating correctness.

### P7. Additive Compatibility (`SHOULD`)

- Prefer additive changes over breaking changes.
- If a breaking behavior is necessary, document migration path and rationale.

### P8. Evidence-Driven Changes (`MUST`)

Every non-trivial math change must include:

- at least one positive regression case
- at least one edge/failure guard case
- local compile-gate pass for unified example doc (`examples/test.typ`)

## 3) Repository Architecture Boundaries

Use the existing module boundaries consistently.

- `src/truths/*`: canonical data (function registry, identities, rule tables)
- `src/simplify*`, `src/identity-engine*`: deterministic rewrite/canonicalization logic
- `src/restrictions*`, `src/domain*`, `src/assumptions*`: domain and restriction semantics
- `src/calculus/*`: symbolic calculus engines and method analyzers
- `src/steps/*`: trace model, trace generation, rendering, style
- `src/api/*`: public UX wrappers, result plumbing, context wrappers

### Anti-patterns (do not introduce)

- duplicated feature logic in trace-only heuristics that diverges from core engine behavior
- bypassing truths with ad-hoc hardcoded name checks where registry data exists
- undocumented special-cases that alter math semantics

### Approved structural exceptions

These are allowed name-based paths because they are syntax/symbol structure, not
function behavior policy:

- parser structural forms (`sqrt`, `root`, `frac`, structural `log` grammar)
- foundational constants and integration constant symbol handling (`e`, `pi`, `i`, `C`)

Any removable hardcoded function behavior (for example by-parts hints or sign facts)
`MUST` be migrated into `src/truths/function-registry.typ`.

## 4) Required Invariants

The following invariants must be preserved unless an approved breaking change explicitly replaces them.

- `+ C` remains at tail for indefinite integrals
- `C` policy consistency: bare `C` reserved as integration constant
- simplify behavior remains deterministic; idempotence expectations must not regress
- detail/depth semantics remain consistent across trace endpoints
- result contract includes restriction metadata fields (`restrictions`, `satisfied`, `conflicts`, `residual`, `variable-domains`)

## 5) Change Playbooks

Use the relevant playbook and include required validation evidence.

### A) Add a New Function

Expected files:

- `src/truths/function-registry.typ`
- optionally `src/truths/identities.typ`
- parser/display/eval docs only if syntax/presentation changed

Required validation:

- parse/eval/display examples for the new function
- calculus behavior checks if diff/integ metadata is provided
- domain restriction behavior checks if restrictions are defined

Docs touchpoints:

- `README.md` (if user-facing)
- `docs/COMPLETE_GUIDE.md` API sections

### B) Add a New Identity

Expected files:

- `src/truths/identities.typ`
- optional trace labeling/docs if identity visibility changed

Required validation:

- positive simplify case
- anti-regression case proving no oscillation/incorrect rewrite
- verify identity telemetry/trace label behavior when applicable

Docs touchpoints:

- simplify/identity section in `docs/COMPLETE_GUIDE.md` if behavior is user-visible

### C) Change Parser Syntax

Expected files:

- `src/parse/engine.typ`
- optionally `src/display.typ` for round-trip readability

Required validation:

- positive parse case(s)
- malformed-input case(s)
- no regressions in existing syntax coverage

Docs touchpoints:

- parsing sections in `README.md` and `docs/COMPLETE_GUIDE.md`

### D) Modify Simplify Behavior

Expected files:

- `src/simplify.typ`
- optional `src/identity-engine.typ`, truths identity data

Required validation:

- representative before/after case(s)
- edge/failure guard case(s)
- deterministic output check (same input/assumptions gives same output)

Docs touchpoints:

- simplify behavior notes and examples where output semantics changed

### E) Modify Calculus Behavior

Expected files:

- `src/calculus/diff.typ`, `src/calculus/integrate.typ`, and/or `src/calculus/advanced.typ`
- optionally `src/calculus/integrate-methods.typ` for method selection

Required validation:

- at least one direct correctness case per changed rule
- restriction propagation/strict-mode behavior check
- trace consistency check if step labels/method flow changed

Docs touchpoints:

- calculus sections in `README.md` and `docs/COMPLETE_GUIDE.md`

### F) Modify Trace Rendering/Structure

Expected files:

- `src/steps/model.typ`
- `src/steps/trace.typ`
- `src/steps/render.typ`
- optionally `src/steps/style.typ`

Required validation:

- semantic correctness (trace reflects executed transformation)
- readability checks (branching/depth behavior)
- compile check for `examples/test.typ`

Docs touchpoints:

- step/trace section in `README.md`
- step model/render sections in `docs/COMPLETE_GUIDE.md`

## 6) Definition of Done (Merge Checklist)

A PR is done only when all applicable items are satisfied.

- [ ] Correctness checks added for touched math behavior
- [ ] Edge/failure guard cases added for touched behavior
- [ ] Restriction/assumption behavior validated when relevant
- [ ] Unified compile gate passed (`examples/test.typ`)
- [ ] Docs updated for public semantic/API changes
- [ ] Migration note included for intentional breakage
- [ ] No new ad-hoc function ladder bypassing truths (or rationale documented)

## 7) Review Severity Rubric

Review findings are prioritized as:

- `S0` Correctness violation (blocking)
- `S1` Behavioral regression (blocking)
- `S2` Determinism/trace mismatch (blocking unless exception approved)
- `S3` Docs/consistency debt (non-blocking, must track follow-up)

## 8) Validation Commands

Canonical local gate:

```bash
typst compile examples/test.typ /tmp/typcas-test.pdf --root .
```

Recommended probe gate:

```bash
for probe in examples/probes/*.typ; do
  typst compile "$probe" "/tmp/$(basename "$probe" .typ).pdf" --root .
done
```

Recommended focused checks when touching specific areas:

```bash
# Locate stale hardcoded function ladders / special-cases
rg -n "diff_|integrate|simplify|fn-spec|fn-canonical" src

# Verify no unintended v1 runtime coupling
rg -n "archive/v1|core/legacy.typ" src lib.typ
```

## 9) Decision / Exception Process

Any deliberate violation of a `MUST` requires explicit exception handling in PR description:

1. state the violated principle and why
2. define mitigation and bounded impact
3. link a follow-up issue for restoration/hardening

Without this, `MUST` violations are merge blockers.
