# Tufted

A static website template built using Typst's experimental HTML export. Requires no external dependencies other than basic `make`.

![Tufted website](assets/devices.webp)

## Installation & Usage

Initialize the template from the Typst package registry:

```shell
typst init @preview/tufted:0.1.1
```

To build the website, run:

```shell
make html
```

Explore the `content/` folder for examples.

## Links

- [tufted.vsheg.com](https://tufted.vsheg.com) — live demo and docs of the latest stable version
- [dev.tufted.vsheg.com](https://dev.tufted.vsheg.com) — current dev version
- [Repository on GitHub](https://github.com/vsheg/tufted) — source code, issues, and contributions
- [Typst Universe](https://typst.app/universe/package/tufted) — template page
- [Tufte CSS](https://edwardtufte.github.io/tufte-css/) — used for styling, loaded automatically from a CDN

## License

The source code is available on [GitHub](https://github.com/vsheg/tufted) under the [MIT License](https://github.com/vsheg/tufted/blob/main/LICENSE). The template in the `template/` directory uses the more permissive [MIT-0](https://opensource.org/licenses/MIT-0) license.
