<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->

<a name="readme-top"></a>

<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- [![LinkedIn][linkedin-shield]][linkedin-url] -->

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <!-- <a href="https://github.com/DrakeAxelrod/cvssc">
    <img src="resources/svg/logo.svg" alt="Logo" width="160" height="160">
  </a> -->

<h3 align="center">cvssc</h3>
  <h4 align="center">Common Vulnerability Scoring System Calculator</h4>
  <p align="center">
    The CVSS Typst Library is a <a href="https://github.com/typst/">Typst</a> package designed to facilitate the calculation of Common Vulnerability Scoring System (CVSS) scores for vulnerabilities across multiple versions, including CVSS 2.0, 3.0, 3.1, and 4.0. This library provides developers, security analysts, and researchers with a reliable and efficient toolset for assessing the severity of security vulnerabilities based on the CVSS standards.
    <br />
    <a href="https://github.com/DrakeAxelrod/cvssc"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!-- <a href="https://github.com/DrakeAxelrod/cvssc">View Tests</a>
    · -->
    <a href="https://github.com/DrakeAxelrod/cvssc/issues">Report Bug</a>
    ·
    <a href="https://github.com/DrakeAxelrod/cvssc/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#api-reference">API Reference</a></li>
    <li><a href="#supported-versions">Supported Versions</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

The **cvssc** library provides comprehensive support for calculating CVSS scores across all major versions (2.0, 3.0, 3.1, and 4.0). It includes:

- **Auto-detection** of CVSS version from vector strings
- **Score calculations** with base, temporal, and environmental metrics
- **Visual representations** via radar charts
- **Severity badges** with color-coded display
- **Dictionary and string formats** for flexible input

Based on official specifications from [FIRST.org](https://www.first.org/cvss/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

- [![Typst][Typst]][Typst-url]
- [![Rust][Rust]][Rust-url]
- [![WASM][WASM]][WASM-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

Ensure you have the Typst CLI installed.

### Prerequisites

- typst (see [Typst](https://typst.app/))

### Installation

Import the package in your Typst document:

```typ
#import "@preview/cvssc:0.2.1": *
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->

## Usage

### Quick Start

```typ
#import "@preview/cvssc:0.2.1": *

// Auto-detect version and calculate
#let result = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")

// Display score and severity
Score: #result.overall-score  // 9.8
Severity: #result.severity    // "CRITICAL"

// Show colored badge
#result.badge               // Displays "CRITICAL"
#result.badge-with-score    // Displays "CRITICAL 9.8"

// Display radar chart
#result.graph
```

### Calculation Functions

#### Auto-Detection (Recommended)

The `calc()` function automatically detects the CVSS version:

```typ
// CVSS 2.0
#let r1 = calc("CVSS:2.0/AV:N/AC:L/Au:N/C:P/I:P/A:P")

// CVSS 3.1
#let r2 = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")

// CVSS 4.0
#let r3 = calc("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N")
```

#### Version-Specific Functions

```typ
// CVSS 2.0
#let score = v2("CVSS:2.0/AV:N/AC:L/Au:N/C:C/I:C/A:C")

// CVSS 3.0 or 3.1
#let score = v3("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")

// CVSS 4.0
#let score = v4("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N")
```

### Dictionary Input Format

```typ
#let result = calc((
  version: "3.1",
  metrics: (
    "AV": "N", "AC": "L", "PR": "N", "UI": "N",
    "S": "U", "C": "H", "I": "H", "A": "H"
  )
))
```

### Display Methods

Result objects include built-in display methods:

```typ
#let result = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")

// Badge - severity only (good for inline text)
#result.badge                // CRITICAL

// Badge with score
#result.badge-with-score     // CRITICAL 9.8

// Radar chart visualization
#result.graph
```

### Utility Functions

#### String Conversion

```typ
// Parse CVSS string to dictionary
#let vec = str2vec("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")
// vec.version => "3.1"
// vec.metrics => ("AV": "N", "AC": "L", ...)

// Convert dictionary back to string
#let str = vec2str((
  version: "3.1",
  metrics: ("AV": "N", "AC": "L", "PR": "N", "UI": "N", "S": "U", "C": "H", "I": "H", "A": "H")
))
```

#### Version Detection

```typ
// Extract version from CVSS string
#let version = get-version("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")
// version => "3.1"
```

#### String Utilities

```typ
// Convert camelCase to kebab-case
#kebab-case("helloWorld")        // "hello-world"

