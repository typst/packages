# Contributing to Toy CV

Thank you for considering contributing to Toy CV! Contributions are welcome and greatly appreciated. Here are some guidelines to help you get started.

---

## Development Setup

### Pre-requisites

- Ensure you have [Nix](https://nixos.org/download.html) installed.

### Getting Started

Clone the repository:

```bash
git clone https://github.com/toyhugs/toy-cv.git
cd toy-cv
```

Enter the development shell:

```bash
nix develop
```

From https://github.com/typst/packages/blob/main/docs/manifest.md :

- Add a symlink from `$XDG_DATA_HOME/typst/packages/preview` to the preview folder of your fork of this repository (see the documentation on local packages).
  So it should look like this: `$XDG_DATA_HOME/typst/packages/preview/toy-cv/<your-version>` -> `<path-to-your-fork>/toy-cv`.

### Building the Project

First, ensure to lint the project with:

```bash
nix run .#lint
```

Then, you can build the project with:

```bash
nix run .#build
```

---

## How Can You Contribute?

### 1. Reporting Bugs

If you find a bug, please open an issue with the following details:

- A clear and descriptive title.
- Steps to reproduce the issue.
- Expected behavior and actual behavior.
- Any relevant screenshots or error messages.

### 2. Suggesting Features

Have an idea for a new feature? Open an issue with:

- A detailed description of the feature.
- Why it would be useful.
- Any examples or references.

### 3. Improving Documentation

If you notice any errors, inconsistencies, or missing information in the documentation, feel free to submit a pull request with your improvements.

### 4. Submitting Code

If you'd like to contribute code, follow these steps:

1. Fork the repository.
2. Create a new branch for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Open a pull request with a clear description of your changes, why they are needed, and any relevant context.

---

## Licence

By contributing to this project, you agree that your contributions will be licensed under the [MIT License](./LICENSE).
