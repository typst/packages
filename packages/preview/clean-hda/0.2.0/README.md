# Clean HDA

A [Typst](https://typst.app/) template for h_da thesis and papers in the department of Computer Sciences.


The template recreates
[mbredel/thesis-template](https://github.com/mbredel/thesis-template) by
forking the the existing template of [DHBW](https://github.com/roland-KA/clean-dhbw-typst-template), which looked the most similar to the
original latex implementation for h_da students.

This is an **unofficial** template for [Hochschule Darmstadt - University of Applied Sciences](https://h-da.de/en/) for the department of Computer Sciences.
Contributions and takeover by h_da affiliated are welcome.

## Getting started

Run the following command in your terminal to create a new project using this template:


Make sure to replace `<version>` with the actual version you want to use, e.g. `0.2.0`.

```console
typst init @preview/clean-hda:<version> MyMasterThesis
```

## Abbreviations

The template includes built-in support for abbreviations using the `abbr` package. You can define your abbreviations in a CSV file and reference them throughout your document.

### Setting up abbreviations

1. Create a CSV file with your abbreviations (e.g., `abbr.csv`) in your project directory:
```csv
PR,Pull Request
MR,Merge Request
K8S,Kubernetes
CI/CD,Continuous Integration/Continuous Deployment
h_da,Hochschule Darmstadt
```

2. Load the abbreviations file in your main document **before** the `show: clean-hda.with(...)` statement:
```typst
#import "@preview/clean-hda:0.2.0": *
#import "@preview/abbr:0.3.0"

// Load abbreviations BEFORE applying the template
#abbr.load("abbr.csv")

#show: clean-hda.with(
  title: "Your Title",
  // ... other configuration ...
  abbr-page-break: false, // optional: set to true to start abbreviations list on new page
)
```

### Using abbreviations in your text

Once loaded, you can use abbreviations in your text. The `abbr` package provides several functions - see the [official documentation](https://typst.app/universe/package/abbr/) for all options:

| Typst Input                                                                                | Rendered Output                                                                                                                                      |
|:-------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------|
| `The @API is widely used. @HTTP is a common protocol. Multiple @API:pla can be combined.`  | The Application Programming Interface (API) is widely used. Hypertext Transfer Protocol (HTTP) is a common protocol. Multiple APIs can be combined.  |

The template will automatically:
- Generate a list of abbreviations in the front matter
- Include the abbreviations list in the Table of Contents
- Apply consistent styling to abbreviation references (blue colored links)
- Support the `abbr-page-break` parameter to control whether the abbreviations list starts on a new page

## Getting started for template development

You may want to follow these steps if you want to contribute to the template itself and make your development easier for fast iteration cycles.

1. Add this as a git submodule
```console
git submodule add https://github.com/stefan-ctrl/clean-hda-typst-template hda_template
```

2. Include as the following in your `main.typst`:

```typst
#import "./hda_template/template/main.typ": *
```

Contributions are welcome.

## Forked from DHBW Template

Please review the original forked documentation for more information, configuration and usage options :
[roland-KA/clean-dhbw-typst-template](https://github.com/roland-KA/clean-dhbw-typst-template)

To see the direct changes compared to the forked project, consider
taking a look at the [CHANGELOG.MD](./CHANGELOG.md).
