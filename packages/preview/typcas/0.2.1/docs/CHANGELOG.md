# Changelog

All notable changes to `typcas` are documented in this file, including archived v1 history.

## [0.2.1]

### Added

1. Probe suite for targeted correctness/performance checks:
   - `probe_nonsmooth_diff.typ`
   - `probe_limits.typ`
   - `probe_simplify_properties.typ`
   - `probe_integrate_methods.typ`
   - migrated `probe_query_flow.typ` / `probe_identity_translation.typ`
2. One-sided finite limit support via additive `to` strings: `"a+"`, `"a-"`.
3. Restriction diagnostics panel (`diagnostics.restriction-panel`) with compact status rows.
4. Non-smooth derivative boundary warnings (`nonsmooth-boundary`) in diff flows.
5. Expanded unified demo/regression coverage in `examples/test.typ` for:
   - non-smooth piecewise derivatives (`abs`, `min`, `clamp`)
   - left/right one-sided limits
   - trig-standard and `x -> inf` rational-degree limit cases

### Changed

1. Non-smooth derivatives are now piecewise-aware for:
   - `abs`, `sign`, `min/max`, `clamp`
   with symbolic boundary fallback for correctness.
2. Limit engine expanded with:
   - one-sided execution
   - `x -> ±inf` rational degree rules
   - guarded trig standard forms (`sin(u)/u`, `tan(u)/u`, `(1-cos(u))/u^2` at `u -> 0`)
3. Restriction UX upgraded in step traces with compact active/satisfied/conflict panel notes.
4. Shared integration method analyzer coverage expanded (including stronger partial-fraction/by-parts paths).
5. Simplifier fixed-point hardening now includes cycle detection and deterministic stop safety.
6. Per-call memoization added in simplify, diff, and trace recursion paths.
7. `docs/COMPLETE_GUIDE.md` expanded with dedicated sections for:
   - non-smooth derivative semantics
   - one-sided/infinity limit behavior
   - restriction panel usage
   - local probe validation workflow

### Fixed

1. Divergence risk between integration engine and step-trace method narration for common method-detection cases.
2. Silent regression risk reduced by formalizing probe compiles in local validation workflow.
3. Documentation/version synchronization to package release `0.2.1`.
4. `examples/test.typ` math rendering artifacts caused by string-concatenated display lines (notably linear/nonlinear system and poly-division "Before" lines).
5. Misc showcase rendering consistency in unified test output (matrix solve vector display text and before/after math composition).

### Notes

1. CI workflow file was removed from the repository; validation is currently local/manual.

## [0.2.0]

### Why a full refactor was needed

The previous architecture had accumulated coupling across parser/eval/display/calculus/steps, which made correctness fixes slow and risky. A full refactor was required to:

1. Make `src/truths/*` the canonical source for function behavior and identities.
2. Remove duplicated hardcoded rule ladders across engines.
3. Unify restriction/domain propagation so simplify/diff/integrate/trace all report consistent metadata.
4. Standardize step tracing and rendering so method narration reflects actual engine decisions.
5. Improve API ergonomics while keeping structured result contracts predictable.
6. Establish contributor invariants (correctness-first, deterministic output, explicit domain semantics).

### Added

1. Task-first `cas.*` surface with structured result helpers and context wrappers.
2. Unified domain/restriction pipeline with variable-domain propagation and assumption filtering.
3. Registry-driven function metadata expansion (analysis + integration hints for internal analyzers).
4. Step style system and branch-aware trace presentation controls.
5. Comprehensive docs:
   - `docs/COMPLETE_GUIDE.md`
   - `CONTRIBUTING.md`
   - `.github/pull_request_template.md`
6. Conservative function bundle expansion:
   - `sign`/`sgn`, `floor`, `ceil`, `round`, `trunc`, `fracpart`, `min`, `max`, `clamp`
7. Conservative identity bundle expansion:
   - `log1p(expm1(u))`, `expm1(log1p(u))` (domain-sensitive)
   - `(cbrt(u))^3`, `(sqrt(u))^2` (domain-sensitive)
   - idempotence for `min/max/clamp`, plus sign/abs normalization identities

### Changed

1. Parser/evaluator/display/calculus paths were refactored to reduce truth bypasses.
2. Integration and tracing now share method-analysis decisions for better narrative fidelity.
3. Bare `C` handling was unified as the integration constant policy.
4. Restriction sign reasoning moved to truth-driven metadata where applicable.
5. Example/testing flow consolidated around `examples/test.typ`.
6. Parser now enforces known-function arity from registry metadata at parse time, including variadic minimum arity (`min/max >= 2`).

### Fixed

1. Multiple step-trace formatting and narration mismatches (chain form, u-sub narration, branch readability).
2. Inconsistent restriction reporting between operations and traces.
3. Several simplification and presentation regressions discovered during unification.

### Migration notes

1. Prefer canonical task-first calls under `cas.*`.
2. Translation helpers remain available under `translators/translation.typ` for v1-style migration.
3. Use `c` or `C_0` if a normal variable name is needed instead of bare `C`.
4. The historical codebase is preserved under `archive/v1` (with its own `archive/v1/typst.toml` and `archive/v1/lib.typ` entrypoint).

## [0.1.0]

### Added

1. Function-first public API exposed from `archive/v1/lib.typ`:
   - `simplify`, `simplify-meta`, `expand`
   - `diff`, `diff-n`, `implicit-diff`
   - `integrate`, `definite-integral`
   - `solve`, `solve-meta`, `factor`
   - `taylor`, `limit`
   - `eval-expr`, `substitute`
2. Assumption and domain utilities:
   - `assume`, `assume-domain`, `assume-string`, `merge-assumptions`, `apply-assumptions`
   - `parse-domain`, `domain-normalize`, `domain-intersect`, `domain-contains`, `domain-status-rel`
3. Restriction metadata pipeline:
   - structural/function restriction collectors
   - filter/classification by assumptions
   - metadata surfaces such as `diff-meta` and `simplify-meta`
4. Step-by-step subsystem:
   - `step-simplify`, `step-diff`, `step-integrate`, `step-solve`
   - `display-steps`
5. Solver and algebra tools:
   - polynomial helpers: `poly-coeffs`, `coeffs-to-expr`, `poly-div`, `poly-gcd`, `partial-fractions`
   - systems: linear and nonlinear system solvers
   - matrix operations: arithmetic, determinant, inverse, solve, eigenvalues/eigenvectors
6. Legacy example/regression suite under `archive/v1/examples`.

### Changed

1. Established a function-style API surface as the primary integration pattern for v1 documents.
2. Standardized v1 workflows around assumptions, restrictions, and step rendering.
3. Consolidated v1 runtime/examples under `archive/v1` as archived historical source.

### Fixed

1. Baseline archived release; no separate patch-level fix log was preserved for v1 in this consolidated changelog.
