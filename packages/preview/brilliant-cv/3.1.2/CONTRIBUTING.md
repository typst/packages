# Contributing to Brilliant CV

Thanks for helping keep Brilliant CV polished! This document explains how to run the template locally, adapt it to your needs, and submit improvements upstream.

> **Why the extra setup?**  
> Typst packages are resolved by namespace (`@preview/<name>:<version>`) and normally live inside Typst’s cache/data directories, so the compiler cannot load this template straight from the repository without a link step. The `justfile` automates that link by calling `utpm ws link --force --no-copy`, which registers the workspace as the authoritative copy of `@preview/brilliant-cv:<version>` on your machine. See the Typst package repository docs for more background on how package resolution works.  
> [Typst packages](https://github.com/typst/packages)

---

## 1. Prerequisites

- [Typst](https://github.com/typst/typst) CLI `>= 0.11.0` (matches `typst.toml`)
- [utpm](https://github.com/Thumuss/utpm) (Workspace/package manager used by the automation)
- Fonts listed in `README.md` (Roboto, Source Sans 3, Font Awesome 6)
- macOS/Linux shell with `just` (or run the equivalent commands manually)

Optional but helpful:

- `typstyle`, `pre-commit`, `typos` (recommended tools already mentioned in the README)

---

## 2. Local development workflow

1. **Clone the repo**
   ```bash
   git clone https://github.com/yunanwg/brilliant-CV.git
   cd brilliant-CV
   ```

2. **Link the package into Typst**
   ```bash
   just link
   # or run: utpm ws link --force --no-copy
   ```
   This step is required before Typst can resolve `#import "@preview/brilliant-cv:<version>"`.

3. **Iterate with watch mode**
   ```bash
   just dev
   ```
   - Starts `typst watch template/cv.typ temp/cv.pdf` so you can edit files while the PDF refreshes.
   - On exit it compiles one last time, unlinks the workspace, and clears temporary artifacts.

4. **One-off builds / preview**
   - `just build` → compile `template/cv.typ` into `temp/cv.pdf`
   - `just open` → build then open the resulting PDF
   - `just watch` → plain `typst watch` without the lifecycle extras
   - `just reset` → a convenience combo of `just unlink` + `just clean`

> **Tip:** If Typst refuses to resolve the package after a reboot, re-run `just link`. The registration lives outside the repo and can be pruned by Typst itself.

---

## 3. Repository layout

- `src/` – core reusable components (`cv`, `letter`, utilities). Keep backward compatibility: prefer adding new parameters instead of breaking existing ones, and mirror the “new + deprecated alias” pattern already in `src/lib.typ`.
- `template/` – the bootstrapped project users receive (`cv.typ`, `letter.typ`, modules, assets, `metadata.toml`). Any user-facing customization should be expressed here or via metadata defaults.
- `template/modules_<lang>/` – content examples per language. Add new samples here when you introduce language-specific features.
- `template/metadata.toml` – canonical list of configurable knobs. Update it (and the README) if you add new keys.
- `docs/` – Typst documentation for the API (regenerate if you alter the public surface).
- `justfile` – task runner (see Section 2).

---

## 4. Making changes

### 4.1 Personal customizations

If you simply want to adapt the template to your own profile:

- Change `template/metadata.toml` (language selection, layout, injection settings, personal info).
- Update the relevant `modules_<lang>/*.typ` files with your content.
- Keep `src/` untouched unless you plan to submit the enhancement back.

### 4.2 Feature / bug-fix contributions

1. **Create a branch** and make your changes in `src/` and/or `template/`.
2. **Document anything user-facing**:
   - Update `README.md` (or `docs/`) for new parameters.
   - Add comments to `metadata.toml` if you introduce new knobs.
3. **Keep compatibility**:
   - For renamed parameters, follow the aliasing approach already used in `src/lib.typ`.
   - Don’t remove template options without deprecation notes.
4. **Run the checks**:
   ```bash
   just build
   # optionally
   just dev    # for manual PDF inspection
   just reset  # to clean up before committing
   ```
5. **Commit using conventional commits** (the repo follows conventional commit messages for history clarity).
6. **Open a PR** describing the change, how to test it, and screenshots/PDF snippets if the visual output changed.

---

## 5. Submitting PRs

Before pushing:

- Ensure `temp/` and generated PDFs are excluded (already covered by `.gitignore`, but double-check).
- Re-run `just link` if CI instructions include `typst compile` steps—missing links are the most common local failure mode.
- If you tweak the automation (`justfile`, `utpm` usage), explain the reasoning in the PR since other contributors rely on this workflow to bypass Typst’s package lookup restrictions.

After CI passes, a maintainer will review. Be ready to:

- Rebase / squash based on review requests.
- Provide snippets of rendered output if the diff touches styles or layouts.

Thanks again for contributing! If you hit any setup hurdles, start a discussion or issue before opening a PR so we can keep these docs accurate.
