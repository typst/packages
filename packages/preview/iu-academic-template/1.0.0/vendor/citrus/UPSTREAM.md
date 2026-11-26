# Vendored Citrus Source

## Upstream Information

- **Project:** [pku-typst/citeproc-typst](https://github.com/pku-typst/citeproc-typst)
- **Library:** Citrus
- **Base version:** `0.2.1` (according to `typst.toml`)
- **License:** MIT (see `LICENSE`)
- **Relevant upstream change:** [PR #10](https://github.com/pku-typst/citeproc-typst/pull/10)
- **Documented parser fix commit:** `2deb30f`

This directory contains a locally modified snapshot of Citrus used by the Typst template.

The original MIT license and copyright notices are preserved.

The snapshot does not include upstream Git metadata. Therefore, the exact revision of the complete vendored source cannot be established from the distributed files alone. The parser fix commit listed above does not identify the revision of the entire snapshot.

## Why Citrus Is Vendored

Citrus is included directly to ensure reproducible citation processing and preserve compatibility fixes not guaranteed by the original `0.2.1` release.

The template imports the vendored library through:

`template/integrations/citrus.typ`

Template-specific citation formatting and bibliography behavior are implemented outside the vendored library.

## Local Modifications

The following Citrus source files contain modifications relative to the original implementation.

### 1. CSL-JSON Parser: Issue and Number

**File:** `src/parsing/csl-json.typ`

The original parser could map the CSL-JSON field `issue` to `number`, potentially overwriting an existing article number.

The parser fix preserves both fields independently:

- `issue` — journal issue number
- `number` — article or document number

This correction is associated with [PR #10](https://github.com/pku-typst/citeproc-typst/pull/10) and commit `2deb30f`.

### 2. Punctuation Handling

**Files:**

- `src/interpreter/stack.typ`
- `src/compiler/emit/codegen.typ`

The punctuation handling originally recognized a preceding period but did not consistently recognize question marks or exclamation marks.

Both implementations were extended to recognize `.`, `?`, and `!` as sentence-ending punctuation.

This prevents duplicate punctuation when a CSL group uses `. ` as its delimiter.

The interpreter behavior has been verified against the rendered bibliography. The optional compiler execution path should be tested separately.

### 3. CSL-JSON Variable Resolution

**File:** `src/data/variables.typ`

Two compatibility fixes were applied:

**Issue and number separation**

For CSL-JSON entries, the CSL variable `issue` is resolved directly from the `issue` field instead of falling back to `number`.

This prevents document numbers from being incorrectly interpreted as journal issue numbers.

The existing mapping for other supported input formats is retained.

**Original publisher**

The CSL variable `original-publisher` is resolved using the following priority:

1. `original-publisher`
2. `publisher-en` as a fallback

This supports original publication information in reprinted works while preserving the existing fallback behavior.

## Updating Citrus

When updating to a newer upstream version:

1. Review upstream changes and determine which local patches are still required.
2. Verify that `issue` and `number` remain independent during both parsing and variable resolution.
3. Verify punctuation handling for `.`, `?`, and `!` in both interpreter and compiler execution paths.
4. Verify that `original-publisher` is correctly resolved from CSL-JSON.
5. Preserve the original MIT license and copyright notices.
6. Review API compatibility with `template/integrations/citrus.typ`.
7. Run the complete citation and bibliography regression tests.
8. Update the version, provenance information, and patch documentation in this file.

Do not remove a local patch solely because a newer upstream release is available. Remove it only after equivalent upstream behavior has been verified.

## Maintenance Policy

Citrus is maintained as an external vendored dependency.

Changes to its source should be limited to necessary compatibility fixes. Template-specific formatting and citation behavior should remain in the template's own modules.

All future modifications to the vendored source must be documented here.

The preferred long-term solution is to use an upstream Citrus release that provides the required behavior without local patches.