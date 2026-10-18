# ethz-iis-thesis

ETH Zurich IIS thesis / semester project report template for Typst.

Covers Master Thesis, Bachelor Thesis, Semester Project, and Group Project report types
at the [Integrated Systems Laboratory (IIS)](https://iis.ee.ethz.ch).

## Usage

Initialize a new project with:

```sh
typst init @preview/ethz-iis-thesis
```

Or import directly:

```typst
#import "@preview/ethz-iis-thesis:1.0.0": thesis

#show: thesis.with(
  title: "Title of Your Thesis",
  author: "Student Name",
  email: "student@iis.ee.ethz.ch",
  reporttype: "Master Thesis",
  advisors: (
    (name: "First Supervisor", mail: "first.supervisor@iis.ee.ethz.ch"),
  ),
  professors: (
    (name: "Prof. Dr. P. Professor", mail: "professor@iis.ee.ethz.ch"),
  ),
  abstract: [...],
  bibliography: bibliography("references.bib", style: "ieee"),
)
```

## Third-Party Assets

The ETH Zürich logo (`shared/figures/eth_logo_kurz_pos.svg`) is a trademark of
ETH Zürich and is **not** covered by the Apache-2.0 license. It is reproduced as
publicly available on [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:ETH_Z%C3%BCrich_Logo_black.svg).
Users must comply with [ETH Zürich's branding guidelines](https://ethz.ch/staffnet/en/service/communication/corporate-design/eth-logo.html).

## License

Apache-2.0 — Copyright 2026 ETH Zurich.
