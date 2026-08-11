# simple-unimi-thesis 🎓

This template is the conversion from one of the many templates used for UniMi thesis; in particular I looked up to the [LIM LaTeX template](https://www.overleaf.com/project/641879675262cde2a670826b), in Italian.

## Preview ✨

<p align="center">
  <img alt="Frontispiece/First page" src="thumbnail.png" width="45%">
</p>

> [!TIP]
> See the [instructions](https://github.com/VictuarVi/Template-Tesi-UniMi/blob/410379440c495c0b10f4c968bf9686d4cada0869/docs/instructions.pdf) for more information about the template (in Italian).

## Usage 🚀

Compile with con:

```shell
typst c main.typ --pdf-standard a-3b
```

The following excerpt is the canonical example of how the template can be structured:

```typ
#import "@preview/simple-unimi-thesis:0.1.0": *

#show: project.with(
  language: "en",
)

#show: frontmatter

// dedication

#show: acknowledgements

// acknowledgements

#toc // table of contents

#show: mainmatter

// main section of the thesis

#show: appendix

// appendix

#show: backmatter

// bibliography

// associated laboratory
#closingpage("associated_lab")

```

> [!NOTE]
> The default monospace font is [`JetBrainsMono NF`](https://fonts.google.com/specimen/JetBrains+Mono).
