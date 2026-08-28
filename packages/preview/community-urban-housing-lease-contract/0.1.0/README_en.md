# Urban Housing Lease Contract Typst Template

A Typst template for urban housing lease contracts.

[中文](./README.md) [English](./README_en.md)

## About

[Typst](https://typst.app/) is a document typesetting system developed in Rust. You can write text documents following Typst syntax rules and compile them into PDF documents. Typst aims to achieve LaTeX-level typesetting quality with Markdown-level simplicity and compilation speed.

This template is a simple and easy-to-use Typst template for urban housing lease contracts, generating standardized housing rental agreement documents.

## Usage

### Local Editing

- Install Typst

If you use the Scoop package manager, simply run:

```sh
scoop install typst
```

- Clone the project

```sh
git clone <repository-url>
cd urban-housing-lease-contract
```

- Edit contract content

Modify the configuration parameters in `template/main.typ`, including house information, lease terms, party A and party B information, etc.

- Compile to PDF

```sh
typst compile template/main.typ
```

## Template Structure

- `src/lib.typ` - Core library functions
- `src/style.typ` - Style configuration
- `template/main.typ` - Contract template example

## Features

- Complete housing lease contract format
- House information management (location, area, layout, renovation, etc.)
- Lease terms configuration (rent, deposit, duration, cost allocation, etc.)
- Party A and Party B information management
- House handover checklist attachment
- Radio buttons, checkboxes, form elements, etc.

## Known Issues

- Spaces and underscores in the contract may need adjustment based on actual requirements
- Some formatting details may need modification according to local housing authority requirements