// Convert dictionary keys to kebab-case
#kebabify-keys((
  "baseScore": 9.8,
  "overallScore": 9.8
))
// => ("base-score": 9.8, "overall-score": 9.8)
```

### Customization

#### Color Scheme

```typ
// Update severity colors
#set-colors((
  "critical": rgb("#ff0000"),
  "high": rgb("#ff8800"),
  "chart-stroke": rgb("#0000ff")
))
```

### Real-World Examples

#### CVE-2021-44228 (Log4Shell)

```typ
// CVSS 3.1
#let log4shell = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H")
#log4shell.badge-with-score  // CRITICAL 10.0
```

#### CVE-2014-0160 (Heartbleed)

```typ
// CVSS 2.0
#let heartbleed_v2 = calc("CVSS:2.0/AV:N/AC:L/Au:N/C:P/I:N/A:N")
#heartbleed_v2.badge-with-score  // MEDIUM 5.0

// CVSS 3.1
#let heartbleed_v3 = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N")
#heartbleed_v3.badge-with-score  // HIGH 7.5
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- API REFERENCE -->

## API Reference

### Calculation Functions

#### `calc(vec) -> dict`
Calculate CVSS scores with auto-version detection.
- **Input**: String (vector) or dictionary
- **Returns**: Dictionary with scores, severity, metadata, and display methods (`.badge`, `.badge-with-score`, `.graph`)

#### `v2(vec) -> dict`
Calculate CVSS 2.0 scores.
- **Input**: String (vector) or dictionary
- **Returns**: Dictionary with scores and display methods

#### `v3(vec) -> dict`
Calculate CVSS 3.0 or 3.1 scores.
- **Input**: String (vector) or dictionary
- **Returns**: Dictionary with scores and display methods

#### `v4(vec) -> dict`
Calculate CVSS 4.0 scores.
- **Input**: String (vector) or dictionary
- **Returns**: Dictionary with scores and display methods

### Utility Functions

#### `str2vec(s) -> dict`
Parse CVSS string to dictionary with `version` and `metrics` fields.

#### `vec2str(vec) -> string`
Convert CVSS dictionary to string.

#### `get-version(input) -> string`
Extract version from CVSS string.

#### `kebab-case(string) -> string`
Convert camelCase string to kebab-case.

#### `kebabify-keys(input) -> dict`
Convert dictionary keys from camelCase to kebab-case.

### Configuration Functions

#### `set-colors(new-colors) -> none`
Update CVSS color scheme. Accepts dictionary with color keys.

### Return Format

All calculation functions return a dictionary with kebab-case keys:

```typ
(
  version: "3.1",
  base-score: 9.8,
  temporal-score: none,
  environmental-score: none,
  overall-score: 9.8,
  severity: "CRITICAL",
  base-severity: "CRITICAL",
  metrics: ("AV": "N", "AC": "L", ...),
  vector: "CVSS:3.1/...",
  specification-document: "https://...",

  // Display methods
  badge: [content],              // Severity badge only
  badge-with-score: [content],   // Severity badge with score
  graph: [content]               // Radar chart visualization
)
```

CVSS 4.0 also includes:
- `threat-score`: Threat score (if applicable)
- `macro-vector`: 6-digit macro vector string (e.g., "000020")

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- SUPPORTED VERSIONS -->

## Supported Versions

### CVSS 2.0
- **Base Metrics**: AV, AC, Au, C, I, A
- **Temporal Metrics**: E, RL, RC
- **Environmental Metrics**: CDP, TD, CR, IR, AR
- **Severity Ratings**: LOW, MEDIUM, HIGH
- **Format**: `CVSS:2.0/AV:N/AC:L/Au:N/C:P/I:P/A:P`

### CVSS 3.0
- **Base Metrics**: AV, AC, PR, UI, S, C, I, A
- **Temporal Metrics**: E, RL, RC
- **Environmental Metrics**: CR, IR, AR, MAV, MAC, MPR, MUI, MS, MC, MI, MA
- **Severity Ratings**: NONE, LOW, MEDIUM, HIGH, CRITICAL
- **Format**: `CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N`

### CVSS 3.1
- Same as CVSS 3.0 with refined environmental score calculation
- Most widely used version
- **Severity Ratings**: NONE, LOW, MEDIUM, HIGH, CRITICAL
- **Format**: `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N`

