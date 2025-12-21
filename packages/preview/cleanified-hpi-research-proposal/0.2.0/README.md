# Cleanified HPI Research Proposal

A clean-aesthetic template for writing a research proposal.
There are no official guidelines on how to write a research proposal.

## Getting Started

```
typst init @preview/cleanified-hpi-research-proposal:0.2.0
```

## Configuration

An example configuration is located in [`example/`](./example/main.typ).

```typst
#import "@preview/cleanified-hpi-research-proposal:0.2.0": *

#show: project.with(
  title: "My Very Long, Informative, Expressive, and Definitely Fancy Title",
  author: "Max Mustermann",
  date: "Febuary 29, 2025",
  chair: "Data-Intensive Internet Computing",
  additional-logos: (image("path/to/my/logo.png"),),
  enable-hpi-logo: true,
  enable-up-logo: true,
  abstract: [#lorem(100)]
)

= Introduction
#lorem(80)

== Contributions
#lorem(40)

=== Really Small Stuff
#lorem(20)

= Related Work
#lorem(500)
```

**Required parameters**

| Parameter | Type | Usage |
|-----------|------|-------|
| `title` | string | Title of the proposal |
| `author` | string | Author of the proposal |
| `date` | string | Date of the proposal |
| `chair` | string | HPI Chair the proposal is proposed to |

**Optional parameters**

| Parameter | Type | Usage | Default |
|-----------|------|-------|---------|
| `additional-logos` | image array | Further logos on the proposal. Logos listed as images in an array. styling should be evicted. | `()` |
| `hpi-logo-index` | int | Index at which the HPI logo should be displayed. 0 means the HPI logo is the first logo. | `0` |
| `enable-hpi-logo` | boolean | Whether to include the HPI logo in the proposal. | true |
| `enable-up-logo` | boolean | Whether to include the University of Potsdam logo in the proposal. Be reminded that externally published work needs to include HPI and UP logo. | `false` |
| `abstract` | content | The abstract of the work. | `[]` |
| `abstract-formatting` | dictionary | Special formatting for the abstract. Will be applied to a [text function](https://typst.app/docs/reference/text/text/). | ```(fill: rgb("2e2e2e"), style: "italic")``` |
| `enable-toc` | boolean | Whether to include a table of contents in the work. | `true` |
| `double-column` | boolean | Turns the document into double or single-column format. | `false` |

## Copyright Notes

Please note that Hasso Plattner Institute logo is subject to a copyright ([HPI Logo Usage Guidelines](https://hpi.de/en/imprint/)). Same applies for the logo of the University of Potsdam and their [copyright guidelines](https://www.uni-potsdam.de/fileadmin/projects/zim/files/MMP/PDF_Dateien_MMP/250509-Leitfaden_DigitalPrint-web.pdf).

## You like this template? Consider supporting!

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://coff.ee/robert.richter)
