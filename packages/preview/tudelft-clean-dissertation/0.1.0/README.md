# TU Delft Clean Dissertation

Unofficial TU Delft dissertation template. Designed with clean, sans-serif monochrome sensibilities and clear opinionated directory structure. Designed to be used with Git and Inkscape, but these are not essential.

Comes with OFL fonts, a few other assets, and utility scripts.

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `tudelft-clean-dissertation`.

Alternatively (if you use Typst on your local computer), you can use the CLI to kick this project off using the command

```shell
typst init @preview/tudelft-clean-dissertation my_dissertation
```

Typst will create a new directory (`my_dissertation` in this example) with all the files needed to get you started. The README.md file in the new directory will contain most of the instructions on how to use the template.

## Organisation Motivation

Rather than confining the styling to the scope of the package, all styling is included in the template (at `/template/style/`). This approach is chosen because it gives the user the greatest flexibility to make changes, all while keeping everything in a single directory which can be archived with git. This is because reproducibility is prioritised over minimalism. If the template ever evolves to be highly tuned with many rounds of feedback, it may make sense to move the styling into the package instead.

```
.
└── template
    ├── appendix
    │   └── something-for-the-end
    ├── assets
    │   ├── boxes_symbols
    │   ├── cc_symbols
    │   └── tudelft_symbols
    ├── backmatter
    ├── chapters
    │   ├── 01_background
    │   │   └── figures
    │   │       └── figure_1
    │   │           └── panels
    │   └── 02_another_chapter
    │       └── figures
    │           └── figure_1
    │               └── panels
    ├── cover
    ├── embedded-files
    ├── fonts
    │   ├── Atkinson_Hyperlegible
    │   ├── Onest
    │   │   └── static
    │   └── Open_Sans
    │       └── static
    ├── frontmatter
    ├── propositions
    │   └── utils
    ├── style
    └── utils
```


## Contributing

If you find issues, or have improvements to the template (in the form of new features, or cleaner syntax), you can contribute on the repository homepage at [codeberg.org/NemoAndrea/tudelft-clean-dissertation-template](https://codeberg.org/NemoAndrea/tudelft-clean-dissertation-template)

For more general questions with respect to Typst, please consult the [Typst documentation](https://typst.app/docs/), the [Typst book](https://sitandr.github.io/typst-examples-book/book/about.html) or use the [Typst forum](https://forum.typst.app/), where you find a helpful and responsive community.