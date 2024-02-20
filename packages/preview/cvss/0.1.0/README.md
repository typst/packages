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
  <!-- <a href="https://github.com/DrakeAxelrod/cvss.typ">
    <img src="resources/svg/logo.svg" alt="Logo" width="160" height="160">
  </a> -->

<h3 align="center">cvss.typ</h3>

  <p align="center">
    The CVSS Typst Library is a <a href="https://github.com/typst/">Typst</a> package designed to facilitate the calculation of Common Vulnerability Scoring System (CVSS) scores for vulnerabilities across multiple versions, including CVSS 2.0, 3.0, 3.1, and 4.0. This library provides developers, security analysts, and researchers with a reliable and efficient toolset for assessing the severity of security vulnerabilities based on the CVSS standards.
    <br />
    <a href="https://github.com/DrakeAxelrod/cvss.typ"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <!-- <a href="https://github.com/DrakeAxelrod/cvss.typ">View Tests</a>
    · -->
    <a href="https://github.com/DrakeAxelrod/cvss.typ/issues">Report Bug</a>
    ·
    <a href="https://github.com/DrakeAxelrod/cvss.typ/issues">Request Feature</a>
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
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

```typ
#import "@preview/cvss:0.1.0": score, severity, parse, re, NONE, LOW, MEDIUM, HIGH, CRITICAL;

#score("CVSS:2.0/AV:L/AC:H/Au:M/C:P/I:C/A:C") // => 5.6
#severity("CVSS:2.0/AV:L/AC:H/Au:M/C:P/I:C/A:C") // => "Medium"

#score("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H") // => 9.8
#severity("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H") // => "Critical"

#score("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H") // => 8.6
#severity("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H") // => "High"

#score("CVSS:4.0/AV:A/AC:H/AT:P/PR:L/UI:P/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L") // => 5.3
#severity("CVSS:4.0/AV:A/AC:H/AT:P/PR:L/UI:P/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L") // => "Medium"
```

<!-- Here's a blank template to get started: To avoid retyping too much info. Do a search and replace with your text editor for the following: `github_username`, `repo_name`, `twitter_handle`, `linkedin_username`, `email_client`, `email`, `project_title`, `project_description` -->

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

- [![Typst][Typst]][Typst-url]
- [![Rust][Rust]][Rust-url]
- [![WASM][WASM]][WASM-url]
<!-- - [![React][React.js]][React-url]
- [![Vue][Vue.js]][Vue-url]
- [![Angular][Angular.io]][Angular-url]
- [![Svelte][Svelte.dev]][Svelte-url]
- [![Laravel][Laravel.com]][Laravel-url]
- [![Bootstrap][Bootstrap.com]][Bootstrap-url]
- [![JQuery][JQuery.com]][JQuery-url] -->

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

<!-- This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps. -->

Ensure you have the Typst CLI installed.

1. Import the package

```typ
#import "@preview/cvss:0.1.0";
```

2. Use the various library functions to calculate CVSS scores and severities.

```typ
#import "@preview/cvss:0.1.0";

#cvss.score("CVSS:2.0/AV:L/AC:H/Au:M/C:P/I:C/A:C") // => 5.6
#cvss.severity("CVSS:2.0/AV:L/AC:H/Au:M/C:P/I:C/A:C") // => "Medium"

#cvss.score("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H") // => 9.8
#cvss.severity("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H") // => "Critical"

#cvss.score("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H") // => 8.6
#cvss.severity("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H") // => "High"

#cvss.score("CVSS:4.0/AV:A/AC:H/AT:P/PR:L/UI:P/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L") // => 5.3
#cvss.severity("CVSS:4.0/AV:A/AC:H/AT:P/PR:L/UI:P/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L") // => "Medium"
```

3. the library has pseudo constants for the various severity levels.

```typ
#cvss.NONE => "None"
#cvss.LOW => "Low"
#cvss.MEDIUM => "Medium"
#cvss.HIGH => "High"
#cvss.CRITICAL => "Critical"
```

4. The library also provides a `parse` function to parse a CVSS string into a structured object.

