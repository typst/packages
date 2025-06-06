# The `css-colors` Package
 <!-- markdownlint-disable MD033 -->
<div align="center">Version 0.1.0</div>

Allows CSS/SVG named colors to be used directly in a Typst document.

## Getting Started

These instructions will get you a copy of the project up and running on the Typst web app.

```typ
#import "@preview/css-colors:0.1.0": *

Normal text may be #text(fill: css("crimson"))[colored so.]
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg" alt="">
</picture>

## Installation

Follow these steps to set up your development environment and prepare for contributing to the project:

1. **Typst:**
   Install Typst (version 0.13.0 or higher) using the [official installation instructions](https://github.com/typst/typst?tab=readme-ov-file#installation). Typst is required to work with the core functionality of the project.

1. **Just:**
   Install [Just](https://just.systems/man/en/introduction.html), a handy command runner for executing predefined tasks. You can install it using a package manager or by downloading a pre-built binary. Refer to the [available packages](https://just.systems/man/en/packages.html) for installation instructions specific to your operating system.

1. **tytanic:**
   Install [tytanic](https://tingerrr.github.io/tytanic/index.html), a library essential for testing and working with Typst projects. Use the [quickstart installation guide](https://tingerrr.github.io/tytanic/quickstart/install.html) to get it up and running.

1. **Clone the Repository:**
   Download the project's source code by cloning the repository to your local machine:

    ```bash
    git clone https://github.com/nandac/css-colors.git
    ```

Once you've completed these steps, your development environment will be ready.

### Next Steps

The `css-colors` package source code is located at:

```plaintext
src/css-colors.typ
```

This is where you will make any necessary changes to the module.

### Running Tests

To test the functionality of the module locally, run the predefined test cases using the following command:

```bash
just test
```

Ensure that all tests pass before submitting any changes to maintain the project's integrity.

If you want to test the module with a Typst file, you can install the `css-colors` package locally in the `preview` location by running:

```bash
just install-preview
```

Once installed, you can import the package into your Typst file using the following statement:

```typ
#import "@preview/css-colors:0.1.0": *
```

This setup allows you to experiment with the module in a Typst file before finalizing your changes.

## Usage

The following examples demonstrate the usage of the `css-colors` package in various cases:

```typ
#import "@preview/css-colors:0.1.0": *

#align(center)[
  #polygon.regular(
    fill: css("darkgoldenrod").lighten(60%),
    stroke: (paint: css("darkgoldenrod"), thickness: 4pt, cap: "round"),
    size: 60mm,
    vertices: 6,
  )
]
```

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-2-dark.svg">
  <img src="./thumbnail-2-light.svg" alt="">
</picture>

For more examples, in-depth explanations, and the PDF output, please refer to the project manual.

## Acknowledgments

Special thanks to the Typst community on [Discord](https://discord.com/channels/1054443721975922748/1069937650125000807) for their invaluable assistance and support during the development of this package.
