# Publish the UIU CSE FYDP template

Package: **`academic-uiu-fydp`**, version **`0.1.0`**. Source repository:
[shaadahmmed/uiu-fydp-template](https://github.com/shaadahmmed/uiu-fydp-template).
The manifest includes that URL and the author credit. The package has been
prepared for submission; it has not been submitted or accepted by this workflow.

## What is prepared

- A versioned manifest, package entry point, and `@preview` starter import.
- A package-specific README documenting the distributed files and public API.
- CC BY 4.0 license, original attribution, changes notice, and changelog.
- A thumbnail rendered from the freshly initialized, logo-free template.
- Checks for local and initialized reports in both stages, optional pages, multiple
  students, documentation links, version consistency, and thumbnail requirements.
- CI running those checks on the baseline and latest stable Typst compiler.
- A submission bundle, checksum, draft PR description, and safe staging command.

Reports build without any university logo. Optional images in `local-assets/`
are ignored by Git and excluded from the submission. The original workspace image
was moved there for local use. Removing it from the current source does not erase
an image from earlier Git commits.

## 1. Review and push this repository

From this repository's root, generate the release files:

```sh
python3 scripts/project.py package
```

Inspect `build/package-final.pdf` and `build/package-fydp-1.pdf`. Review the
prepared changes, commit them, and push to your own repository:

```sh
git status --short
git add .
git commit -m "Prepare academic-uiu-fydp for Typst Universe submission"
git push origin main
```

The command creates:

```text
dist/academic-uiu-fydp/0.1.0/             Submission directory
dist/academic-uiu-fydp-0.1.0.tar.gz       Source archive
dist/academic-uiu-fydp-0.1.0.tar.gz.sha256 Archive checksum
dist/universe-pr.md                     Draft PR description
```

The submission directory contains only `lib.typ`, `typst.toml`, `README.md`,
`LICENSE`, `NOTICE`, `CHANGELOG.md`, `thumbnail.png`, `template/`, and `docs/`.
The `README.md` comes from `packaging/README.md`, rather than the development
README. Build tools, local assets, and editor settings are not included.

Normal report PDFs use a fixed creation timestamp through the helper; set
`SOURCE_DATE_EPOCH` to select a different timestamp. Archive metadata is not
normalized, so separate package runs can produce different archive checksums.

## 2. Fork and clone the Universe repository

Open [typst/packages](https://github.com/typst/packages) on GitHub and click
**Fork** under your `shaadahmmed` account. If you already have that fork, update
it from upstream before creating the submission branch.

Run these commands from this template repository's root. The clone is placed
beside this repository; use a different path if that folder already exists.

```sh
git clone --filter=blob:none --sparse https://github.com/shaadahmmed/typst-package.git ../typst-packages
git -C ../typst-packages sparse-checkout set packages/preview
git -C ../typst-packages switch -c add-academic-uiu-fydp-0.1.0
```

Check [existing packages](https://github.com/typst/packages/tree/main/packages/preview)
and open pull requests for name conflicts before submitting. The helper does not
check the online registry or reserve a package name. The maintainers review
[naming and manifest requirements](https://github.com/typst/packages/blob/main/docs/manifest.md).

## 3. Stage the tested package into your fork

From this template repository's root:

```sh
python3 scripts/project.py stage --packages-repo ../typst-packages
```

This rebuilds and validates the bundle, then copies it into:

```text
../typst-packages/packages/preview/academic-uiu-fydp/0.1.0/
```

The command does not commit, push, or open a pull request. It refuses to overwrite
an existing version directory. If you are revising your own unsubmitted draft,
review and remove only that draft directory before staging again, or copy the
changed files deliberately. Never replace an already published version.

## 4. Commit, push, and open the pull request

```sh
git -C ../typst-packages diff --stat
git -C ../typst-packages add packages/preview/academic-uiu-fydp/0.1.0
git -C ../typst-packages diff --cached --stat
git -C ../typst-packages commit -m "Add academic-uiu-fydp 0.1.0"
git -C ../typst-packages push -u origin add-academic-uiu-fydp-0.1.0
```

Open your fork on GitHub and choose **Compare & pull request**:

- Base repository: `typst/packages`
- Base branch: `main`
- Head repository: `shaadahmmed/typst-package`
- Head branch: `add-academic-uiu-fydp-0.1.0`
- Title: `academic-uiu-fydp:0.1.0`

Use the current upstream PR template. Add the description in
`dist/universe-pr.md`, checking upstream requirements yourself. The generated
text records the compiler actually used and does not pre-check review statements.
Explain that this is Shaad Ahmmed's community adaptation of Swakkhar Shatabda's
CC BY 4.0 Overleaf template, with attribution retained and no bundled logo.

Review the official [submission instructions](https://github.com/typst/packages/blob/main/docs/README.md)
and [licensing guidance](https://github.com/typst/packages/blob/main/docs/licensing.md).
CC BY is an accepted package license category; maintainers may still request
changes, including to naming, documentation, or starter licensing. This adaptation
retains the inherited license and does not claim to waive the original author's rights.

## 5. After acceptance

Once the PR is merged and upstream processing completes, test the public package:

```sh
typst init @preview/academic-uiu-fydp:0.1.0 my-fydp
cd my-fydp
typst compile main.typ report.pdf
```

Verify that the Universe page has the right thumbnail and **Start from template**
works in the web app. Then update the source README status and add the actual
Universe link. You may tag your source release `v0.1.0`. A GitHub tag or release
alone does not publish to Typst Universe.

## Future updates

GitHub changes do not automatically update Universe or existing student projects.
For each release:

1. Increase `version` in `typst.toml`, for example `0.1.0` to `0.1.1`.
2. Update the `@preview` import in `template/main.typ` and all versioned examples
   and release paths in `README.md`, `packaging/README.md`, and this guide.
3. Add a new entry to `CHANGELOG.md`; preserve historical entries.
4. Run `python3 scripts/project.py package`. Version checks reject stale imports.
5. Create a new branch in your updated packages fork and use the staging command.
   It selects the new version directory from the manifest automatically.
6. Submit another PR containing the new version directory; retain old versions.

Raise `compiler`, `.typst-version`, and the CI baseline together only when raising
the minimum supported compiler. The `latest` CI job follows new stable releases.

Users update an existing project's package import explicitly. Updating the import
changes the layout code; it does not overwrite their chapter files or configuration.
