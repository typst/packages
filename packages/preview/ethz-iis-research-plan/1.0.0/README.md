# ethz-iis-research-plan

ETH Zurich IIS PhD research plan template for Typst.

Used for the initial research plan that PhD candidates at the
[Integrated Systems Laboratory (IIS)](https://iis.ee.ethz.ch) submit during their first year.

## Usage

Initialize a new project with:

```sh
typst init @preview/ethz-iis-research-plan
```

Or import directly:

```typst
#import "@preview/ethz-iis-research-plan:1.0.0": research-plan

#show: research-plan.with(
  title: "Title of Your Research Plan",
  author: "Jane Doe",
  email: "jdoe@iis.ee.ethz.ch",
  chair:        (name: "Prof. Dr. Chair",      mail: "chair@iis.ee.ethz.ch"),
  supervisor:   (name: "Prof. Dr. Supervisor", mail: "supervisor@iis.ee.ethz.ch"),
  cosupervisor: (name: "Dr. Co-Supervisor",    mail: "cosupervisor@iis.ee.ethz.ch"),
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
