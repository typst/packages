<!--
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: (C) 2025 Andreas Hartmann <hartan@7x.de>

Upstream-Project: <https://gitlab.com/tgdp/templates>
Configured-For-Version: 1.4.0
-->

# Cloudy Contributing Guide


## Table of Contents

1. [Welcome][a]
1. [Ground rules][b]
1. [Before you start][c]
1. [Share ideas][d]
1. [Environment setup][e]
    1. [Containerized environment][ea]
        1. [Getting the container][eaa]
        1. [Generic editor/IDE integration][eab]
    1. [Host-based environment][eb]
1. [Conventions][f]
1. [Commit style guide][g]
1. [Linting the code][h]
1. [Testing the code][i]
1. [Creating merge requests][j]
1. [Interacting with GNU `make`][k]
1. [Making a release][l]

[a]: #welcome
[b]: #ground-rules
[c]: #before-you-start
[d]: #share-ideas
[e]: #environment-setup
[ea]: #containerized-environment
[eaa]: #getting-the-container
[eab]: #generic-editoride-integration
[eb]: #host-based-environment
[f]: #conventions
[g]: #commit-style-guide
[h]: #linting-the-code
[i]: #testing-the-code
[j]: #creating-merge-requests
[k]: #interacting-with-gnu-make
[l]: #making-a-release


## Welcome

Welcome to the Cloudy Contributing Guide, and thank you for your interest!

Regardless of what you want to contribute, please read the following sections first:

1. [Ground rules][b]
2. [Before you start][c]

We accept the following contributions:

- To **report a bug or other issue**, please read:
    - [Share ideas][d]
- To **request/suggest a feature or other addition**, please read:
    - [Share ideas][d]
- To **contribute code (fixes/features/other things)**, please read:
    - [Environment setup][e]
    - [Commit style guide][g]
    - [Linting the code][h]
    - [Testing the code][i]
    - [Creating merge requests][j]
- To **contribute documentation**, please read:
    - [Environment setup][e]
    - [Commit style guide][g]
    - [Linting the code][h]
    - [Creating merge requests][j]

However, at this time, we do not accept the following contributions:

- Translations
- Backports of features or fixes to non-current versions

If you cannot find your specific contribution in any of the lists, either pick the nearest match or
just [open an issue][open_an_issue] and ask for help.


## Ground rules

In order to contribute, you must adhere to the following behavior policies:

- Be respectful of differing viewpoints.
- Kindly accept constructive criticism.
- Do not use derogatory language.
- Be empathetic towards fellow contributors.


## Before you start

All contributions, regardless of their nature, must be made through GitLab. Please refrain from
mailing changes or suggestions to contributors or maintainers directly, they will be ignored.

**Note**: If you do not have a GitLab account, you must [sign up for a new GitLab account][c0]
first.

[c0]: https://gitlab.com/users/sign_up


## Share ideas

You're cordially invited to share your ideas, feedback, and suggestions. This includes, but is not
limited to:

- Features you'd like to see
- Bugs in the code
- Documentation improvements
- Additions or changes to development workflows
- New and exciting tools for development

For any of those, please [open an issue in GitLab][open_an_issue]. If there are pre-defined
templates, please always prefer to use a template that you deem appropriate. If none fits, create a
blank issue instead.


## Environment setup

Setting up a local development environment can be done in a number of ways. However, only the
[Containerized environment][ea] is officially supported. Any other development environment is your
own to manage and fix in case things break.

We **strongly recommend** the [Containerized environment][ea] as it should be simple to use and
reduces setup and inconsistencies to a minimum. All official documentation for developing in this
project assumes you use this environment.

> **Note**: Any other environment setup isn't officially supported. You cannot expect to get help or
> guidance when using any of these.

If, for some reason, you are either unwilling or unable to use the [Containerized environment][ea],
you can attempt a regular [Host-based environment][eb] instead. This setup is documented only for
the sake of completeness and you should prefer to avoid it if possible.


### Containerized environment

This repo uses GNU `make` as build system/command runner and an OCI container to manage
dependencies. To use this repo, at the very least you must install:

- [GNU bash][ea0]
- [GNU coreutils][ea1] (or any other implementation of `realpath`, `basename` and `dirname`)
- [podman][ea2]

After that, the following command should *just work*:

```bash
bin/make
```

It will automatically download the necessary container and setup everything for you. If downloading
the container fails, refer to section [Getting the container][eaa]. Otherwise, your setup is now
complete and you can continue with your contribution.

