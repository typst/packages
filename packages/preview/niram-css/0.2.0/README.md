# The `niram-css` Package
<!-- markdownlint-disable MD033 -->
<div align="center">Version 0.2.0</div>

`niram-css`[^niram] brings standard CSS color names[^color-keywords] to Typst.

While Typst natively ships with [eighteen predefined colors](https://typst.app/docs/reference/visualize/color/#predefined-colors), using anything outside that set usually means hunting down a hex code. `niram-css` eliminates this friction by giving you access to the standard CSS color names. Instead of writing `#c71585`, you can just write `mediumvioletred`.

**Key features:**

* **Complete CSS Color Support:** Access all 147 standard CSS color names.[^html-table]

* **Flexible Naming Convention:** Write color names in whatever form feels most natural to you. Inputs are automatically normalized, meaning `mediumvioletred`, `medium violet red`, `Medium Violet Red`, `medium-violet-red`, `medium_violet_red`, `mediumVioletRed`, `MediumVioletRed`, `MEDIUM_VIOLET_RED`, and `MEDIUMVIOLETRED` will all resolve to the same color.

[^niram]: In [Tamil](https://en.wikipedia.org/wiki/Tamil_language), _niram_ (நிறம், /n̪ɪrɐm/) means "color"—a fitting name for a coloring package.
[^color-keywords]: While the official W3C specification refers to these as "color keywords," they are almost universally known among web developers as "color names." This documentation uses the common vernacular for readability.
[^html-table]: You may also view these [colors](https://htmlpreview.github.io/?https://github.com/nandac/niram-css/blob/v0.2.0/docs/css-colors-table.html) in a web browser.

## Requirements

This package requires Typst 0.13.0 or higher.

## Getting Started

Import the package at the top of your Typst document:

```typ
#import "@preview/niram-css:0.2.0": *
```

Then, use the `css` function anywhere a color value is expected:

```typ
This is #text(fill: css("mediumvioletred"))[mediumvioletred] text.
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./colored-text-dark.svg">
  <img src="./colored-text-light.svg" alt="Text colored with the CSS color mediumvioletred">
</picture>

That is all it takes to start using CSS color names in your document.

For more examples, please refer to the [official manual](docs/manual.pdf).

## Development

If you wish to contribute to this package, follow the steps below to prepare your development environment. The package source is in `src/lib.typ`.

1. **Typst:** Install Typst (version 0.13.0 or higher) following the [Typst installation guide](https://github.com/typst/typst?tab=readme-ov-file#installation). Typst is the core tool required for this project.

1. **Just:** Install [Just](https://just.systems/man/en/introduction.html), a command runner for executing predefined tasks. Refer to the [available packages](https://just.systems/man/en/packages.html) for installation instructions specific to your operating system.

1. **tytanic:** Install [tytanic](https://tingerrr.github.io/tytanic/index.html), a library essential for testing and working with Typst projects. Use the [quickstart installation guide](https://tingerrr.github.io/tytanic/quickstart/install.html) to get it up and running.

1. **Clone the Repository:** Download the project's source code by cloning the repository to your local machine:

    ```bash
    git clone https://github.com/nandac/niram-css.git
    ```

    Your development environment is now ready.

### Running Tests

To validate the package functionality, execute the following command:

```bash
just test
```

To add a new test case execute:

```bash
tt new <test-case-name>
```

This will create a new folder with the following structure under the `tests` directory:

```bash
├── <test-case-name>
│   ├── .gitignore
│   ├── ref
│   │   └── 1.png
│   └── test.typ
```

You may then write your tests in the `test.typ` file.

For more information on writing tests using tytanic please see this [guide](https://typst-community.github.io/tytanic/guides/tests.html).

Once you have written your test run:

```bash
just update
just test
```

Ensure all tests pass before submitting changes to maintain code quality.

To test the package with an actual Typst file, install the `niram-css` package locally in the `preview` location by running:

```bash
just install-preview
```

Once installed, import it into your Typst file using:

```typ
#import "@preview/niram-css:0.2.0": *
```

This allows experimentation with the package before finalizing updates.

### Releasing a New Version

Follow these steps to release a new version of the package:

1. **Update Version Number:**

   * Increment the major and/or minor version number in all files referencing the old version.

1. **Update CHANGELOG:**

   * Document added features, modifications, and optionally include a migration guide for the new version in `CHANGELOG.md`.
   * Use the guidelines given at [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

1. **Commit Changes:**

   * Push your updates to the repository:

     ```bash
     git add -u
     git commit -m "Bump version and update CHANGELOG"
     git push
     ```

1. **Tag the Release:**

   * Create and push a new tag for the version:

     ```bash
     git tag -a v<version> -m "<release-text>"
     git push --tags origin
     ```

1. **Create a Pull Request:**

    * The release action in GitHub will create a branch in your fork of typst-packages.
    * Use this branch to open a pull request in the main [Typst Packages repository](https://github.com/typst/packages).

## Acknowledgments

Special thanks to the Typst community on [Discord](https://discord.com/channels/1054443721975922748/1069937650125000807) for their invaluable assistance and support during the development of this package.
