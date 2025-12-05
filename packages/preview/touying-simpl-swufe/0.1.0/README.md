# [English](README.md) | [中文说明](README.zh.md)
# Touying Slide Theme for SWUFE

A Typst version for [SWUFE Beamer template](https://www.overleaf.com/latex/templates/swufe-beamer-theme/hysqbvdbpnsm).

Inspired by [Touying Slide Theme for Beihang University](https://github.com/Coekjan/touying-buaa).

## Quick Start (Official Package)

The fastest way to get started is to use the Typst official package manager:

```console
 $ typst init @preview/touying-simpl-swufe
Successfully created new project from @preview/touying-simpl-swufe:<latest>
To start writing, run:
> cd touying-simpl-swufe
> typst watch main.typ
```

## Installation and Setup (From GitHub)

### Method 1: Direct File Copy

You can directly copy the [`lib.typ`](lib.typ) file to your project root directory. Then import the template at the top of your Typst file.

```typst
#import "/lib.typ": *
```

### Method 2: Local Package Installation

Clone the repository and install it as a local package for use across different projects. Refer to the [Typst documentation](https://github.com/typst/packages/blob/main/README.md):

```bash
git clone https://github.com/leichaol/packages.git {data-dir}/typst/packages/local/touying-simpl-swufe/0.1.0
```

Where `{data-dir}` is:

- Linux: `$XDG_DATA_HOME` or `~/.local/share`
- macOS: `~/Library/Application Support`
- Windows: `%APPDATA%`, i.e., `C:/Users/<username>/AppData/Roaming`

Then use:

```typst
#import "@local/touying-simpl-swufe:0.1.0": *
```

## Examples

![screenshot of the template slide](thumbnail.webp)

See the [`examples`](examples) directory for more details and sample projects.

### Compiling Examples

You can compile the examples locally:

```console
$ typst compile ./examples/main.typ --root .
```

This will generate `./examples/main.pdf`.

## Copyright Disclaimer

The logo in this theme is sourced from [swufe-logo](https://github.com/ChenZhongPu/swufe-logo) by [ChenZhongPu](https://github.com/ChenZhongPu). Thank the author for providing the logo resource.

These logos are the property of Southwestern University of Finance and Economics. Their inclusion here is for academic formatting purposes only and does not imply official endorsement by the university.

The template author does not hold the copyright to these logos and does not claim any rights over them.

For official use or redistribution of the logos, please contact Southwestern University of Finance and Economics directly.

## License

Licensed under the [MIT License](LICENSE).