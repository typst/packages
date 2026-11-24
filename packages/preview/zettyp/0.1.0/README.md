# zettyp

The Typst package for [ZetTypst](https://github.com/project-zettypst/zettypst), providing knowledge semantics, a default notebook implementation, and interfaces for external tools.

- [core](core/): Graph and state descriptions, policy composition, and observations
- [kickstart](kickstart/): Default notebook functions and an editable example template
- [host](host/): File operation plans executed by external tools
- [lsp](lsp/): Typst interfaces for selected language server capabilities
- [site](site/): Site publication interfaces and HTML rendering support

```typst
#import "@preview/zettyp:0.1.0": core, host, kickstart, lsp, site
```

Start a notebook with the included template:

```sh
typst init @preview/zettyp:0.1.0 my-notes
cd my-notes
typst compile index.typ
```

For a notebook with an Astro site, use [Grove](https://github.com/project-zettypst/grove).

[MIT](LICENSE).
