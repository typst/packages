# typcas Import Dependency Tree

This document inventories the Typst `#import` / `#include` graph for every `.typ` file in this repository.
Non-Typst files are outside the Typst module graph and are intentionally omitted.

## Summary

- `.typ` files scanned: `94`
- Files with direct imports/includes: `84`
- Files with no direct imports/includes: `10`
- `#include` edges found: `0`
- External package targets: `@preview/typcas:0.2.1`

## Root Forest

### Current Graph

```text
examples/probes/probe_identity_translation.typ
|-- lib.typ
|   |-- @preview/typcas:0.2.1 [external]
|   \-- src/api/cas.typ
|       |-- src/api/builder.typ
|       |   |-- src/core/ast.typ
|       |   |   \-- src/expr.typ
|       |   |-- src/core/runtime.typ
|       |   |   |-- src/expr.typ [shared]
|       |   |   |-- src/parse.typ
|       |   |   |   \-- src/parse/engine.typ
|       |   |   |       |-- src/expr.typ [shared]
|       |   |   |       \-- src/truths/function-registry.typ
|       |   |   |           \-- src/expr.typ [shared]
|       |   |   |-- src/display.typ
|       |   |   |   |-- src/expr.typ [shared]
|       |   |   |   \-- src/truths/function-registry.typ [shared]
|       |   |   |-- src/simplify.typ
|       |   |   |   |-- src/expr.typ [shared]
|       |   |   |   |-- src/rational.typ
|       |   |   |   |   \-- src/expr.typ [shared]
|       |   |   |   |-- src/identities.typ
|       |   |   |   |   |-- src/truths/identities.typ
|       |   |   |   |   |   \-- src/expr.typ [shared]
|       |   |   |   |   \-- src/identity-engine.typ
|       |   |   |   |       |-- src/expr.typ [shared]
|       |   |   |   |       |-- src/truths/identities.typ [shared]
|       |   |   |   |       \-- src/truths/function-registry.typ [shared]
|       |   |   |   |-- src/truths/function-registry.typ [shared]
|       |   |   |   \-- src/restrictions.typ
|       |   |   |       |-- src/expr.typ [shared]
|       |   |   |       |-- src/domain.typ
|       |   |   |       |-- src/truths/function-registry.typ [shared]
|       |   |   |       \-- src/display.typ [shared]
|       |   |   |-- src/eval-num.typ
|       |   |   |   |-- src/expr.typ [shared]
|       |   |   |   \-- src/truths/function-registry.typ [shared]
|       |   |   |-- src/calculus.typ
|       |   |   |   |-- src/calculus/diff.typ
|       |   |   |   |   |-- src/expr.typ [shared]
|       |   |   |   |   |-- src/simplify.typ [shared]
|       |   |   |   |   |-- src/core/expr-walk.typ
|       |   |   |   |   |   \-- src/expr.typ [shared]
|       |   |   |   |   \-- src/truths/function-registry.typ [shared]
|       |   |   |   |-- src/calculus/integrate.typ
|       |   |   |   |   |-- src/expr.typ [shared]
|       |   |   |   |   |-- src/simplify.typ [shared]
|       |   |   |   |   \-- src/calculus/integrate-methods.typ
|       |   |   |   |       |-- src/expr.typ [shared]
|       |   |   |   |       |-- src/simplify.typ [shared]
|       |   |   |   |       |-- src/core/expr-walk.typ [shared]
|       |   |   |   |       |-- src/truths/function-registry.typ [shared]
|       |   |   |   |       |-- src/poly.typ
|       |   |   |   |       |   |-- src/expr.typ [shared]
|       |   |   |   |       |   \-- src/simplify.typ [shared]
|       |   |   |   |       \-- src/calculus/diff.typ [shared]
|       |   |   |   \-- src/calculus/advanced.typ
|       |   |   |       |-- src/expr.typ [shared]
|       |   |   |       |-- src/simplify.typ [shared]
|       |   |   |       |-- src/eval-num.typ [shared]
|       |   |   |       |-- src/poly.typ [shared]
|       |   |   |       |-- src/core/expr-walk.typ [shared]
|       |   |   |       |-- src/calculus/diff.typ [shared]
|       |   |   |       \-- src/calculus/integrate.typ [shared]
|       |   |   |-- src/solve.typ
|       |   |   |   \-- src/solve/engine.typ
|       |   |   |       |-- src/expr.typ [shared]
|       |   |   |       |-- src/simplify.typ [shared]
|       |   |   |       |-- src/helpers.typ
|       |   |   |       |   \-- src/core/int-math.typ
|       |   |   |       |-- src/core/int-math.typ [shared]
|       |   |   |       |-- src/core/expr-walk.typ [shared]
|       |   |   |       |-- src/poly.typ [shared]
|       |   |   |       |-- src/rational.typ [shared]
|       |   |   |       \-- src/truths/function-registry.typ [shared]
|       |   |   |-- src/assumptions.typ
|       |   |   |   |-- src/expr.typ [shared]
|       |   |   |   |-- src/truths/function-registry.typ [shared]
|       |   |   |   \-- src/domain.typ [shared]
|       |   |   |-- src/domain.typ [shared]
|       |   |   |-- src/restrictions.typ [shared]
|       |   |   |-- src/steps.typ
|       |   |   |   |-- src/steps/model.typ
|       |   |   |   |   \-- src/expr.typ [shared]
|       |   |   |   |-- src/steps/trace.typ
|       |   |   |   |   |-- src/expr.typ [shared]
|       |   |   |   |   |-- src/simplify.typ [shared]
|       |   |   |   |   |-- src/assumptions.typ [shared]
|       |   |   |   |   |-- src/calculus/diff.typ [shared]
|       |   |   |   |   |-- src/calculus/integrate.typ [shared]
|       |   |   |   |   |-- src/calculus/integrate-methods.typ [shared]
|       |   |   |   |   |-- src/solve/engine.typ [shared]
|       |   |   |   |   |-- src/poly.typ [shared]
|       |   |   |   |   |-- src/truths/function-registry.typ [shared]
|       |   |   |   |   |-- src/core/expr-walk.typ [shared]
|       |   |   |   |   |-- src/restrictions.typ [shared]
|       |   |   |   |   |-- src/steps/detail.typ
|       |   |   |   |   \-- src/steps/model.typ [shared]
|       |   |   |   |-- src/steps/render.typ
|       |   |   |   |   |-- src/expr.typ [shared]
|       |   |   |   |   |-- src/display.typ [shared]
|       |   |   |   |   |-- src/helpers.typ [shared]
|       |   |   |   |   \-- src/steps/style.typ
|       |   |   |   |-- src/steps/style.typ [shared]
|       |   |   |   \-- src/steps/detail.typ [shared]
|       |   |   |-- src/system.typ
|       |   |   |   |-- src/expr.typ [shared]
|       |   |   |   |-- src/simplify.typ [shared]
|       |   |   |   |-- src/eval-num.typ [shared]
|       |   |   |   \-- src/calculus.typ [shared]
|       |   |   |-- src/poly.typ [shared]
|       |   |   |-- src/matrix.typ
|       |   |   |   |-- src/expr.typ [shared]
|       |   |   |   \-- src/simplify.typ [shared]
|       |   |   |-- src/truths/function-registry.typ [shared]
|       |   |   |-- src/truths/identities.typ [shared]
|       |   |   \-- src/identities.typ [shared]
|       |   \-- src/api/result.typ
|       |-- src/core/ast.typ [shared]
|       |-- src/display/index.typ
|       |   \-- src/core/runtime.typ [shared]
|       |-- src/parse/index.typ
|       |   \-- src/core/runtime.typ [shared]
|       \-- src/core/runtime.typ [shared]
\-- translators/translation.typ
    |-- lib.typ [shared]
    \-- src/core/runtime.typ [shared]

examples/test.typ
|-- lib.typ [shared]
\-- translators/translation.typ [shared]

examples/probes/probe_integrate_methods.typ
\-- lib.typ [shared]

examples/probes/probe_limits.typ
\-- lib.typ [shared]

examples/probes/probe_nonsmooth_diff.typ
\-- lib.typ [shared]

examples/probes/probe_query_flow.typ
\-- lib.typ [shared]

examples/probes/probe_simplify_properties.typ
\-- lib.typ [shared]

test-new.typ
\-- lib.typ [shared]

src/domain/index.typ
\-- src/core/runtime.typ [shared]

src/matrix/index.typ
\-- src/core/runtime.typ [shared]

src/restrictions/index.typ
\-- src/core/runtime.typ [shared]

src/simplify/index.typ
\-- src/core/runtime.typ [shared]

src/solve/index.typ
\-- src/core/runtime.typ [shared]

src/steps/index.typ
\-- src/core/runtime.typ [shared]

src/calculus/index.typ
\-- src/calculus.typ [shared]

src/core/number.typ
\-- src/core/ast.typ [shared]
```

