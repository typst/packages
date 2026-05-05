# Atlas Solver and LazyDeferred Resolution

This document describes how Atlas resolves versions when SAT solving is enabled,
including the current lazy-loading flow.

## Scope

This is the behavior used by `loadWorkspace(..., doSolve = true)` in
`/Volumes/projects/nims/atlas/src/depgraphs.nim`.

The lazy behavior is enabled when both are true:

- `doSolve == true`
- traversal mode is `AllReleases`

In code, this is `deferChildDeps = doSolve and mode == AllReleases`.

You can force the previous eager behavior with `--no-lazy-deps`.
When set, Atlas loads transitive dependencies eagerly and skips the lazy rerun loop.

## High-Level Algorithm

1. Build an initial dependency graph.
2. Create a SAT formula from known versions and constraints.
3. Solve SAT.
4. If the chosen solution references still-lazy dependencies, load those deps and rerun.
5. Repeat until no more lazy packages are required, then activate and checkout selected versions.

## Detailed Flow

### 1. Graph expansion with lazy children

During expansion (`expandGraph` in `/Volumes/projects/nims/atlas/src/dependencies.nim`):

- Root and directly encountered dependencies are initialized and traversed.
- Child dependencies can be marked `LazyDeferred` instead of being fully loaded.
- A lazy package is still inserted into the graph with a placeholder version entry
  (`*@-` with a `#head` release payload) so the graph remains structurally connected.

This keeps the first pass small while preserving package identity.

### 2. SAT formula construction

`toFormular` in `/Volumes/projects/nims/atlas/src/depgraphs.nim` builds constraints:

- A SAT var is created per package version.
- Feature SAT vars are created per release feature.
- Root packages require exactly one version.
- Non-root packages allow at most one version.
- Dependency implications are added for loaded packages.

Important for lazy mode:

- Dependency implications to `LazyDeferred` nodes are skipped for the current pass.
- If a loaded version has unsatisfied loaded deps, that version is negated.

### 3. First solve pass

`solve(graph, form, rerun)` runs the SAT solver.

If SAT succeeds:

- Selected versions/features are marked active.
- Atlas scans active releases and enabled features.
- Any required dependency that is still `LazyDeferred` is queued for load.
- Those packages are switched to `DoLoad`, their cached versions are cleared,
  and `rerun = true`.

If SAT fails:

- Atlas tries a conflict-recovery lazy load pass:
  - It scans already-loaded packages and pulls in referenced lazy deps.
  - For feature-dependent lazy deps, it only includes features enabled via
    context/CLI flags (unselected features are ignored during UNSAT recovery).
  - If a package has special (`#...`) versions, it prioritizes deps from those
    special versions while building the recovery set.
- If any lazy deps are added, rerun is requested.
- If no further lazy deps can be loaded, Atlas reports a version conflict.

### 4. Rerun mechanics

When `rerun == true`, `loadWorkspace` recursively re-runs:

- version var IDs are reset,
- feature var mappings are cleared,
- graph is expanded again with newly promoted `DoLoad` packages,
- SAT is rebuilt and solved again.

The loop ends when SAT succeeds and no selected dependency remains lazy.

### 5. Activation

After final solve:

- duplicate module names are checked (and must be resolved with `pkgOverrides`),
- selected package commits are checked out,
- build steps/hooks run,
- `nim.cfg` is generated/updated.

## Explicit version narrowing in lazy mode

When explicit versions are discovered and a package is traversed in
`ExplicitVersions` mode, Atlas can narrow that package's version table to only
explicit matches (commit prefixes, `#head`, exact version, etc.).

This narrowing is currently applied in lazy SAT mode so reruns don't keep
considering unrelated historical versions once a package is explicitly pinned.

## Limitations and user-visible tradeoffs

### Multiple solver passes are expected

Lazy loading reduces initial work, but large graphs may require many SAT reruns.
This is normal and can increase install/update time.

### Conflicts can surface late

Because deferred deps are not fully constrained in early passes, an initial SAT
success can later become UNSAT after more lazy deps are loaded.

### Git metadata quality matters

Atlas depends on tags, commit lookup, and version extraction from Nimble files.
Repos with inconsistent tags/versions can produce warnings, fallback behavior,
or reduced candidate sets.

### Special-version-heavy graphs may bias recovery loading

In UNSAT recovery, packages with special (`#...`) versions prioritize deps from
those special versions. This helps branch/commit pin workflows, but may delay
loading semver-only alternatives until later reruns.

### Feature-dependent deps load only when features are enabled

Lazy feature dependencies are pulled in only if features are enabled via:

- CLI/global feature flags, or
- SAT-selected feature vars for active releases.

During UNSAT recovery specifically, only context/CLI-enabled features are used
to select lazy feature deps (there is no SAT-selected feature model on UNSAT).

If a feature is not enabled, its lazy deps are intentionally not loaded.

### Duplicate module names are solved separately

SAT may find a version assignment that still has duplicate module names from
forks/official packages. Users must resolve this with `pkgOverrides` in
`atlas.config`.

## Practical guidance

- Use `--dumpgraphs` and `--showGraph` when diagnosing rerun-heavy or conflict cases.
- Expect more reruns in repos with many optional features or forked packages.
- Add `pkgOverrides` early when both official and forked packages can appear.