```typ
#cvss.parse("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H")
// (
//  score: 8.6,
//  severity: "High",
//  metrics: (
//     AV: "N",
//     AC: "L",
//     PR: "N",
//     UI: "N",
//     S: "U",
//     C: "L",
//     I: "L",
//     A: "H"
//     version: "3.1"
//   )
// )
```

all functions / variables contained in the library are the following:

- `score` - a function that takes a CVSS string and returns the CVSS score as a float.
- `severity` - a function that takes a CVSS string and returns the CVSS severity as a string.
- `metrics` - a function that takes a CVSS string and returns the CVSS metrics as a structured object.
- `parse` - a function that takes a CVSS string and returns a structured object containing the CVSS score, severity, and metrics.
- `verify` - a function that takes a CVSS string and returns a boolean indicating whether the string is a valid CVSS string.
- `NONE` - a pseudo constant representing the "None" severity level.
- `LOW` - a pseudo constant representing the "Low" severity level.
- `MEDIUM` - a pseudo constant representing the "Medium" severity level.
- `HIGH` - a pseudo constant representing the "High" severity level.
- `CRITICAL` - a pseudo constant representing the "Critical" severity level.
- `re` - a regular expression object used to parse CVSS strings.

### Prerequisites

This is an example of how to list things you need to use the software and how to install them.

- typst (see [Typst](https://typst.app/))

<!-- ### Installation -->

<!-- 1. Get a free API Key at [https://example.com](https://example.com)
2. Clone the repo
   ```sh
   git clone https://github.com/DrakeAxelrod/cvss.typ.git
   ```
3. Install NPM packages
   ```sh
   npm install
   ```
4. Enter your API in `config.js`
   ```js
   const API_KEY = "ENTER YOUR API"
   ``` -->

<!-- <p align="right">(<a href="#readme-top">back to top</a>)</p> -->

<!-- USAGE EXAMPLES -->

## Usage

Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources.

_For more examples, please refer to the [Examples](./src/examples.pdf)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

## Roadmap

<!--
- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3
  - [ ] Nested Feature
-->

See the [open issues](https://github.com/DrakeAxelrod/cvss.typ/issues) for a full list of proposed features (and known issues).

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

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

<!-- <img src="https://avatars.githubusercontent.com/u/51012876?v=4" height="60px" width="60px"></img> -->

Drake Axelrod - [Github Profile](<[https://github/](https://github.com/DrakeAxelrod/)>) - drakeaxelrod@gmail.com

Project Link: [https://github.com/DrakeAxelrod/cvss.typ](https://github.com/DrakeAxelrod/cvss.typ)

## Contributors

<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DrakeAxelrod"><img src="https://avatars.githubusercontent.com/u/51012876?v=4?s=64" width="64px;" alt="Drake Axelrod"/><br /><sub><b>Drake Axelrod</b></sub></a><br />
    </tr>
  </tbody>
</table>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Typst](https://typst.app/)
- [First.org](https://www.first.org)
- [Rust Library - cvss_tools](https://docs.rs/cvss_tools)
- [Rust Library - cvssrust](https://docs.rs/cvssrust/latest/cvssrust/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/DrakeAxelrod/cvss.typ.svg?style=for-the-badge
[contributors-url]: https://github.com/DrakeAxelrod/cvss.typ/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/DrakeAxelrod/cvss.typ.svg?style=for-the-badge
[forks-url]: https://github.com/DrakeAxelrod/cvss.typ/network/members
[stars-shield]: https://img.shields.io/github/stars/DrakeAxelrod/cvss.typ.svg?style=for-the-badge
[stars-url]: https://github.com/DrakeAxelrod/cvss.typ/stargazers
[issues-shield]: https://img.shields.io/github/issues/DrakeAxelrod/cvss.typ.svg?style=for-the-badge
[issues-url]: https://github.com/DrakeAxelrod/cvss.typ/issues
[license-shield]: https://img.shields.io/github/license/DrakeAxelrod/cvss.typ.svg?style=for-the-badge
[license-url]: https://github.com/DrakeAxelrod/cvss.typ/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
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