### Archive v1 Graph

```text
archive/v1/examples/cas_test_suite.typ
\-- archive/v1/lib.typ
    |-- archive/v1/src/expr.typ
    |-- archive/v1/src/parse.typ
    |   \-- archive/v1/src/parse/engine.typ
    |       |-- archive/v1/src/expr.typ [shared]
    |       \-- archive/v1/src/truths/function-registry.typ
    |           \-- archive/v1/src/expr.typ [shared]
    |-- archive/v1/src/display.typ
    |   |-- archive/v1/src/expr.typ [shared]
    |   \-- archive/v1/src/truths/function-registry.typ [shared]
    |-- archive/v1/src/simplify.typ
    |   |-- archive/v1/src/expr.typ [shared]
    |   |-- archive/v1/src/rational.typ
    |   |   \-- archive/v1/src/expr.typ [shared]
    |   |-- archive/v1/src/identities.typ
    |   |   |-- archive/v1/src/truths/identities.typ
    |   |   |   \-- archive/v1/src/expr.typ [shared]
    |   |   \-- archive/v1/src/identity-engine.typ
    |   |       |-- archive/v1/src/expr.typ [shared]
    |   |       |-- archive/v1/src/truths/identities.typ [shared]
    |   |       \-- archive/v1/src/truths/function-registry.typ [shared]
    |   |-- archive/v1/src/truths/function-registry.typ [shared]
    |   \-- archive/v1/src/restrictions.typ
    |       |-- archive/v1/src/expr.typ [shared]
    |       |-- archive/v1/src/display.typ [shared]
    |       |-- archive/v1/src/truths/function-registry.typ [shared]
    |       \-- archive/v1/src/domain.typ
    |-- archive/v1/src/eval-num.typ
    |   |-- archive/v1/src/expr.typ [shared]
    |   \-- archive/v1/src/truths/function-registry.typ [shared]
    |-- archive/v1/src/calculus.typ
    |   |-- archive/v1/src/calculus/diff.typ
    |   |   |-- archive/v1/src/expr.typ [shared]
    |   |   |-- archive/v1/src/simplify.typ [shared]
    |   |   |-- archive/v1/src/truths/calculus-rules.typ
    |   |   |   \-- archive/v1/src/truths/function-registry.typ [shared]
    |   |   |-- archive/v1/src/helpers.typ
    |   |   |   \-- archive/v1/src/core/int-math.typ
    |   |   \-- archive/v1/src/core/expr-walk.typ
    |   |       \-- archive/v1/src/expr.typ [shared]
    |   |-- archive/v1/src/calculus/integrate.typ
    |   |   |-- archive/v1/src/expr.typ [shared]
    |   |   |-- archive/v1/src/simplify.typ [shared]
    |   |   |-- archive/v1/src/poly.typ
    |   |   |   |-- archive/v1/src/expr.typ [shared]
    |   |   |   \-- archive/v1/src/simplify.typ [shared]
    |   |   |-- archive/v1/src/helpers.typ [shared]
    |   |   |-- archive/v1/src/truths/calculus-rules.typ [shared]
    |   |   |-- archive/v1/src/truths/function-registry.typ [shared]
    |   |   |-- archive/v1/src/core/expr-walk.typ [shared]
    |   |   \-- archive/v1/src/calculus/diff.typ [shared]
    |   \-- archive/v1/src/calculus/advanced.typ
    |       |-- archive/v1/src/expr.typ [shared]
    |       |-- archive/v1/src/simplify.typ [shared]
    |       |-- archive/v1/src/eval-num.typ [shared]
    |       |-- archive/v1/src/helpers.typ [shared]
    |       |-- archive/v1/src/calculus/diff.typ [shared]
    |       \-- archive/v1/src/calculus/integrate.typ [shared]
    |-- archive/v1/src/solve.typ
    |   \-- archive/v1/src/solve/engine.typ
    |       |-- archive/v1/src/expr.typ [shared]
    |       |-- archive/v1/src/simplify.typ [shared]
    |       |-- archive/v1/src/helpers.typ [shared]
    |       |-- archive/v1/src/core/int-math.typ [shared]
    |       |-- archive/v1/src/core/expr-walk.typ [shared]
    |       |-- archive/v1/src/poly.typ [shared]
    |       \-- archive/v1/src/rational.typ [shared]
    |-- archive/v1/src/assumptions.typ
    |   |-- archive/v1/src/expr.typ [shared]
    |   |-- archive/v1/src/truths/function-registry.typ [shared]
    |   \-- archive/v1/src/domain.typ [shared]
    |-- archive/v1/src/domain.typ [shared]
    |-- archive/v1/src/restrictions.typ [shared]
    |-- archive/v1/src/steps.typ
    |   |-- archive/v1/src/steps/model.typ
    |   |-- archive/v1/src/steps/trace.typ
    |   |   |-- archive/v1/src/expr.typ [shared]
    |   |   |-- archive/v1/src/simplify.typ [shared]
    |   |   |-- archive/v1/src/calculus.typ [shared]
    |   |   |-- archive/v1/src/display.typ [shared]
    |   |   |-- archive/v1/src/solve.typ [shared]
    |   |   |-- archive/v1/src/restrictions.typ [shared]
    |   |   |-- archive/v1/src/truths/calculus-rules.typ [shared]
    |   |   |-- archive/v1/src/truths/function-registry.typ [shared]
    |   |   |-- archive/v1/src/helpers.typ [shared]
    |   |   |-- archive/v1/src/core/int-math.typ [shared]
    |   |   |-- archive/v1/src/core/expr-walk.typ [shared]
    |   |   |-- archive/v1/src/poly.typ [shared]
    |   |   |-- archive/v1/src/steps/model.typ [shared]
    |   |   \-- archive/v1/src/steps/render.typ
    |   |       |-- archive/v1/src/expr.typ [shared]
    |   |       |-- archive/v1/src/display.typ [shared]
    |   |       \-- archive/v1/src/helpers.typ [shared]
    |   \-- archive/v1/src/steps/render.typ [shared]
    |-- archive/v1/src/matrix.typ
    |   |-- archive/v1/src/expr.typ [shared]
    |   \-- archive/v1/src/simplify.typ [shared]
    |-- archive/v1/src/system.typ
    |   |-- archive/v1/src/expr.typ [shared]
    |   |-- archive/v1/src/simplify.typ [shared]
    |   |-- archive/v1/src/eval-num.typ [shared]
    |   \-- archive/v1/src/calculus.typ [shared]
    \-- archive/v1/src/poly.typ [shared]

archive/v1/examples/regression_check.typ
\-- archive/v1/lib.typ [shared]

archive/v1/examples/test.typ
\-- archive/v1/lib.typ [shared]

archive/v1/examples/test_new.typ
\-- archive/v1/lib.typ [shared]
```

