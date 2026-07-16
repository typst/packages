# 04 Developer Experience

The goal of this plan is to improve the developer experience. Namely,

- Add a mise task to install the current package locally
- Add a mise task to bundle the package

## Install package locally

The command should run as `mise run install` and ensure that the current version (see `typst.toml`) is installed. Therefore it should be possible to `#import "@preview/prinzipien:VERSION": *`. Equivalently after `mise run install` it should be possible to compile `examples/demo.typ` and `examples/full-demo.typ`.

## Bundle

The command should run as `mise run bundle` and create the follwing structure: `packages/preview/prinzipien/VERSION` with the current version only.

The bundler should only include those files which are not on the `exclude` list of `typst.toml`, or if they are on the `exclude` list they should be referenced by any file which is included. This should be solved by iteratively using `ripgrep`.

## Guidelines

Create mise tasks by adding to mise.toml. An example:

```toml
[tasks.bundle]
description = "Bundle package for release"
tools = { "aqua:BurntSushi/ripgrep": "latest" }
sources = ...
outputs = ...
run = ...
```

See <https://mise.jdx.dev/tasks/task-configuration.html> for the full specification.
