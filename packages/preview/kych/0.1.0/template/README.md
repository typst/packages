# 跨越晨昏

A static website template built using Typst's experimental HTML export. Requires no external dependencies other than basic `make`.

> **基于** [tufted](https://github.com/vsheg/tufted) (Copyright © 2025 Vsevolod Shegolev, MIT License) 修改而来。

![跨越晨昏 website](assets/devices.webp)

## Installation & Usage

Initialize the template from the Typst package registry:

```shell
typst init @preview/kych:0.1.1
```

To build the website, run: 

```shell
make html
```

Explore the `content/` folder for examples.

## Links

- [Original template (tufted)](https://github.com/vsheg/tufted) — upstream project
- [Repository on GitHub](https://github.com/CrossDark/KYCH) — source code, issues, and contributions
- [Tufte CSS](https://edwardtufte.github.io/tufte-css/) — used for styling, loaded automatically from a CDN

## License

The source code is available on [GitHub](https://github.com/CrossDark/KYCH) under the [MIT License](https://github.com/CrossDark/KYCH/blob/main/LICENSE). The template in the `template/` directory uses the more permissive [MIT-0](https://opensource.org/licenses/MIT-0) license.