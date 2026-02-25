# Tracl: ACL Style for Typst

Tracl is an unofficial Typst template for writing papers for the *ACL series of conferences with Typst (ACL, EACL, NAACL, EMNLP, etc.).


It implements the official [ACL paper formatting guidelines](https://acl-org.github.io/ACLPUB/formatting.html) and is modeled after the [LaTeX style](https://github.com/acl-org/acl-style-files). Tracl is the **T**ypst **R**econstruction of the **ACL** style.

Tracl was developed by [Alexander Koller](https://www.coli.uni-saarland.de/~koller/), out of a personal desire to use Typst to write ACL papers. It is not officially supported by ACL, but it was used to successfully publish [at least one paper](https://aclanthology.org/2025.findings-emnlp.352/).

## Usage

The usage of the ACL style is documented in [main.pdf](https://github.com/coli-saar/tracl/blob/main/main.pdf).
An example of a paper prepared with tracl is [Duchnowski et al. 2025](https://aclanthology.org/2025.findings-emnlp.352/).


## Obtaining the fonts

Tracl uses [TeX Gyre Termes](https://ctan.org/pkg/tex-gyre-termes) as the serif font for the main text (replaces Times), [TeX Gyre Heros](https://ctan.org/pkg/tex-gyre-heros) as the sans-serif font (replaces Helvetica), and [Inconsolata](https://fonts.google.com/specimen/Inconsolata) as the monospace font. TeX Gyre Termes, in particular, is accepted as a replacement for Times by [aclpubcheck](https://github.com/acl-org/aclpubcheck); it is an extended version of [Nimbus Roman No9 L](https://www.fontsquirrel.com/fonts/nimbus-roman-no9-l), the font that LaTeX uses when you import the `times` package.

These fonts are preinstalled in the Typst web app, so you should be able to use tracl out of the box simply by creating a project from the tracl template.

If you want to work offline, you will need to [install the fonts](https://typst.app/docs/reference/text/text/#parameters-font) on your computer. You can obtain the two TeX Gyre fonts from [CTAN](https://ctan.org/pkg/tex-gyre-termes) and Inconsolata from [Google Fonts](https://fonts.google.com/specimen/Inconsolata). All three fonts are distributed under open licenses.

However, note that Typst currently [does not support variable fonts](https://github.com/typst/typst/issues/185). Static versions of TeX Gyre Termes and Heros are in the `opentype` directory of the Zip file you download. A static version of Inconsolata is [available here](https://fontsme.com/inconsolata.font). I recommend that you install these versions of the fonts until variable fonts are supported by Typst.


## License information

The ACL style for Typst is distributed under the Apache License 2.0.

The SVG example picture in `pics/spec-paths-cubic01.svg` is (c) 2016 openscad under an MIT License. It comes from [this Github repository](https://github.com/openscad/svg-tests).