## Direct Dependency Index

| File | Direct imports/includes |
| --- | --- |
| `archive/v1/examples/cas_test_suite.typ` | `archive/v1/lib.typ` |
| `archive/v1/examples/regression_check.typ` | `archive/v1/lib.typ` |
| `archive/v1/examples/test.typ` | `archive/v1/lib.typ` |
| `archive/v1/examples/test_new.typ` | `archive/v1/lib.typ` |
| `archive/v1/lib.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/parse.typ`<br>`archive/v1/src/display.typ`<br>`archive/v1/src/simplify.typ`<br>`archive/v1/src/eval-num.typ`<br>`archive/v1/src/calculus.typ`<br>`archive/v1/src/solve.typ`<br>`archive/v1/src/assumptions.typ`<br>`archive/v1/src/domain.typ`<br>`archive/v1/src/restrictions.typ`<br>`archive/v1/src/steps.typ`<br>`archive/v1/src/matrix.typ`<br>`archive/v1/src/system.typ`<br>`archive/v1/src/poly.typ` |
| `archive/v1/src/assumptions.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/truths/function-registry.typ`<br>`archive/v1/src/domain.typ` |
| `archive/v1/src/calculus.typ` | `archive/v1/src/calculus/diff.typ`<br>`archive/v1/src/calculus/integrate.typ`<br>`archive/v1/src/calculus/advanced.typ` |
| `archive/v1/src/calculus/advanced.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/simplify.typ`<br>`archive/v1/src/eval-num.typ`<br>`archive/v1/src/helpers.typ`<br>`archive/v1/src/calculus/diff.typ`<br>`archive/v1/src/calculus/integrate.typ` |
| `archive/v1/src/calculus/diff.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/simplify.typ`<br>`archive/v1/src/truths/calculus-rules.typ`<br>`archive/v1/src/helpers.typ`<br>`archive/v1/src/core/expr-walk.typ` |
| `archive/v1/src/calculus/integrate.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/simplify.typ`<br>`archive/v1/src/poly.typ`<br>`archive/v1/src/helpers.typ`<br>`archive/v1/src/truths/calculus-rules.typ`<br>`archive/v1/src/truths/function-registry.typ`<br>`archive/v1/src/core/expr-walk.typ`<br>`archive/v1/src/calculus/diff.typ` |
| `archive/v1/src/core/expr-walk.typ` | `archive/v1/src/expr.typ` |
| `archive/v1/src/core/int-math.typ` | `-` |
| `archive/v1/src/display.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/truths/function-registry.typ` |
| `archive/v1/src/domain.typ` | `-` |
| `archive/v1/src/eval-num.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/truths/function-registry.typ` |
| `archive/v1/src/expr.typ` | `-` |
| `archive/v1/src/helpers.typ` | `archive/v1/src/core/int-math.typ` |
| `archive/v1/src/identities.typ` | `archive/v1/src/truths/identities.typ`<br>`archive/v1/src/identity-engine.typ` |
| `archive/v1/src/identity-engine.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/truths/identities.typ`<br>`archive/v1/src/truths/function-registry.typ` |
| `archive/v1/src/matrix.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/simplify.typ` |
| `archive/v1/src/parse.typ` | `archive/v1/src/parse/engine.typ` |
| `archive/v1/src/parse/engine.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/truths/function-registry.typ` |
| `archive/v1/src/poly.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/simplify.typ` |
| `archive/v1/src/rational.typ` | `archive/v1/src/expr.typ` |
| `archive/v1/src/restrictions.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/display.typ`<br>`archive/v1/src/truths/function-registry.typ`<br>`archive/v1/src/domain.typ` |
| `archive/v1/src/simplify.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/rational.typ`<br>`archive/v1/src/identities.typ`<br>`archive/v1/src/truths/function-registry.typ`<br>`archive/v1/src/restrictions.typ` |
| `archive/v1/src/solve.typ` | `archive/v1/src/solve/engine.typ` |
| `archive/v1/src/solve/engine.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/simplify.typ`<br>`archive/v1/src/helpers.typ`<br>`archive/v1/src/core/int-math.typ`<br>`archive/v1/src/core/expr-walk.typ`<br>`archive/v1/src/poly.typ`<br>`archive/v1/src/rational.typ` |
| `archive/v1/src/steps.typ` | `archive/v1/src/steps/model.typ`<br>`archive/v1/src/steps/trace.typ`<br>`archive/v1/src/steps/render.typ` |
| `archive/v1/src/steps/model.typ` | `-` |
| `archive/v1/src/steps/render.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/display.typ`<br>`archive/v1/src/helpers.typ` |
| `archive/v1/src/steps/trace.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/simplify.typ`<br>`archive/v1/src/calculus.typ`<br>`archive/v1/src/display.typ`<br>`archive/v1/src/solve.typ`<br>`archive/v1/src/restrictions.typ`<br>`archive/v1/src/truths/calculus-rules.typ`<br>`archive/v1/src/truths/function-registry.typ`<br>`archive/v1/src/helpers.typ`<br>`archive/v1/src/core/int-math.typ`<br>`archive/v1/src/core/expr-walk.typ`<br>`archive/v1/src/poly.typ`<br>`archive/v1/src/steps/model.typ`<br>`archive/v1/src/steps/render.typ` |
| `archive/v1/src/system.typ` | `archive/v1/src/expr.typ`<br>`archive/v1/src/simplify.typ`<br>`archive/v1/src/eval-num.typ`<br>`archive/v1/src/calculus.typ` |
| `archive/v1/src/truths/calculus-rules.typ` | `archive/v1/src/truths/function-registry.typ` |
| `archive/v1/src/truths/function-registry.typ` | `archive/v1/src/expr.typ` |
| `archive/v1/src/truths/identities.typ` | `archive/v1/src/expr.typ` |
| `examples/probes/probe_identity_translation.typ` | `lib.typ`<br>`translators/translation.typ` |
| `examples/probes/probe_integrate_methods.typ` | `lib.typ` |
| `examples/probes/probe_limits.typ` | `lib.typ` |
| `examples/probes/probe_nonsmooth_diff.typ` | `lib.typ` |
| `examples/probes/probe_query_flow.typ` | `lib.typ` |
| `examples/probes/probe_simplify_properties.typ` | `lib.typ` |
| `examples/test.typ` | `lib.typ`<br>`translators/translation.typ` |
| `lib.typ` | `@preview/typcas:0.2.1`<br>`src/api/cas.typ` |
| `src/api/builder.typ` | `src/core/ast.typ`<br>`src/core/runtime.typ`<br>`src/api/result.typ` |
| `src/api/cas.typ` | `src/api/builder.typ`<br>`src/core/ast.typ`<br>`src/display/index.typ`<br>`src/parse/index.typ`<br>`src/core/runtime.typ` |
| `src/api/result.typ` | `-` |
| `src/assumptions.typ` | `src/expr.typ`<br>`src/truths/function-registry.typ`<br>`src/domain.typ` |
| `src/calculus.typ` | `src/calculus/diff.typ`<br>`src/calculus/integrate.typ`<br>`src/calculus/advanced.typ` |
| `src/calculus/advanced.typ` | `src/expr.typ`<br>`src/simplify.typ`<br>`src/eval-num.typ`<br>`src/poly.typ`<br>`src/core/expr-walk.typ`<br>`src/calculus/diff.typ`<br>`src/calculus/integrate.typ` |
| `src/calculus/diff.typ` | `src/expr.typ`<br>`src/simplify.typ`<br>`src/core/expr-walk.typ`<br>`src/truths/function-registry.typ` |
| `src/calculus/index.typ` | `src/calculus.typ` |
| `src/calculus/integrate-methods.typ` | `src/expr.typ`<br>`src/simplify.typ`<br>`src/core/expr-walk.typ`<br>`src/truths/function-registry.typ`<br>`src/poly.typ`<br>`src/calculus/diff.typ` |
| `src/calculus/integrate.typ` | `src/expr.typ`<br>`src/simplify.typ`<br>`src/calculus/integrate-methods.typ` |
| `src/core/ast.typ` | `src/expr.typ` |
| `src/core/expr-walk.typ` | `src/expr.typ` |
| `src/core/int-math.typ` | `-` |
| `src/core/number.typ` | `src/core/ast.typ` |
| `src/core/runtime.typ` | `src/expr.typ`<br>`src/parse.typ`<br>`src/display.typ`<br>`src/simplify.typ`<br>`src/eval-num.typ`<br>`src/calculus.typ`<br>`src/solve.typ`<br>`src/assumptions.typ`<br>`src/domain.typ`<br>`src/restrictions.typ`<br>`src/steps.typ`<br>`src/system.typ`<br>`src/poly.typ`<br>`src/matrix.typ`<br>`src/truths/function-registry.typ`<br>`src/truths/identities.typ`<br>`src/identities.typ` |
| `src/display.typ` | `src/expr.typ`<br>`src/truths/function-registry.typ` |
| `src/display/index.typ` | `src/core/runtime.typ` |
| `src/domain.typ` | `-` |
| `src/domain/index.typ` | `src/core/runtime.typ` |
| `src/eval-num.typ` | `src/expr.typ`<br>`src/truths/function-registry.typ` |
| `src/expr.typ` | `-` |
| `src/helpers.typ` | `src/core/int-math.typ` |
| `src/identities.typ` | `src/truths/identities.typ`<br>`src/identity-engine.typ` |
| `src/identity-engine.typ` | `src/expr.typ`<br>`src/truths/identities.typ`<br>`src/truths/function-registry.typ` |
| `src/matrix.typ` | `src/expr.typ`<br>`src/simplify.typ` |
| `src/matrix/index.typ` | `src/core/runtime.typ` |
| `src/parse.typ` | `src/parse/engine.typ` |
| `src/parse/engine.typ` | `src/expr.typ`<br>`src/truths/function-registry.typ` |
| `src/parse/index.typ` | `src/core/runtime.typ` |
| `src/poly.typ` | `src/expr.typ`<br>`src/simplify.typ` |
| `src/rational.typ` | `src/expr.typ` |
| `src/restrictions.typ` | `src/expr.typ`<br>`src/domain.typ`<br>`src/truths/function-registry.typ`<br>`src/display.typ` |
| `src/restrictions/index.typ` | `src/core/runtime.typ` |
| `src/simplify.typ` | `src/expr.typ`<br>`src/rational.typ`<br>`src/identities.typ`<br>`src/truths/function-registry.typ`<br>`src/restrictions.typ` |
| `src/simplify/index.typ` | `src/core/runtime.typ` |
| `src/solve.typ` | `src/solve/engine.typ` |
| `src/solve/engine.typ` | `src/expr.typ`<br>`src/simplify.typ`<br>`src/helpers.typ`<br>`src/core/int-math.typ`<br>`src/core/expr-walk.typ`<br>`src/poly.typ`<br>`src/rational.typ`<br>`src/truths/function-registry.typ` |
| `src/solve/index.typ` | `src/core/runtime.typ` |
| `src/steps.typ` | `src/steps/model.typ`<br>`src/steps/trace.typ`<br>`src/steps/render.typ`<br>`src/steps/style.typ`<br>`src/steps/detail.typ` |
| `src/steps/detail.typ` | `-` |
| `src/steps/index.typ` | `src/core/runtime.typ` |
| `src/steps/model.typ` | `src/expr.typ` |
| `src/steps/render.typ` | `src/expr.typ`<br>`src/display.typ`<br>`src/helpers.typ`<br>`src/steps/style.typ` |
| `src/steps/style.typ` | `-` |
| `src/steps/trace.typ` | `src/expr.typ`<br>`src/simplify.typ`<br>`src/assumptions.typ`<br>`src/calculus/diff.typ`<br>`src/calculus/integrate.typ`<br>`src/calculus/integrate-methods.typ`<br>`src/solve/engine.typ`<br>`src/poly.typ`<br>`src/truths/function-registry.typ`<br>`src/core/expr-walk.typ`<br>`src/restrictions.typ`<br>`src/steps/detail.typ`<br>`src/steps/model.typ` |
| `src/system.typ` | `src/expr.typ`<br>`src/simplify.typ`<br>`src/eval-num.typ`<br>`src/calculus.typ` |
| `src/truths/function-registry.typ` | `src/expr.typ` |
| `src/truths/identities.typ` | `src/expr.typ` |
| `test-new.typ` | `lib.typ` |
| `translators/translation.typ` | `lib.typ`<br>`src/core/runtime.typ` |

## Leaf Files

- `archive/v1/src/core/int-math.typ`
- `archive/v1/src/domain.typ`
- `archive/v1/src/expr.typ`
- `archive/v1/src/steps/model.typ`
- `src/api/result.typ`
- `src/core/int-math.typ`
- `src/domain.typ`
- `src/expr.typ`
- `src/steps/detail.typ`
- `src/steps/style.typ`
