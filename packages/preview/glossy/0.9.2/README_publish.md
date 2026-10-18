# Publish changes

## Links

* repository to publish to: https://github.com/typst/packages/tree/main/packages/preview/glossy

* doc: https://github.com/typst/packages/blob/main/docs/README.md
* doc: https://github.com/typst/packages/blob/main/docs/tips.md#what-to-commit-what-to-exclude

Example PR from glossy:

- [v0.9.0](https://github.com/typst/packages/pull/3323)
- [v0.8.0](https://github.com/typst/packages/pull/2122)

## Prepare to publish

**There is a branch `submitted-upstream`: It will no longer be used for publishing.**

1. Make these commands run without error

    ```bash
    just fmt    # format all .typ files in place
    just check  # fmt-check + full test suite
    ```

2. Update changelog in `README.md`

3. Update version in `typst.toml`

   ```bash
   just bump patch # or minor
   ```

4. Run full pre-submission checks

   ```bash
   just pre-submit  # clean → images → check
   ```

5. Commit to `main` and create a version tag.

   ```bash
   git tag -a vx.y.z -m "x.y.z"
   git push && git push --tags
   ```

6. Create a fork of https://github.com/typst/packages/

7. Copy package files into a local clone of the upstream registry.

   ```bash
   cd ~/src/glossy
   TYPST_PACKAGES_REPO=~/typst-packages

   ver=$(grep '^version' "typst.toml" | cut -d'"' -f2)
   dest="$TYPST_PACKAGES_REPO/packages/preview/glossy/$ver"

   rm -r "$dest"
   mkdir -p "$dest"
   cp -r src "$dest/"
   cp -r lib.typ LICENSE README.md README_publish.md README_development.md typst.toml themeshots.png thumbnail.png "$dest/"
   ```

8. On fork of https://github.com/typst/packages/

   ```bash
   cd $TYPST_PACKAGES_REPO
   git switch -c submit_glossy
   git add packages/preview/glossy/$ver
   git commit -m "glossy:$ver"
   git push -u origin submit_glossy
   ```

## Notes on just

Run `just` (or `just help`) to list all available recipes.