[ea0]: https://www.gnu.org/software/bash/
[ea1]: https://www.gnu.org/software/coreutils/
[ea2]: https://podman.io/


#### Getting the container

In order to work, this project requires a container with the dependencies installed. The command
mentioned under [Containerized environment][ea0] usually takes care of setting everything up for
you. In some cases you may get an error message about the download failing due to *invalid bearer
tokens* or any other kind of *missing authentication*. [Refer to the GitLab docs][eaa0] for further
instructions on what can be done to resolve this issue.

The command you need to enter should look something like this:

```bash
podman login -u "$YOUR_GITLAB_USERNAME" registry.gitlab.com
```

Now retry the setup under [Containerized environment][ea0]. If it still doesn't work, please [reach
out to us][open_an_issue] and explain the problem you're facing. In the meantime, you can try to
build the container locally to get going with development if you wish.

To use the local container, you have to run the following setup commands from the base directory of
this project every time you want to work with it:

```bash
source .env
export CONTAINER_IMAGE="${CONTAINER_IMAGE/registry.gitlab.com/localhost}"
```

Then, to build the container run:

```bash
if ! podman image exists "$CONTAINER_IMAGE:$CONTAINER_TAG" &> /dev/null; then
    podman build -t "$CONTAINER_IMAGE:$CONTAINER_TAG" -f Containerfile.develop .
fi
```

> Note: This command need only be executed once, or whenever the container tag changes.

[eaa0]: https://docs.gitlab.com/18.0/user/packages/container_registry/authenticate_with_container_registry/


#### Generic editor/IDE integration

To make the most of the development container during development, you can integrate the container
with an editor/IDE of your choice. Simply extend the `$PATH` variable of your editor/IDE with the
`bin/` subfolder in this project to get access to those binaries from the container. For example, if
you're using [`neovim`][eab0] as editor, run the following command in a terminal (from the root of
the project) to launch [`neovim`][eab0] with `$PATH` extended:

```bash
PATH="$PWD/bin:$PATH" nvim
```

Now for example the `make` executable used by [`neovim`][eab0] should be the one inside the
development container.

If your editor/IDE has a kind of "remote containers" extension, you may of course try to use that as
well. Please be aware that we do not currently offer support for this kind of integration.
Nevertheless, you are cordially invited to share your experience if you try this out.

[eab0]: https://neovim.io


### Host-based environment

> **Note**: Prefer the [Containerized environment][ea] if possible.

Refer to the contents of the [Containerfile.develop][eb0] and adapt the setup steps from there to
your system. There is no general guidance on how to translate individual [Containerfile
statements][eb1] to operating system specific commands, so you may have to do some research. Most
importantly, note that package names will likely differ if you're reproducing the setup on a
different operating system than the container uses.

Once your setup is complete, check the contents of the [`.env` environment file][eb2]. It may
contain definitions for environment variables required to perform development. In that case,
remember to source the environment variables like so:

```bash
source .env
```

This step has to be performed in every shell instance you want to develop in. If you are using
external tools such as an IDE, make sure the IDE is aware of these environment definitions, too.

In this setup, the contents of the `bin/` subfolder will not work for you. Instead, you must
"translate" invocations accordingly by stripping out leading `bin/`. For example, when the docs tell
you to run `bin/make`, you must call plain `make` instead.

[eb0]: ./Containerfile.develop
[eb1]: https://docs.docker.com/reference/dockerfile/
[eb2]: ./.env


## Conventions

Our project has adopted the following conventions for contributing:

- [Conventional Commits][conventional_commits], as described in the [Commit style guide][g] section
- [Semantic Versioning][semantic_versioning], as described in the [Making a release][l] section


## Commit style guide

**TL;DR**:

1. Make yourself familiar with [Conventional Commits][conventional_commits]
2. Select an atomic, self-contained portion of your changes for the commit
3. Choose a title that summarizes the changes:
    - *Remember: This title will show up in the official Changelog*
    - Allow users without technical background to understand it if possible
    - Keep it simple and prefer to explain technical stuff/details in the body
4. Give a technical rundown of your changes in the commit body
    - Link to external resources if possible
    - Explain what you tried and what didn't work if applicable
    - Mention why a change was necessary wherever it makes sense

**The long version**:

