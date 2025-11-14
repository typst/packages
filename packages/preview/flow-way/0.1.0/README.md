# Flow-Way

Flow-Way is a simple Typst template for creating modern documents, reports and notes with a clean design. 

## Getting Started

You can start using this template using the Typst CLI command:

```bash
typst init @preview/flow-way:0.1.0    
```

This will create a new Typst project with the Flow-Way template. You can then edit the `main.typ` file to customize your document.

Alternatively, you can create a new Typst file and import Flow-Way manually:

```typst
#import "@preview/flow-way:0.1.0": *

#show: flow.with(
  title: "My Document Title",
  subtitle: "An optional subtitle",
  authors: ("Author One", "Author Two"),
  affiliation: "My Company",
  year: 2025,
  logo: image("path/to/logo.png"),
  toc: true,
  toc-depth: 3
)
```

You can view a compiled pdf example of the template [here](https://github.com/fexh10/flow-way/blob/main/template/main.pdf).

## Fonts

This template uses the following open-source fonts:

- **Source Sans Pro** for the body text.
- **Barlow** for headings.
- **CMU Typewriter Text** for inline code and code blocks.

You can download them from [here](https://github.com/fexh10/flow-way/tree/main/fonts).

## Documentation

For detailed instructions on how to use and customize this template, please refer to the [official documentation](https://github.com/fexh10/flow-way/blob/main/docs/docs.pdf).

## Contributing

Contributions are welcome. If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on the [GitHub repository](https://github.com/fexh10/flow-way).

## Local Installation

If you want to install the template locally or contribute to the project, here are some steps to get you started:

- Clone the [repository](https://github.com/fexh10/flow-way).
- Install `typst` (if you haven't already), `tytanic` and `just`.
- Install the required fonts. If you are using Linux, you can run `just install-fonts` to install them automatically.
- Run `just install` to install the template in the `@local` namespace and `just install-preview` to install it in the `@preview` one.