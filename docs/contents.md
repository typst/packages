# Contents of a package

In order to understand what should be included in a Typst package, it helps to
understand how a package is processed while and after being submitted to [Typst
Universe][typst_universe]. The following sections will explain what your
package may or should not contain during different parts of this processing.

The general gist is that, as your package travels from your repository to end
users machines, various files probably can (and should) be removed. This is
done to:

1. Keep [this repository][this_repo] small and
2. Reduce downloads (and disk usage) for end users


## Categories of files

The files possibly contained in your package are broadly grouped into the
following three categories.


### Required files

These files are necessary for the package to work. If any of these files are
removed, the package would break for the end user.

This includes the manifest file (`typst.toml`), main Typst file (mentioned
under `package.entrypoint` in `typst.toml`) and its dependencies, and in case
of a template package, any file in the template directory. On top of this, the
following files are also included:

- The LICENSE file (e.g. `LICENSE` or `COPYING`): This should always be
  available along with the source code
- The README file (e.g. `README.md`): This is generally a lightweight file, and
  can provide minimal documentation in case the user is offline or can't access
  anything else than their local package cache for some other reason

Examples:

- `README.md`
- `LICENSE`
- `typst.toml`
- `src/lib.typ` (see `package.entrypoint` in `typst.toml`)
- `my-plugin.wasm` (for WASM plugins)
- Images, icons, and other assets if your package reproduces these in documents


### Documentation files

These files are necessary for the package to be displayed correctly on [Typst
Universe][typst_universe].

This includes any files that are linked from the README (manuals, examples,
illustrations, etc.). These files can easily be accessed by opening the package
README. If your README links to directories (such as `examples/`), include
these directories as well. In the case of PDF manuals, for example, it suffices
to include the built PDF without the source code.

Examples:

- `docs/user-manual.pdf` (but *not* the source code, if any)
- `assets/screenshot.png` (if your README links to that)
- `examples/try-this.typ` (if your README links to that)


### Other files

This generally includes test files, build scripts, but also examples or manuals
that are not linked in the README.

These files would be almost impossible to access for the final user, unless
they browse [this GitHub repository][this_repo] or their local package cache.

Examples:

- `.github`
- `CHANGELOG.md`
- `Makefile`
- `tests/`


## Stage 1: Package development

This is the state of the package that you work on. Your package is most likely
published to some git forge (GitHub, GitLab, …) but it doesn't have to be.

At this stage, the package is entirely under your control and you decide what
files you keep in your repository. Your repository may already contain various
supporting files and the actual source code of your package. If you
auto-generate these files by some means, they don't have to be present yet,
however.

**Here, your package contains**:

- [Required files][files_required]
- [Documentation files][files_docs]
- [Other files][files_other]

Here's a fictional example package in stage 1:

```text
my-package
├── assets
│   └── screenshot.png
├── bin
│   └── build
├── CHANGELOG.md
├── CONTRIBUTING.md
├── docs
│   ├── user-manual.pdf
│   └── user-manual.typ
├── examples
│   └── try-this.typ
├── LICENSE
├── Makefile
├── README.md
├── src
│   ├── a-subfile.typ
│   └── lib.typ
├── test
│   ├── ...
│   └── utils.typ
└── typst.toml
```


## Stage 2: Published package

This is the state of the package that you commit to the [Typst `packages`
repository][this_repo].

To prepare for this step, you can copy your repository contents into [this
repository][this_repo] and remove all files labeled [*Other
files*][files_other] above. If you don't have any files that fall into the
category of [*Other files*][files_other] in your package, you can skip to the
next section.

**Here, your package contains**:

- [Required files][files_required]
- [Documentation files][files_docs]

Continuing with the fictional example from above, this is the content in stage
2. In other words, these are the files you would commit here:

```text
my-package
├── assets
│   └── screenshot.png
├── docs
│   └── user-manual.pdf
├── examples
│   └── try-this.typ
├── LICENSE
├── README.md
├── src
│   ├── a-subfile.typ
│   └── lib.typ
└── typst.toml
```


## Stage 3: Imported archive

This is the final package content that will be downloaded and stored in a
user's package cache when they `#import` your code.

The transition from stage 2 to stage 3 is performed automatically, based on the
value of `package.exclude` in your package manifest (`typst.toml`). This means
you have to configure your package manifest to exclude all files labeled
[*Documentation files*][files_docs] above.

**Here, your package contains**:

- [Required files][files_required]

Based on the example above, we end up with:

```text
my-package
├── LICENSE
├── README.md
├── src
│   ├── a-subfile.typ
│   └── lib.typ
└── typst.toml
```

<!-- External links -->
[typst_universe]: https://typst.app/universe/
[this_repo]: https://github.com/typst/packages
<!-- Internal links -->
[files_required]: #required-files
[files_docs]: #documentation-files
[files_other]: #other-files
