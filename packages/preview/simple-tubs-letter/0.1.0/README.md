# A simple letter template for the Technische Universität Braunschweig

> This project losely follows the [corporate design](https://www.tu-braunschweig.de/presse/corporate-design) of the Technische Universität Braunschweig. You are welcome to contribute to the project for a better match of the original latex templates.

## File structure

```tree
.
├── template
│   ├── assets/figure/tubs
│   │   ├── institute_logo.jpg
│   │   └── tubs_logo.svg
│   ├── letter.typ
│   └── metadata.typ
├── template.typ
├── thumbnail.png
└── typst.toml
```

## Usage

You have to edit the following three files to use this template:

1. `institute_logo.jpg`\
   Replace it with your logo. If you change the file type, you have to edit the file name in `metadata.typ`.
   - You also need to edit the `logo-dx` and `logo-dy` to move the new logo to the correct position.
2. `metadata.typ`\
   This file defines the content of the sidebar and address field.
3. `letter.typ`\
   Here the actual letter is written.

## Development

In case you want to contribute, check out the repo into a [typst package directory](https://github.com/typst/packages?tab=readme-ov-file#local-packages).

```bash
mkdir -p ~/.local/share/typst/packages/local/simple-tubs-letter
cd ~/.local/share/typst/packages/local/simple-tubs-letter
git clone https://github.com/Cangarw/simple-tubs-letter.git
mv simple-tubs-letter 0.1.0
```

## Licence

The licence can be found in COPYING.

## Acknoledgments

Thanks to [Valentin Riess](https://github.com/v411e) and his [optimal-ovgu-thesis](https://github.com/v411e/optimal-ovgu-thesis) which was used as a starting point for this project.
