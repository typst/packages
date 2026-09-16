# ethz-iis-assignment

ETH Zurich IIS thesis assignment sheet template for Typst.

Used for issuing student thesis and project assignments at the
[Integrated Systems Laboratory (IIS)](https://iis.ee.ethz.ch).

## Usage

Initialize a new project with:

```sh
typst init @preview/ethz-iis-assignment
```

Or import directly:

```typst
#import "@preview/ethz-iis-assignment:1.0.0": assignment

#show: assignment.with(
  projecttype: "master",
  student: "Student Name",
  title: "Master Thesis Title",
  advisors: (
    (name: "First Supervisor", office: "OAT UXX", mail: "first.supervisor@iis.ee.ethz.ch"),
  ),
  professors: (
    (name: "Prof. Dr. P. Professor", mail: "professor@iis.ee.ethz.ch"),
  ),
)
```

Supported `projecttype` values: `"master"`, `"bachelor"`, `"semester"`, `"group"`.

## Third-Party Assets

The ETH Zürich logo (`shared/figures/eth_logo_kurz_pos.svg`) is a trademark of
ETH Zürich and is **not** covered by the Apache-2.0 license. It is reproduced as
publicly available on [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:ETH_Z%C3%BCrich_Logo_black.svg).
Users must comply with [ETH Zürich's branding guidelines](https://ethz.ch/staffnet/en/service/communication/corporate-design/eth-logo.html).

## License

Apache-2.0 — Copyright 2026 ETH Zurich.
