# Atlas Package Cloner

Atlas is a simple package cloner tool. It manages project dependencies in an isolated `deps/` directory.

Atlas is compatible with Nimble in the sense that it supports the Nimble
file format.


## Concepts

Atlas uses two main concepts:

1. Projects
2. Dependencies

### Projects

A project is a directory that has a file `atlas.config` inside it. Use `atlas init`
to create a project out of the current working directory.

Projects can share dependencies and be developed locally by using the `link` command. This creates `nimble-link` files that allow projects to share their dependencies.

The project structure looks like this:

```
  $project / project.nimble
  $project / nim.cfg
  $project / other main project files...
  $project / deps / atlas.config
  $project / deps / dependency-A
  $project / deps / dependency-B
  $project / deps / dependency-C.nimble-link (for linked projects)
```

The deps directory can be set via `--deps:DIR` during `atlas init`.


### Dependencies

Inside a project there is a `deps` directory where your dependencies are kept. It is
easy to move a dependency one level up and out of the `deps` directory, turning it into a project.
Likewise, you can move a project to the `deps` directory, turning it into a dependency.

The only distinction between a project and a dependency is its location. For dependency resolution
a project always has a higher priority than a dependency.


## No magic

Atlas works by managing two files for you, the `project.nimble` file and the `nim.cfg` file. You can
edit these manually too, Atlas doesn't touch what should be left untouched.


## How it works

Atlas uses git commits internally; version requirements are translated
to git commits via git tags and a fallback of searching Nimble file commits.

Atlas uses URLs internally; Nimble package names are translated to URLs
via Nimble's  `packages.json` file. Atlas uses "shortnames" for known URLs from
packages. Unofficial URLs, including forks, using a name triplet of the form
`projectName.author.host`. For example Atlas would be `atlas.nim-lang.github.com`. Packages can be added using `nameOverrides` in `atlas.config` which adds a new name to URL mapping.
Atlas downloads `packages.json` into `deps/_packages` by default; pass
`--packagesGit` to keep the git-clone behavior for the full packages repo.

Atlas does not call the Nim compiler for a build, instead it creates/patches
a `nim.cfg` file for the compiler. For example:

```
############# begin Atlas config section ##########
--noNimblePath
--path:"deps/nimx"
--path:"deps/sdl2/src"
--path:"deps/opengl/src"
--path:"../linked-project/src"
--path:"../linked-project/deps/msgpack4nim/"
############# end Atlas config section   ##########
```

The version selection is deterministic, it picks up the *minimum* required
version. Thanks to this design, lock files are much less important.



## Commands

Atlas supports the following commands:


### Use <url> / <package name>

Clone the package behind `url` or `package name` and its dependencies into
the `deps` directory and make it available for your current project.
Atlas will create or patch the files `$project.nimble` and `nim.cfg` for you so that you can simply
import the required modules.

For example:

```
  mkdir newproject
  cd newproject
  git init
  atlas use lexim
  # add `import lexim` to your example.nim file
  nim c example.nim

```


### Link <path>

Link another project into the current project to share its dependencies. This creates `nimble-link` files that allow the projects to share their dependencies.

For example:

```
  atlas link ../other-project
```

This will link the other project and make its dependencies available to your current project. The other project must be another Atlas project and have a Nimble file.

The linked project will be added to this project's Nimble file if it's not already present.

Note, that the other project's `nameOverrides` and `urlOverrides` *aren't* imported. You may need to import the name-overrides to properly use the deps. This is due to the triplet-naming above.

### Clone/Update <url>/<package name>

Clones a URL and all of its dependencies (recursively) into the project.
Creates or patches a `nim.cfg` file with the required `--path` entries.

**Note**: Due to the used algorithms an `update` is the same as a `clone`.


If a `<package name>` is given instead the name is first translated into an URL
via `packages.json` or via a github search.

## When Statements

When statements provide support for boolean expressions with a subset of compile time defines. The list of defines currently supported: 

  windows, posix, linux, macosx, freebsd, openbsd, netbsd, solaris;
  amd64, x86_64, i386, arm, arm64, mips, powerpc;

If a when statement isn't supported consider using `feature` statements instead.

### Feature Statements

Features in Nimble files enable optional requirements for things different scenarios. This is useful when dealing with scenarios like testing only dependencies.

*Note*: Currently features aren't saved to the Atlas config you must always pass `atlas --feature:foobar` when doing any command. This simplifies configuration and state management in Atlas. It only does what you ask it to do. 

```nim
require "normallib"

feature "testing":
  require "mytestlib"
```

Features are lazily cloned by Atlas until they are specified by either a requires feature or passed from the command line.

In Nimble files you can enable features for a a given package like so:
```nim
require "somelib[testing]"
require "anotherlib[testing, async]"
```


### Search <term term2 term3 ...>

Search the package index `packages.json` for a package that contains the given terms
in its description (or name or list of tags).


### Install <proj.nimble>

Use the .nimble file to setup the project's dependencies.

### UpdateProjects / updateDeps [filter]

Update every project / dependency in the project that has a remote URL that
matches `filter` if a filter is given. The project / dependency is only updated
if there are no uncommitted changes.

### Others

Run `atlas --help` for more features.

### Usage With CI

Atlas works well with CI since deps are installed in the cloned repo. Just cache the `deps/` dir.

Here's a snippet Github Actions YML:

```yml
    ... Nim setup ...

    - name: Install Latest Atlas (recommend until Nim's Atlas verision catches up in 2.2.8+)
      run: |
        nimble install 'https://github.com/nim-lang/atlas@#head'

    - name: Cache packages
      uses: actions/cache@v3
      with:
        path: deps/
        key: ${{ runner.os }}-${{ hashFiles('foo.nimble') }}

    - name: Install Deps
      run: |
        atlas install --feature:test --feature:other # etc
```

