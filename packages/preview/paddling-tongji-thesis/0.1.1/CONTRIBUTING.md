# CONTRIBUTING

## Contents

- source files: as a template repository, "source files" are ".typ", ".bib" and some related files with other extension names.
- doc files: including all ".typ" files and even "main.typ", which show how to use "source files".
- config files: These files make our development and use of templates more standardlized (e.g. .gitignore).

## How to contribute

### How to ask for help?

Providing conditions where people ask for help and solve problems is also part of community. We hope to provide technique support in [Discussions](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/discussions).

It has to be **NOTICED** that: **DO NOT CONTACT WITH ANY CONTRIBUTOR THROUGH IM**!

### How to report a bug?

If a bug is confirmed, you can raise it in the [Issues](https://github.com/TJ-CSCCG/tongji-undergrad-thesis-typst/issues).

### How to pull request?

We recommend to follow this workflow step by step:

1. Fork this repository as upstream repository.
2. Clone the repository forked from remote to local.
3. Create a new local branch as a work branch.
4. Commit some changes on the work branch.
5. Push the new local branch to remote with commits.
6. Pull request, from the new remote branch to any branch of upstream repository.

### Before your pull request

Remember to check whether you have added, renamed or removed file in `init-files/`. If so, please update the `.github/patches/package_release.diff` and commit it along with your pull request.

如果你新增、移动或删除了`init-files/`目录下的文件，请检查是否需要更新`.github/patches/package_release.diff`，并将其随PR一同提出。

> [!TIP]
> You can use `git diff HEAD~1 HEAD > package_release.diff` to generate a patch that can be accepted.

> [!IMPORTANT]
> We use `git apply` to apply the patch and generate a package-release branch. Please check if your patch can be applied successfully. If not, we may not be able to merge your branch.
>
> 请务必确保patch可以被`git apply`命令应用。如果patch未更新或无法被正确应用，我们可能将无法合并您的分支。
