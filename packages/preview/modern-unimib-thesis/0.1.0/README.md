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

## Installation

1. Clone this repository:

```bash
git clone https://github.com/michelebanfi/unimib-typst-template.git
cd modern-unimib-thesis
```

2. Make sure you have Typst installed. Visit [Typst's official website](https://typst.app/) for installation instructions.

## Usage

1. Create a new file `thesis.typ` in the project directory.

2. Import the template and configure it with your information:

```typst
#import "@preview/modern-unimib-thesis:0.1.0": template

#template(
  title: "Higher Order Quantum Theory, the \"Double-Ket\" notation",
  candidate:(
    name: "Michelino Banfi",
    number: "869294"
  ),
  date: "2024/2025",
  university: "Universitá degli studi Milano - Bicocca",
  school: "Scuola di Scienze",
  department: "Dipartimento di Fisica",
  course: "Master Degree in Artificial Intelligence for Science and Technology",
  logo: image("logo_unimib.png", width: 30%),
  supervisor: "Prof. Luca Manzi",
  co-supervisor: ("Saira Sanchez", "Prof. Annalisa Di Pasquali")
)

= Introduction

Your thesis content goes here...

= Chapter One

More content...
```

3. Compile your thesis:

```bash
typst compile thesis.typ
```

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
