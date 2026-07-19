# Building and deployment notes 
This file explains how to to build locally and deploy to Typst app and Typst templates. 

Since v0.2.0, the build process is based on [`just`](https://github.com/casey/just)

# Toolchain & dependencies
To build, test and deploy new releases I'm using [just](https://github.com/casey/just), which is really nice! On Ubuntu, I'm using the the app version of `just`. 

`ImageMagick` is used for creating the thumbnails.

Both can be installed with:
```bash
sudo apt install just imagemagick pngquant
```

# Development process
For the sake of simplicity from a developer's perspective, there's a single repository on this side, containing a singe source folder for both the report and the bachelor thesis. When building, the repos is split and handled differently from Typst perspecive. All the heavy-lifting for this is made using `just`.

## Working on the template
:warning: If running on Mac, you might have to adapt the shell used in `scripts/package` (uncomment the second line).

To develop new features in the template, a symlink to the preview directory (of either the bachelor thesis or the report) can be created using:

```bash
just install-symblink-bthesis

OR

just install-symblink-report
```

Once done, you can work on one of the document and compile it with 

```bash
typst watch bachelor_thesis.typ
```

for instance.

## Testing local deployment
When sufficiently confident that it seems to work, it's time to test a `preview` version as created by `typst`.

To deploy locally for `typst` command-line

```bash
just uninstall-preview pack_distro_preview
```

This creates both `report` and `bachelor-thesis` packages for testing conveniently from the preview directory. The templates can be tested as needed by creating a local sample using:

```bash
typst init @preview/isc-hei-report:0.3.1
```

Then go the directory, try to compile with `typst watch report.typ`.

For convenience, `scripts/test-report.sh` and `scripts/test-thesis.sh` enable to quickly check for errors before deploying to the universe.

## Deploying to Typst universe

- Fork the [Typst universe repos](https://github.com/typst/packages/tree/main)
- Clone the fork it into `DEST_TO_REPOS`, and then `just pack_distro DEST_TO_REPOS/packages/preview`. 
- Lint for kebab-case only (at least publicly accessible functions)
- Test using `typst-package-check` from https://github.com/typst/package-check, using `typst-package-check check @preview/isc-hei-bthesis:0.5.0` from the `packages` directory *inside* of the cloned repos.
- From github, create PR as usual. A template creates automatically the PR text with update etc... If changes are required by CI/CD, push to local repository. It updates the PR automatically.

## Forking issues

If the forked repository is still "ahead" of the forked branch, make this : 

```bash
git fetch upstream
git checkout main
git reset --hard upstream/main
git push origin main --force
```

## Image quantization
To reduce the size of images, which is nice for reducing the template size on the Universe.

```bash
pngquant --quality 10-80 *.png --ext .png --force
```