# Touying Slide Theme for Yanshan University

[[中文]](./README.zh.md)

This repository provides a Yanshan University-themed slide template for [Touying](https://touying-typ.github.io/touying/zh/) and Typst.

## Requirements

- Typst `0.14.x`
- `@preview/touying:0.6.3`
- `@preview/cuti:0.4.0`

## Initialize with `typst init`

Once this package is published to Typst Universe, initialize a new deck with:

```bash
typst init @preview/simply-ysu-touying:0.1.0 my-slides
cd my-slides
typst compile main.typ
```

The generated `main.typ` already imports:

```typ
#import "@preview/simply-ysu-touying:0.1.0": *
```

For local testing before the package PR is merged, mirror the published `preview` layout under a local package path and reuse `--package-path`; the exact directory structure is documented in [`docs/typst-packages-pr-structure.md`](./docs/typst-packages-pr-structure.md).

## Quick start

After publication, import the package directly:

```typ
#import "@preview/simply-ysu-touying:0.1.0": *

#show: ysu-theme.with(
  config-info(
    title: [Presentation Title],
    author: [Your Name],
    institution: [Yanshan University],
    date: datetime.today(),
  ),
)

#title-slide()
#outline-slide()
```

To work directly from a cloned repository, import the theme file instead:

```typ
#import "@preview/touying:0.6.3": *
#import "themes/ysu-beamer.typ": *
```

## Compile the repository demo

After cloning this repository, compile the bundled demo with:

```bash
typst compile --root . examples/beamer-ysu.typ
```

## Included files

- `template/main.typ`: template entrypoint used by `typst init`
- `themes/ysu-beamer.typ`: main theme file
- `themes/assets/`: official YSU-inspired visual assets adapted for Typst

Repository demo source:
[`examples/beamer-ysu.typ`](./examples/beamer-ysu.typ)

## Preview

| Cover | Two-column layout |
| --- | --- |
| ![Cover slide preview](https://raw.githubusercontent.com/bahayonghang/simply-ysu-touying/d19fe7c29f10d1b08a1148d4643c12641fa8ea3b/docs/screenshots/beamer-ysu-cover.png) | ![Two-column layout preview](https://raw.githubusercontent.com/bahayonghang/simply-ysu-touying/d19fe7c29f10d1b08a1148d4643c12641fa8ea3b/docs/screenshots/beamer-ysu-two-column.png) |

![Minimal example code slide preview](https://raw.githubusercontent.com/bahayonghang/simply-ysu-touying/d19fe7c29f10d1b08a1148d4643c12641fa8ea3b/docs/screenshots/beamer-ysu-minimal-example.png)

See [`README.zh.md`](./README.zh.md) for the main documentation and the repository demo link above for a complete sample.

## Licensing and Assets

- Theme and library source files are released under the MIT License.
- `LICENSE` preserves both the upstream QuadnucYard notice and the current Geekyhang notice because this repository adapts upstream work while shipping new YSU-specific source files under the same MIT terms.
- The starter content in `template/main.typ` is additionally available under MIT No Attribution; see [`LICENSE-MIT-0.txt`](./LICENSE-MIT-0.txt).
- University-branded assets in `themes/assets/ysu-*` are not covered by the SPDX license expression in `typst.toml`; see [`ASSETS.md`](./ASSETS.md) for the file inventory, source links, transformation notes, and reviewer guidance.

## License

Licensed under the [MIT License](LICENSE).
