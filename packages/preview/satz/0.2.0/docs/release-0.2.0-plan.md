# Satz 0.2.0 release plan

Status: release candidate prepared from the 22 October 2026 interface audit.
The manifest identifies version 0.2.0; it is not published. This plan does not
authorize a Typst Universe submission or public CLI executable release.

## Product decision

Prepare a coherent document API and accurate reference before building the
multi-template CLI. A beginner starts with one editable Typst file. Splitting
configuration, cover and chapters into files remains optional. The CLI will
create those same documented starters, rather than maintain another set.

## 1. Establish the release candidate

Status: the report, outline, list, and palette work is reconciled into the
changelog and roadmap, with migration notes. The configuration reference and
validation gates are complete; the manifest now identifies the 0.2.0 candidate.

- Review and either finish or deliberately defer the existing uncommitted
  report, outline, list and palette changes. Preserve unrelated document work.
- Reconcile the changelog and roadmap with the implemented journal, proposal,
  heading, theme and documentation work. Mark experimental APIs explicitly.
- Keep the current supported scope explicit: DFG 53.01 (09/26), represented
  NWO 2026 profiles, and experimental book support do not mean every form or
  arbitrary LaTeX parity is supported.
- Record intentional visual-default changes and provide migration examples.

Acceptance: a clean, identified candidate commit with a truthful changelog.

## 2. English interfaces and migration

`letter`, `invoice`, `complaint`, and `guest-contract` are the English entry
points. In 0.2.0, `letter` uses English argument and address-field names; the
old public `brief` name and German letter arguments are removed. This is a
breaking change from 0.1.1 and must be highlighted in migration notes. German
letter output remains available through `language: "de"`.

`rechnung`, `klageschrift`, and `gastspielvertrag` and their German arguments
remain supported; English input aliases normalize to their existing renderers.
Invoice, complaint, and guest-contract output remain German. The focused checks
compile the supported English and German interfaces and reject invalid values.

## 3. Resolve appearance consistently

Status: implemented in the 0.2.0 development source; focused precedence tests
pass in `examples/latex-parity/check_appearance_precedence.py`.

Separate document content (sender, recipient, title, date, invoice items) from
appearance (`config`, theme, page geometry, typography). Keep specialized DIN
letter geometry and grant-form requirements; they need not use identical layout
implementations to offer a coherent interface.

Adopt and document one precedence policy for appearance:

1. Shared defaults.
2. Template-specific defaults.
3. Selected theme or preset.
4. Explicit direct appearance arguments retained for convenience/compatibility.
5. Explicit nested `config` overrides.

Merge nested dictionaries deeply; replace arrays and scalar values. Resolve
appearance once and make rendering read the resolved values. Fix the observed
book case where raw `accent`/`math-font` arguments can bypass merged config.
Reuse `theme-config` for the shared palette selection; avoid another palette
copy or a second merge implementation.

For letter/invoice, introduce common appearance options through an adapter;
do not force their postal layout into the report renderer. Clearly state which
shared settings each template supports and reject unsupported new options.

Acceptance: minimal overrides retain unrelated defaults, explicit overrides win
consistently, and themes apply predictably across representative templates.

## 4. Configuration reference with actual value contracts

Status: complete for the exported API and shared configuration surface.
`docs/configuration-reference.md` lists shared defaults, template-specific
appearance differences, exported entry points, defaults, enums, record/array
shapes, validation boundaries, and extension behavior. Candidate and published
version checks compile examples against the versions they declare.

The release reference gives the Satz-specific contracts for each public entry
point. Native Typst arguments forwarded by a helper retain Typst semantics; the
reference links the relevant Typst contract where appropriate. The reference
includes:

- Full key path or function argument.
- Type, including unions such as `none | alignment`.
- Default, with template-specific differences.
- Exhaustive keywords for enums, or representative examples plus a link to the
  native Typst contract for open-ended values.
- Required/optional status; accepted nested record keys and array element shapes.
- Meaning, units, constraints and template scope.
- Effect of `auto`, `none`, omission, and explicit overrides where applicable.
- One compiling example and version availability.

Examples of the level of detail needed for the development API:

| Setting | Type / values | Current default | Meaning |
| --- | --- | --- | --- |
| `typography.size` | Typst length, e.g. `11pt`, `12pt` | `11pt` shared; article overrides | Body text size |
| `typography.leading` | Typst length, e.g. `0.65em`, `8pt` | `0.65em` shared | Space between line bounds, not a LaTeX multiplier |
| `headings.spacing` | `"koma"` or `"native"` | `"koma"` shared | Heading spacing policy |
| `headings.h1-above` | `auto` or Typst length | `auto` shared | Policy-derived gap or explicit override |
| `toc.depth` | `none` or non-negative integer | `none` shared; article overrides to `0` | `0` disables contents; other behavior is template-specific |
| `theme` | `none` or one of six named palettes | Template-specific | Palette selection; availability differs by entry point |

These rows describe development behavior, not a claim that all options exist
in the published 0.1.1 release. Theme names are `neutral`, `slate`, `soft-jade`,
`soft-slate`, `warm-editorial`, `plum`, and `soft-rose`.

Provide a short, annotated starter config containing only useful overrides, plus
a complete versioned default-config reference. Do not teach users to copy or
merge the complete defaults into their overrides: that freezes inherited values
and can mask future improvements.