The project adheres to [Conventional Commits][conventional_commits]. We do this because we believe
that commit messages are part of a projects documentation. In addition, this allows us for example
to automatically generate changelogs from the git history during releases and elsewhere, reducing
the burden on maintainers.

If you're unfamiliar with the concept of [Conventional Commits][conventional_commits], you can
either:

- Take a moment and [read the official documentation][conventional_commits], or
- Study past commits in this repo, or
- Get going and have the commit linter guide you.

All commits inside merge requests will be linted as part of CI. This means in order for CI to fully
pass, your commits must adhere to our convention. In case the CI fails because of your commit style,
the output of the `commits` CI-job should explain what needs to be done.

Please refrain from making big, monolithic commits that touch unrelated areas of the code. Ideally
your commits introduce fixes/changes/additions in an order that allows each commit to build
individually. Generally speaking, a commit introduces a self-contained piece of code. The
maintainers may ask you to make changes to your commits if they deem you do not entirely satisfy
this convention.

Commit descriptions (as defined by [Conventional Commits][conventional_commits]) should be concise
summaries of the changes being committed. These descriptions will end up in the release Changelog.
As such, try to phrase descriptions in a way that gives casual users an idea of what happened.
Technical aspects and fine details of your changes should generally be part of the commit body.
Commit descriptions are allowed to (over-)simplify things.

Commit bodies (as defined by [Conventional Commits][conventional_commits]) have no size limit and
can generally explain whatever you deem important to understand your changes. If there are external
resources that either help understand your code or that greatly influenced how you wrote the code
(e.g. similar code in other projects, theoretical discussions of algorithms you implemented, ...),
add a link to these resources here. When possible, prefer permanent links (i.e. anything with a
version number in it) in hopes that the link will still be valid in the future. If you explored
different code designs and scratched a few ideas along the way, please explain what those were. It
may help the interested contributor (or maintainer) in the future to make informed decisions about
possible refactorings or extensions. If it makes sense, also explain why a change was necessary. You
shouldn't introduce changes just for the sake of moving code around. If the code was previously
broken, mention this. If you're making the code adhere to some new coding style/lint, mention that,
too. If you're refactoring the code for reasons of improved testing/maintenance/... those are all
perfectly valid explanations, but please mention those.


## Linting the code

This project runs various linters as part of regular CI pipelines. It's not expected that you
install and run all of these linters locally on your machine. Instead, you can use the CI pipeline
to do the linting for you. However, if you feel there is some particular linter you'd like to run
locally for example to fix an especially persistent lint, take a look at the output of the
respective CI job. That should tell you what linter is used in which version.

All linters are configured through their respective configuration files in this repository. If you
feel the need to change any of the pre-configured linter settings, please explain why the change is
necessary in the merge request. Changes to linter settings for no other reason than to make CI pass
in situations where the underlying lint could be fixed will be rejected.


## Testing the code

To run all tests, use:

```bash
bin/make test
```

Ideally your contribution adds new tests to the extent that this is feasible. In case of doubt reach
out to the maintainers and ask whether a test is required.


## Creating merge requests

**TL;DR**:

1. Collect commits dealing with a specific topic on a branch
2. [Create a merge request][j0] with the branch you made previously
3. Choose a title that summarizes all the changes
    - This title helps maintainers categorize the content and scope of your changes
4. Write a description from the users point of view:
    - *Remember: This merge request might be linked in the official Changelog*
    - Give casual users a chance to understand what you did, as if you gave a presentation
    - Explain how fixed bugs affected users before and whether action is required
    - Demonstrate new features, give examples (with screenshots if you like) and highlight
      configuration changes if applicable
    - Mention issues that will be closed by these changes as `Closes: #n`, one per line
5. Add additional comments below the merge request for questions to maintainers, notes to yourself,
   progress reports, ...

**The long version:**

In general, any merge request should deal with a specific, well-defined topic. If you develop some
feature `A` and, while working on that, fix some entirely unrelated bug `B`, please prefer to
open separate merge requests for each of those. This will allow our review to focus on a specific
topic and it also makes sure that, for example, minor fixes aren't pending on review cycles of major
changes.

When [opening a merge request][j0], choose a brief and concise title that summarizes your work. The
description can be as long as you like, and we encourage you to make use of this. The description
should describe what you did from a users point of view. Certain changes may be linked directly from
the release changelog, so you should expect that your text may be read by casual users. Keep this in
mind when describing your changes. If it helps your description, imagine you're giving a brief
presentation to other users of the application.

