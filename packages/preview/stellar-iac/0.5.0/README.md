# Typst Template for the International Astronautical Congress (IAC) Manuscript

This is an unofficial Typst template for the International Astronautical Congress (IAC) manuscript, which is based on [the 74th IAC Manuscript Guidelines (PDF file)](https://www.iafastro.org/assets/files/IAC%202023%20Manuscript%20Guidelines.pdf) and [the Manuscript Template and Style Guide (MS Word file)](https://www.iafastro.org/assets/files/IAC%202023_Manuscript-Template.doc).

## Usage

To initialize a project with this template, run the following command:

```bash
typst init @preview/stellar-iac
```

Or, you can manually add the following line at the beginning of your Typst file:

```typst
#import "@preview/stellar-iac:0.5.0": project
```

The `project` function exported by this template has the following named arguments:

- `paper-code` (default: `""`): The paper code of the manuscript.
- `title` (default: `""`): The title of the manuscript.
- `authors` (default: `()`): The authors of the manuscript. Each item in the array should be a dictionary with the following keys:
  - `name` (required): The name of the author.
  - `email` (required): The email address of the author.
  - `affiliation` (required): The affiliation of the author. The value must match one of the affiliation names defined in the `organizations` argument.
  - `corresponding` (default: `false`): Whether the author is the corresponding author.
- `organizations` (default: `()`): The organizations of the authors. Each item in the array should be a dictionary with the following keys:
  - `name` (required): The name of the organization. This name should be used in the `affiliation` field of the `authors` argument.
  - `display` (required): The display name of the organization, including its address.
- `keywords` (default: `()`): The keywords of the manuscript.
- `header` (default: `[]`): The header of the manuscript. For IAC 2024, it should be `[75#super[th] International Astronautical Congress (IAC), Milan, Italy, 14-18 October 2024.\ Copyright #{sym.copyright}2024 by the International Astronautical Federation (IAF). All rights reserved.]`.
- `abstract` (default: `""`): The abstract of the manuscript.

See [`main.typ`](template/main.typ) for more details.

## Notable differences from the official template

- The citation style is not exactly the same as the official template. This could be fixed by manually preparing a CSL file, but it is "good enough."

## Directory Structure and Licensing

- The `lib.typ` file and all other files in this package, except for the content in the `template` directory, are licensed under the MIT License. See [LICENSE-MIT.txt](./LICENSE-MIT.txt) for details.

- The content in the `template` directory is licensed under the MIT-0 License, which allows for unlimited reuse without any restrictions. See [LICENSE-MIT-0.txt](./LICENSE-MIT-0.txt) for more information.

- The `reproduction` directory is included in this repository to demonstrate how the Typst template in `lib.typ` can be used to reproduce a layout similar to [the original MS Word template](https://www.iafastro.org/assets/files/IAC%202023_Manuscript-Template.doc) copyrighted by the International Astronautical Federation (IAF). **This content is not part of the distributed package and is provided here solely for demonstration purposes.** It is not licensed for use, modification, or distribution without permission from the copyright holder.