## Package Overrides

Sometimes two URLs can conflict for the same dependency shortname. For example, when a project uses a forked dependency with bug fixes. These conflicts need to be manually resolved using `pkgOverrides` in `atlas.config`. The format is package name and the selected URL:

```json
  "pkgOverrides": {
    "asynctools": "https://github.com/timotheecour/asynctools"
  },
```

When a fork is involved, Atlas treats the URL in the dependency graph as canonical and ensures a corresponding git remote exists. It uses `origin` to store the canonical URL and also adds a named remote derived from the repo/author/host (e.g. `repo.user.host`) so it can resolve branch tips and special versions (like `#branch`) against the correct fork while still allowing an “official” remote to coexist for the upstream project.

## Overrides

You can override how Atlas resolves a package name or a URL. The overrides use
a simple pattern matching language and are flexible enough to integrate private
gitlab repositories.

```json
{
  "resolver": "SemVer",
  "nameOverrides": {
    "customProject": "https://gitlab.company.com/customProject"
  },
  "urlOverrides": {
    "https://github.com/araq/ormin": "https://github.com/useMyForkInstead/ormin"
  },
  "plugins": "",
}

```

The `$` has a special meaning in a pattern:

| Syntax             | Meaning
|--------------------|--------------------------------------------------------
|``$$``              |Matches a single dollar sign.
|``$*``              |Matches until the token following the ``$*`` was found.
|                    |The match is allowed to be of 0 length.
|``$+``              |Matches until the token following the ``$+`` was found.
|                    |The match must consist of at least one char.
|``$s``              |Skips optional whitespace.

For example, here is how to override any github link:

```json
  "urlOverrides": {
    "https://github.com/$+": "https://utopia.forall/$#"
  }
```

You can use `$1` or `$#` to refer to captures.


## Virtual Nim environments

Atlas supports setting up a virtual Nim environment via the `env` command. You can
even install multiple different Nim versions into the same project.

For example:

```
atlas env 1.6.12
atlas env devel
```

When completed, run `source nim-1.6.12/activate.sh` on UNIX and `nim-1.6.12/activate.bat` on Windows.


## Dependency resolution

To change the used dependency resolution mechanism, edit the `resolver` value of
your `atlas.config` file. The possible values are:

### MaxVer

The default resolution mechanism is called "MaxVer" where the highest available version is selected
that still fits the requirements.

Suppose you have a dependency called "mylibrary" with the following available versions:
1.0.0, 1.1.0, and 2.0.0. `MaxVer` selects the version 2.0.0.



### SemVer

Adhere to Semantic Versioning (SemVer) by selecting the highest version that satisfies the specified
version range. SemVer follows the format of `MAJOR.MINOR.PATCH`, where:

MAJOR version indicates incompatible changes.

MINOR version indicates backward-compatible new features.

PATCH version indicates backward-compatible bug fixes.

Consider the same "mylibrary" dependency with versions 1.0.0, 1.1.0, and 2.0.0. If you set the
resolver to `SemVer` and specify a version range requirement of `>= 1.0.0`, the highest version
that satisfies the range that does not introduce incompatible changes will be selected. In this
case, the selected version would be 1.1.0.


### MinVer

For the "mylibrary" dependency with versions 1.0.0, 1.1.0, and 2.0.0, if you set the resolver
to `MinVer` and specify multiple minimum versions, the highest version among the minimum
required versions will be selected. For example, if you specify a minimum requirement of
both `>=1.0.0` and `>=2.0.0`, the selected version would be 2.0.0.


## Reproducible builds / lockfiles

Atlas supports lockfiles for reproducible builds via its `pin` and `rep` commands.

**Notice**: Atlas helps with reproducible builds, but it is not a complete solution.
For a truely reproducible build you also need to pin the used C++ compiler, any
third party dependencies ("libc" etc.) and the version of your operating system.


### pin [atlas.lock]

`atlas pin` can be run either in the project or in a specific project. It "pins" the used
repositories to their current commit hashes.
If run in the project the entire project is "pinned" in the `atlas.lock` file.
If run in a project the project's dependencies but not the project itself is "pinned" in the
lock file.

### rep [atlas.lock]

The `rep` command replays or repeats the projects to use the pinned commit hashes. If the
projects have any "build" instructions these are performed too unless the `--noexec` switch
is used.


## Plugins

Atlas operates on a graph of dependencies. A dependency is a git project of a specific commit.
The graph and version selection algorithms are mostly programming language agnostic. Thus it is
easy to integrate foreign projects as dependencies into your project.

This is accomplished by Atlas plugins. A plugin is a NimScript snippet that can call into
external tools via `exec`.

To enable plugins, add the line `plugins="_plugins"` to your `atlas.config` file. Then create
a directory `_plugins` in your project. Every `*.nims` file inside the plugins directory is
integrated into Atlas.


### Builders

A builder is a build tool like `make` or `cmake`. What tool to use is determined by the existence
of certain files in the project's top level directory. For example, a file `CMakeLists.txt`
indicates a `cmake` based build:

```nim

builder "CMakeLists.txt":
  mkDir "build"
  withDir "build":
    exec "cmake .."
    exec "cmake --build . --config Release"

```

Save this as `_plugins/cmake.nims`. Then every dependency that contains a `CMakeLists.txt` file
will be build with `cmake`.

**Note**: To disable any kind of action that might run arbitrary code, use the `--noexec` switch.