Any technical details or information such as *this still needs work in the following areas: ...*,
*remaining tasks: ...* or *Open questions: ...* should go into one or more comments under the
description. Rest assured the maintainers will read your entire merge request.

**If you fix a bug**, please explain how the bug affected users and whether they have to change
anything to make use of your fix. You don't have to explain how you fixed the bug as, ideally, this
is already recorded in your commit messages or in comments in the code.

**If you're implementing a feature**, take the time to explain how a user may interact with it. Give
examples of how to use your feature where possible and demonstrate any configuration that may apply.
Give an overview of caveats to be aware of (if any), such as interactions with other existing
features.

If merging your changes fixes any open issues (or supersedes other merge requests), mention this at
the very bottom of your description. If multiple issues are affected, mention each issue on a
separate line like this:

```text
Closes: #3
Closes: #11
```

[j0]: https://docs.gitlab.com/18.4/user/project/merge_requests/creating_merge_requests/


## Interacting with GNU `make`

If you're using the [Containerized setup][ea], all invocations of `make` must be made with
`bin/make`. This ensures that `make` runs inside the development container and has access to the
development environment.

Common targets of interest for developers:

- `all`: The default target, runs various other targets in succession
- `format`: Run automatic code formatting on the code
- `test`: Run all tests
- `example`: Build all documents from the `examples/` subfolder
- `pdf`: Generate user documentation as PDF
- `clean`: Purge temporary files that can easily be reconstructed. External resources, like for
  example anything downloaded from the Internet, are kept. See also `mrproper`.
- `mrproper`: Runs `clean` and removes external resources like downloads from the Internet.
- `changelog` and variants: Refer to [`CHANGELOG.md`][k0] for an explanation.

The [`Makefile`][k1] in this repository defines various targets, not all are listed above. If you
don't want to read the [`Makefile`][k1] to find out which targets exist (beyond what's already
mentioned), you can run the following command to get a list of defined targets:

```bash
bin/make help
```

Please note that this list may be wildly inaccurate and not all targets are meant to be run by
developers. It's highly recommended you consult the [`Makefile`][k1] before you run anything.

[k0]: ./CHANGELOG.md
[k1]: ./Makefile


## Making a release

The process for making a release roughly comes down to this:

1. Figure out what the next version number (`$NEXT_VERSION`) should be. Keep in mind that we strive
   to adhere to [Semantic Versioning][semantic_versioning].
2. Create a branch for the release and preferably name it `release/$NEXT_VERSION`
3. Find all places where the current version is mentioned and update it
    - The documentation under `docs/`
    - The `README.md`, including examples there
    - The typst manifest in `typst.toml`
4. Make a commit, here's an example commit message:
   ```bash
   git commit -eF - <<GITCOMMIT
   build: Bump project version to $NEXT_VERSION

   in preparation for the upcoming release.
   GITCOMMIT
   ```
5. Push the commit and wait for CI to pass. If CI fails, fix mistakes/bugs on the default branch
   (most likely `main`) and rebase the release branch.
6. Create an annotated tag, here's an example tag message:
   ```bash
   git tag -a $NEXT_VERSION -eF - <<GITCOMMIT
   Release Version $NEXT_VERSION

   Enter a release message that gives a high-level overview of this release and potential higlights
   users may be interested in. Don't repeat the changelog here. If there are breaking changes,
   mention what those are and ideally point towards some migration instructions. You can link to
   particularly interesting merge requests if they contain the necessary information.
   GITCOMMIT
   ```
7. Push the tag:
   ```bash
   git push origin tag $NEXT_VERSION
   ```
8. Wait for CI to pass and you're done!

Everything else (building release assets, generating the changelog, ...) happens automatically as
part of the CI pipeline.

If you made changes to the release pipeline or project that may cause breakage, you can make a
pre-release (release candidate). In this case, attach `-rc.1` (increment the `1` if needed) to the
next release version and continue with the steps above as described. If CI passes, you can re-tag
the same commit with the "correct" version number and repeat.


<!-- Shared sources (used in multiple sections) -->
[conventional_commits]: https://www.conventionalcommits.org/en/v1.0.0/
[semantic_versioning]: https://semver.org/spec/v2.0.0.html
<!-- Project-specific sources -->
[open_an_issue]: https://gitlab.com/hartang/typst/cloudy/-/issues/new?type=ISSUE
