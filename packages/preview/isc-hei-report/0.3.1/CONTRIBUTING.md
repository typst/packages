# Building and deployment notes 
This file explains how to to build locally and deploy to Typst app and Typst templates. 

Since v0.2.0, the build process is based on [`just`](https://github.com/casey/just)


# Toolchain
To build, test and deploy new releases I'm using [Just](https://github.com/casey/just). On Ubuntu, I'm using the `snapd` version of `just`.

In reality there's a single repos and source folder for both the report and the bachelor thesis, which are then split and handled differently from Typst perspecive. All the heavy-lifting for this is made using `just`.

## Working on the template
:warning: If running on Mac, you might have to adapt the shell used in `scripts/package` (uncomment the second line).

To develop new features in the template, a symblink the working directory to the preview directory can be created using :

```bash
just install-symblink-bthesis

OR

just install-symblink-report
```

> [!TIP]
> The idea of the `just` command is to create a symlink to the location Typst looks for templates locally. For instance in a Linux environment it would be:
>
> ```shell
> mkdir ~/.local/share/typst/packages/local/PACKAGE.NAME
> ln -s REPO_FOLDER \
> ~/.local/share/typst/packages/local/PACKAGE.NAME/PACKAGE.VERSION
> ```
>

These creates both `report` and `bachelor-thesis` packages for testing conveniently from a single directory.

## Testing local deployment
When sufficiently confident that it seems to work, it's time to test a `preview` version as created by `typst`.

To deploy locally for `typst` command-line

```bash
just uninstall-preview pack_distro_preview
```

then test the template as needed by creating a local sample

```bash
typst init @preview/isc-hei-report:0.3.1
```

Then go the directory, try to compile with `typst watch report.typ`.

## Deploying to Typst universe

- Clone the [Typst universe repos](https://github.com/typst/packages/tree/main), and `just pack_distro DEST_TO_REPOS/packages/preview`. 
- Do not forget to add a proper `.gitignore` to remove all PDFs
- Lint for kebab-case only
- Create PR as usual. A template creates automatically the PR text with update etc... If changes are required by CI/CD, push to local repository. It updates the PR automatically.

## Image quantization
To reduce the size of images, which is nice for reducing the template size on the Universe.

```bash
pngquant *.png --ext .png --force
```