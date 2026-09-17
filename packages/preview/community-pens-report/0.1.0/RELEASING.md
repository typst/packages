# Releasing community-pens-report

How to release a new version of this template on your own GitHub repo and
publish it to Typst Universe.

## Mental model

Every published version is permanent. On Typst Universe, each version is a
separate folder (`packages/preview/community-pens-report/0.1.0/`, then `0.1.1/`, ...)
submitted via its own pull request. You never modify an already-published
version folder — you always add a new one.

The version number lives in `typst.toml` and must match:
- the git tag on this repo (`v0.1.1`), and
- the folder name in the `typst/packages` submission (`0.1.1`).

## Phase A — Develop and release in this repo

1. Create a branch, make changes, open a PR and merge (or commit directly).
2. Bump `version` in `typst.toml` (SemVer): `0.1.0` -> `0.1.1` for bugfixes,
   `0.2.0` for new features.
3. Update the README: any `@preview/community-pens-report:0.1.0` examples must use the
   new version.
4. Regenerate `thumbnail.png` if the cover or design changed:
   ```console
   typst compile -f png --pages 1 --ppi 250 template/main.typ thumbnail.png
   ```
   (Thumbnail requirements: longer edge >= 1080 px, file size <= 3 MiB.)
5. Test locally: copy the package into your local Typst package cache under the
   new version folder, then in a scratch directory run
   `typst init @preview/community-pens-report:0.1.1` and `typst compile main.typ`.
   On Windows the package cache is `%LOCALAPPDATA%\typst\packages\preview\`.
6. Tag and push:
   ```console
   git tag -a v0.1.1 -m "v0.1.1"
   git push origin v0.1.1
   ```
7. Create a GitHub release from the tag (website: Releases -> Draft a new
   release -> choose tag -> Publish).

## Phase B — Publish to Typst Universe

Work in your fork of [`typst/packages`](https://github.com/typst/packages),
which lives locally at e.g. `/tmp/packages-fork`.

1. Sync the fork's `main` with upstream (add the remote once):
   ```console
   cd /path/to/packages-fork
   git remote add upstream https://github.com/typst/packages.git   # once
   git fetch upstream
   git checkout main
   git reset --hard upstream/main
   git push --force origin main
   ```
2. Create the version branch:
   ```console
   git checkout -b community-pens-report-0.1.1
   ```
3. Copy the package into a new folder. Do not touch older version folders.
   ```console
   mkdir -p packages/preview/community-pens-report/0.1.1
   cp -r /path/to/community-pens-report/{typst.toml,lib.typ,template.typ,README.md,LICENSE,thumbnail.png,assets,template} \
         packages/preview/community-pens-report/0.1.1/
   rm -f packages/preview/community-pens-report/0.1.1/template/main.pdf   # no build artifacts
   ```
4. Compile-check the copied files, then commit and push:
   ```console
   typst compile packages/preview/community-pens-report/0.1.1/template/main.typ --root packages/preview/community-pens-report/0.1.1
   git add packages/preview/community-pens-report/0.1.1/
   git commit -m "Update community-pens-report to v0.1.1"
   git push -u origin community-pens-report-0.1.1
   ```
5. Open the PR: base `typst:main` <- `azzamjhd:community-pens-report-0.1.1`, titled
   `Update community-pens-report to v0.1.1`.
6. Wait for maintainer review and merge; CI then publishes the package. It can
   take up to ~30 minutes to appear on Typst Universe.

## Author rule (important for shared repos)

The typst/packages maintainers require the author of an update to be the same
person who submitted the previous version. If someone else submits, the
previous author is asked to confirm.

- Friends can contribute and prepare releases freely in this repo (Phase A).
- The Phase B submission should be opened by the account that owns the package
  history (the one named in `authors` in `typst.toml`).
- If a friend becomes a serious co-author, add them to `authors` in
  `typst.toml` before the next submission so the author check passes.

## While a PR is under review

Do not open a second PR for the next version yet. If maintainers request
changes, push new commits to the open branch (e.g. `community-pens-report-0.1.0`);
the open PR updates automatically. Start Phase B for a new version only after
the previous one is merged.
