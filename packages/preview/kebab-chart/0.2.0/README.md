# Kebab Chart

[![Typst Universe](https://img.shields.io/badge/Typst-Universe-239dad)](https://typst.app/universe/package/kebab-chart/)
[![Repo](https://img.shields.io/badge/GitHub-repo-444)](https://github.com/tguichaoua/kebab-chart)
[![Development version](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fgithub.com%2Ftguichaoua%2Fkebab-chart%2Fraw%2Fmain%2Ftypst.toml&query=package.version&label=main&color=444)](https://github.com/tguichaoua/kebab-chart/tree/main)
[![Manual](https://img.shields.io/badge/docs-manual.pdf-orange)](docs/manual.pdf?raw=true)

Kebab chart is a typst package to display time range chart.

## Examples

Checkout the [repository](https://github.com/tguichaoua/kebab-chart/tree/main/gallery) for the source code of the following examples:

### A simple chart

![simple kebab chart](./gallery/simple.png)

### Product development cycles

![development cycle example](./gallery/development_cycles.png)

## Usage

Here a simple usage:

```typst
#import "@preview/kebab-chart:0.2.0": kebab-chart

#kebab-chart(
  ticks: 5,

  (
    (
      spans: (
        (start: datetime(year: 2025, month: 1, day: 1), end: datetime(year: 2025, month: 1, day: 10)),
        (start: datetime(year: 2025, month: 2, day: 2), end: datetime(year: 2025, month: 2, day: 7)),
      ),
    ),
    (
      spans: (
        (start: datetime(year: 2025, month: 1, day: 7), end: datetime(year: 2025, month: 1, day: 17)),
        (start: datetime(year: 2025, month: 1, day: 28), end: datetime(year: 2025, month: 2, day: 9)),
      ),
    ),
  ),
)
```