### CVSS 4.0
- **Base Metrics**: AV, AC, AT, PR, UI, VC, VI, VA, SC, SI, SA
- **Threat Metrics**: E
- **Environmental Metrics**: CR, IR, AR, MAV, MAC, MAT, MPR, MUI, MVC, MVI, MVA, MSC, MSI, MSA
- **Supplemental Metrics**: S, AU, R, V, RE, U
- Uses macro vector system for scoring
- **Severity Ratings**: NONE, LOW, MEDIUM, HIGH, CRITICAL
- **Format**: `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`

### Severity Ratings

| Score Range | CVSS 2.0 | CVSS 3.x / 4.0 |
|-------------|----------|----------------|
| 0.0         | -        | NONE           |
| 0.1 - 3.9   | LOW      | LOW            |
| 4.0 - 6.9   | MEDIUM   | MEDIUM         |
| 7.0 - 8.9   | HIGH     | HIGH           |
| 9.0 - 10.0  | HIGH     | CRITICAL       |

### Key Differences Between Versions

#### CVSS 2.0 → 3.0
- Added **Scope** metric
- Changed "Authentication" to "Privileges Required"
- Impact values: Partial → Low, Complete → High
- Added **CRITICAL** severity rating
- More granular scoring

#### CVSS 3.0 → 3.1
- Refined environmental score calculation
- One formula difference in Modified Impact calculation
- Otherwise identical

#### CVSS 3.1 → 4.0
- **Revolutionary change**: Macro vector system replaces formulas
- Added **Attack Requirements** (AT)
- Replaced Scope with **Subsequent System** impacts (SC, SI, SA)
- Simplified temporal metrics
- Added supplemental metrics for context
- Equivalent Class (EQ) system for scoring

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

## Roadmap

See the [open issues](https://github.com/DrakeAxelrod/cvssc/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

<!-- <img src="https://avatars.githubusercontent.com/u/51012876?v=4" height="60px" width="60px"></img> -->

Drake Axelrod - [Github Profile](<[https://github/](https://github.com/DrakeAxelrod/)>) - drakeaxelrod@gmail.com

Project Link: [https://github.com/DrakeAxelrod/cvssc](https://github.com/DrakeAxelrod/cvssc)

## Contributors

<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DrakeAxelrod"><img src="https://avatars.githubusercontent.com/u/51012876?s=64" width="64px;" alt="Drake Axelrod"/><br /><sub><b>Drake Axelrod</b></sub></a><br />
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dwbzn"><img src="https://avatars.githubusercontent.com/u/35350794?s=64" width="64px;" alt="dwbzn"/><br /><sub><b>dwbzn</b></sub></a><br />
    </tr>
  </tbody>
</table>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Typst](https://typst.app/)
- [First.org](https://www.first.org)
- [Rust Library - nvd-cvss](https://docs.rs/nvd-cvss)
- [metaeffekt Universal CVSS Calculator](https://github.com/org-metaeffekt/metaeffekt-universal-cvss-calculator)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/DrakeAxelrod/cvssc.svg?style=for-the-badge
[contributors-url]: https://github.com/DrakeAxelrod/cvssc/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/DrakeAxelrod/cvssc.svg?style=for-the-badge
[forks-url]: https://github.com/DrakeAxelrod/cvssc/network/members
[stars-shield]: https://img.shields.io/github/stars/DrakeAxelrod/cvssc.svg?style=for-the-badge
[stars-url]: https://github.com/DrakeAxelrod/cvssc/stargazers
[issues-shield]: https://img.shields.io/github/issues/DrakeAxelrod/cvssc.svg?style=for-the-badge
[issues-url]: https://github.com/DrakeAxelrod/cvssc/issues
[license-shield]: https://img.shields.io/github/license/DrakeAxelrod/cvssc.svg?style=for-the-badge
[license-url]: https://github.com/DrakeAxelrod/cvssc/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/drakeaxelrod
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com
[Typst]: https://img.shields.io/badge/Typst-239dad?style=for-the-badge&logo=typst&logoColor=white
[Typst-url]: https://typst.app/
[Rust]: https://img.shields.io/badge/Rust-b7410e?style=for-the-badge&logo=rust&logoColor=white
[Rust-url]: https://www.rust-lang.org/
[WASM]: https://img.shields.io/badge/WebAssembly-654FF0?style=for-the-badge&logo=webassembly&logoColor=white
[WASM-url]: https://webassembly.org/
