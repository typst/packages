# Tips for package authors

## Sparse checkout of the repository

Because the repository stores all versions of all packages that ever were
published, its size only grows with time. However, most of the time, you will
only work in a few specific directories (the ones for your own packages). Git
allows for "sparse checkouts", which reduce the time it takes to clone the
repository and its size on your disk.

First, make sure you have forked the repository to your own GitHub account.
Then, follow these steps to clone the repository:

```sh
git clone --depth 1 --no-checkout --filter="tree:0" git@github.com:{your-username}/packages
cd packages
git sparse-checkout init
git sparse-checkout set packages/preview/{your-package-name}
git remote add upstream git@github.com:typst/packages
git config remote.upstream.partialclonefilter tree:0
git checkout main
```

The `packages` directory you are in still corresponds to the whole repository.
Do not delete or edit the `README.md`, `LICENSE` or any other file at the root.
Instead, create the directory `packages/preview/{your-package-name}/{version}`
and copy your files here. Note that `packages/` is a directory in the
`packages` repository: if you look at the full path, there should be two
consecutive parts called `packages`.

## Don't use submodules

The Typst package repository requires the files to be actually copied
to their respective directory, they should not be included as Git submodules.

When copying a package from another Git repository, you should not copy the
`.git` folder, otherwise when creating a commit to publish your package,
Git will replace the copied files with a submodule.

## What to commit? What to exclude?

Please refer to the standalone documentation on the [Contents of a
package][contents].

## Tools that can be useful

The community created some tools that can help when developing your package:

- [typst-package-check], to lint your package.
- [tytanic], to test your packages.
- [typship], to easily install your package locally or submit it to Typst Universe.
- [showman], to help you document and publish your package.

[cetz]: https://typst.app/universe/package/cetz/0.3.4
[contents]: contents.md
[typst-package-check]: https://github.com/typst/package-check
[tytanic]: https://typst-community.github.io/tytanic/
[typship]: https://github.com/sjfhsjfh/typship
[showman]: https://github.com/ntjess/showman
[manifest]: manifest.md
