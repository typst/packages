# Modern UNIMIB Thesis

A modern thesis template for University of Milano-Bicocca (UNIMIB) students using the [Typst](https://typst.app/) typesetting system.

## Features

- Clean, modern design
- Simple configuration
- Support for multiple supervisors
- Customizable cover page with university logo
- Written in Typst (a modern alternative to LaTeX)

## Requirements

- Typst (v0.3.0 or newer)

## Getting Started

You can use this template in the Typst web app by clicking “Start from template” on the dashboard and searching for `modern-unimib-thesis`.

Alternatively, you can use the CLI to kick this project off using the command

```
typst init @preview/modern-unimib-thesis
```

Typst will create a new directory with all the files needed to get you started.

## Customization

The template accepts the following parameters:

- `title`: The title of your thesis
- `candidate`: A dictionary containing `name` and `number` (matriculation number)
- `supervisor`: Name of your primary supervisor
- `co-supervisor`: Array of names of co-supervisors
- `department`: Your department name
- `university`: University name
- `school`: School or faculty name
- `course`: Degree program name
- `date`: Academic year
- `logo`: University logo (as an image, PDF not supported as stated by the Typst documentation)

## License

MIT License

## Logo License

Read the [UNIMIB logo usage guidelines](https://www.unimib.it/sites/default/files/Redazione_web/policy.pdf) before using the UNIMIB logo.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