Keep executable defaults authoritative. Generate reference tables/default
examples from defaults plus explicit documentation metadata where useful;
default values alone cannot describe enum choices, semantics or constraints.
Validate documentation metadata against the supported fields to detect drift.
A large runtime schema framework is not a prerequisite.

Acceptance met: every stable exported entry point has a documented Satz input
contract, and versioned examples compile against the candidate or published
package version they name.

## 5. Helpful validation, proportionate to compatibility

Status: complete for Satz-owned enums, configuration groups, and high-impact
public record/array inputs. Regression coverage now includes journal dates,
authors/affiliations, postal records, invoice items/options, proposal budgets
and Gantt rows, DFG options, NWO profiles/components, legal exhibits, guest
contracts, cover choices, and shared heading policies.

Validate high-impact values and record shapes at public entry points: palette
names, heading policy, cover layout, proposal language, author/affiliation
records, addresses, and supported journal date formats. Errors should name the
field and explain accepted values.

The generic deep-merge helper remains open-ended. `document-class` now validates keys
in known shared configuration groups, including typo detection, while preserving
unknown top-level groups and documented template-specific extensions. Postal
appearance groups remain closed. Typst-native values retain Typst validation;
Satz-owned choices and records fail early with field-specific diagnostics.

Acceptance met: common malformed Satz inputs produce actionable diagnostics,
while the existing DFG/NWO, book, proposal, postal, journal and extension
configurations compile in the regression suite.

## 6. Verify the exact package that will ship

Status: `typst.toml` identifies version 0.2.0 and excludes `tools/**` and local
workbook conversions; `examples/latex-parity/check_staged_package.py` stages the current manifest
tree and compiles eight representative starters. GitHub Actions runs that
check plus focused API/PDF regressions with pinned inspection dependencies.
The regression workflow includes shared outlines, tables, callouts,
placeholders, paragraph rhythm, article layout, and proposal forms. The latest
local run passes the staged-package check and all focused API/PDF regressions.
An isolated download of published 0.1.1 compiled the stable letter,
invoice, report, journal, and cover starters again on 5 November 2026. The staged source tree is also
installed under an isolated `0.2.0` package name and compiled. Direct package
imports are version-pinned; the manifest declares compiler minimum 0.15.0, the
version used for local and CI checks. The tracked examples use placeholders,
and the MIT manifest has a root license file. The repository manifest now
identifies 0.2.0; publication remains a separate step.

- Compile documented starters against both their declared published version
  and the candidate where appropriate. A local `@preview` symlink must not
  substitute development source during a published-package check.
- Automate representative compile checks in CI: report, article, journal,
  letter, invoice, cover and supported proposal starters.
- Retain focused PDF checks for heading flow, wrapped journal headers, counters,
  outlines, selected publications and proposal page limits.
- Compile and inspect real consuming reports and journals; do not require every
  unrelated manuscript conversion to achieve arbitrary pixel parity.
- Inspect the actual distributable file list and compile from a staged package.
  Exclude the CLI, its vendored runtime and binary archives (`tools/**`), local
  workbook conversions, generated build directories and website dependencies.
- Record the source commit/version embedded in a CLI runtime; update it
  deliberately. Its stale snapshot must not ship as a second Typst package.
- Check fresh installation without developer symlinks, links in docs, declared
  minimum Typst version, dependency pins, license and example privacy.

Acceptance: reproducible candidate checks, a clean package, and a migration guide.
Then submit the reviewed 0.2.0 package to Typst Universe as a separate release step.

Current local status: the staged package and focused API/PDF checks pass. The
5 November staged-package run included the then-current uncommitted worktree;
repeat it against the exact chosen release commit before submission. The
independent review found and led to a fix for the `qr-purpose` alias, now covered
by regression. The published-0.1.1 compatibility check passed again on 5 November 2026
using an isolated download. Remaining float-placement differences are documented
as acceptable where content stays readable/correctly captioned. Sparse chapter
endings are addressed through a document-level option in the audited workbook.
The 69-page report has a recorded full visual review; current local article and
journal examples were also rendered and visually checked for columns, figures,
footnotes, headers, index layout, and page-boundary clipping.

## After the package release: general Satz CLI

Use one CLI for document creation: proposed commands are `satz new journal`,
`satz new letter`, `satz new report`, and `satz new proposal`. Names remain
proposals until implemented and tested. Keep optional `journal` daily-entry
workflow, multiple named journals and preferred-editor opening in that tool.

Use versioned starters shared with the documentation. Creating a project should
not require creating config/setup/cover/main files manually. Preserve ordinary
Typst ownership: projects remain usable without the CLI. Let users choose
reproducible pinned versions; reserve a live source checkout for explicit
advanced use. Avoid silently changing the package on every launch.

Ship normal versioned Windows/macOS/Linux downloads with checksums and clear
installation instructions. Continue from the existing standalone Go helper;
end users do not need Go or Python installed. Signing and the distribution
experience belong to CLI release work.

## Defer

Do not gate this release on all NWO schemes, a universal renderer, wholesale
internal renaming, a plugin system, a GUI, arbitrary LaTeX pixel parity, or
turning all native Typst options into Satz-specific wrappers.

Top recommendation: resolve the config/alias contract first, document it next,
and build starters/CLI on that stable interface.
