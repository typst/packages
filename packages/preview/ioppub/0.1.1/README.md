# IOP Publishing article template

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fmunechika-koyo%2Fioppub%2Frefs%2Ftags%2Fv0.1.1%2Ftypst.toml&query=package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/ioppub)
[![MIT License](https://img.shields.io/badge/License-MIT-forestgreen)](https://github.com/munechika-koyo/ioppub/blob/v0.1.1/LICENSE)

<!-- [![User Manual](https://img.shields.io/badge/doc-.pdf-mediumpurple)](https://github.com/munechika-koyo/ioppub/blob/main/docs/manual.pdf) -->

The `ioppub` package is designed to closely resemble the manuscript used by IOP Publishing for article formatting.
It is not intended for submission, but rather to help authors prepare articles that resemble the final published version.
It mainly serves as a proof of concept, demonstrating that Typst is a viable option for academic writing and scientific publishing.

## Basic usage

This section provides the minimal amount of information to get started with the template.

To use the `ioppub` template, you need to include the following line at the beginning of your `typ` file:

```typ
#import "@preview/ioppub:0.1.1": *
```

### Initializing the template

After importing `ioppub`, you have to initialize the template by a show rule with the `#ioppub()` command. This function takes an optional argument to specify the title of the document.

- `journal`: Dictionary containing the journal information (e.g. `psst`, `ppcf`, etc.).
- `title`: Title of the paper.
- `abstract`: Abstract of the paper.
- `authors`: List of the authors of the paper.
- `institutions`: List of the institutions of the paper.
- `paper-info`: Dictionary containing the paper information (e.g. year, volume, ...).
- `keywords`: List of keywords of the paper.

## Additional features

The `ioppub` template provides additional features to help you format your document properly.

### Appendix

To activate the appendix environment, all you have to do is to place the following command in your document:

```typ
#show: appendix

// Appendix content here
```

## License

MIT licensed
