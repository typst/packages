# Tips for package authors

## Sparse checkout of the repository

Because the repository stores all versions of all packages that ever were
published, its size only grows with time. However, most of the time, you will
only work in a few specific directories (the ones for your own packages). Git
allows for "sparse checkouts", which reduce the time it takes to clone the
repository and its size on your disk.

Follow these steps to clone the repository:

```sh
git clone --depth 1 --no-checkout --filter="tree:0" git@github.com:typst/packages
cd packages
git sparse-checkout init
git sparse-checkout set packages/preview/{your-package-name}
git checkout main
```

## Don't use submodules

The Typst package repository requires the files to be actually copied
to their respective directory, they should not be included as Git submodules.

When copying a package from another Git repository, you should not copy the
`.git` folder, otherwise when creating a commit to publish your package,
Git will replace the copied files with a submodule.

## What to commit? What to exclude?

In some case, simply copying and pasting the contents of the repository in which
you developed your package to a new directory in this repository is enough to
publish a package. However, this naive approach may result in unecessary files
being included, making the size of this repository and of the final archives
larger than they need to be.

There are two solutions to limit this problem: excluding files from the archive
(using the `exclude` key in your [package manifest][manifest]), or simply not
commiting the files to this repository in the first place.

To know which strategy to apply to each file, we can split them in three groups:

- Files that are necessary for the package to work. If any of these files are
  removed, the package would break for the end user. This includes the manifest
  file, main Typst file and its dependencies, and in case of a template package,
  any file in the template directory.
- Files that are necessary for the package to be displayed correctly on Typst
  Universe. This includes the README, and any files that are linked from there
  (manuals, examples, illustrations, etc.). These files can easily be accessed
  by opening the package README.
- Other files. This generally includes test files, build scripts, but also
  examples or manuals that are not linked in the README. These files would be
  almost impossible to access for the final user, unless they browse this GitHub
  repository or their local package cache.

The first two groups should be commited to this repository, but files that are
not strictly necessary for the package to work (the second group) should be
excluded in `typst.toml`. The third group should simply not be copied here, or
you should consider linking them from your README so that they are easily
discoverable. A good example showing how to link examples and a manual is
[CeTZ][cetz].

The only exceptions to this rule are the LICENSE file (that should always be
available along with the source code, so it should not be excluded), and the
README (which is generally a lightweight file, and can provide minimal
documentation in case the user is offline or can't access anything else than
their local package cache for some other reason).

Also note that there is no need to exclude template thumbnails: they are
automatically left out of the archive.

## Tools that can be useful

The community created some tools that can help when developing your package:

- [typst-package-check], to lint your package.
- [tytanic], to test your packages.
- [typship], to easily install your package locally or submit it to Typst Universe.
- [showman], to help you document and publish your package.

[cetz]: https://typst.app/universe/package/cetz/0.3.4
[typst-package-check]: https://github.com/typst/package-check
[tytanic]: https://tingerrr.github.io/tytanic/index.html
[typship]: https://github.com/sjfhsjfh/typship
[showman]: https://github.com/ntjess/showman
[manifest]: manifest.md