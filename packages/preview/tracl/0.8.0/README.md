# Tracl: ACL Style for Typst

Tracl is an unofficial Typst template for writing papers for the *ACL series of conferences with Typst (ACL, EACL, NAACL, EMNLP, etc.).


It implements the official [ACL paper formatting guidelines](https://acl-org.github.io/ACLPUB/formatting.html) and is modeled after the [LaTeX style](https://github.com/acl-org/acl-style-files). Tracl is the **T**ypst **R**econstruction of the **ACL** style.

Tracl was developed by [Alexander Koller](https://www.coli.uni-saarland.de/~koller/), out of a personal desire to use Typst to write ACL papers. It is not officially supported by ACL, but there is a conversation happening [in a Github thread](https://github.com/acl-org/acl-style-files/issues/58).

## Usage

The usage of the ACL style is documented in [main.pdf](https://github.com/coli-saar/tracl/blob/main/main.pdf).
An example of an accepted EMNLP paper prepared with tracl is [Duchnowski et al. 2025](https://aclanthology.org/2025.findings-emnlp.352/).


## Obtaining the fonts

Tracl uses [TeX Gyre Termes](https://ctan.org/pkg/tex-gyre-termes) as the serif font for the main text (replaces Times), [TeX Gyre Heros](https://ctan.org/pkg/tex-gyre-heros) as the sans-serif font (replaces Helvetica), and [Inconsolata](https://fonts.google.com/specimen/Inconsolata) as the monospace font. TeX Gyre Termes, in particular, is accepted as a replacement for Times by [aclpubcheck](https://github.com/acl-org/aclpubcheck); it is an extended version of [Nimbus Roman No9 L](https://www.fontsquirrel.com/fonts/nimbus-roman-no9-l), the font that LaTeX uses when you import the `times` package.

These fonts are preinstalled in the Typst web app, so you should be able to use tracl out of the box simply by creating a project from the tracl template.

If you want to work offline, you will need to [install the fonts](https://typst.app/docs/reference/text/text/#parameters-font) on your computer. You can obtain the two TeX Gyre fonts from [CTAN](https://ctan.org/pkg/tex-gyre-termes) and Inconsolata from [Google Fonts](https://fonts.google.com/specimen/Inconsolata).

However, note that Typst currently [does not support variable fonts](https://github.com/typst/typst/issues/185). Static versions of TeX Gyre Termes and Heros are in the `opentype` directory of the Zip file you download. A static version of Inconsolata is [available here](https://fontsme.com/inconsolata.font). I recommend that you install these versions of the fonts until variable fonts are supported by Typst.


## Contributors

- Alexander Koller, [@alexanderkoller](https://github.com/alexanderkoller)
- Vilém Zouhar, [@zouharvi](https://github.com/zouharvi)



## Version history

- 2026-01-11 v0.8.0 - better presentation of authors; bump pergamon to 0.7.0; many bugfixes and improvements
- 2025-12-10 v0.7.1 - bumped pergamon dependency to 0.6.0
- 2025-11-01 v0.7.0 - default font now TeX Gyre Termes; use Pergamon for references; compatible with Typst 0.14
- 2025-03-28 v0.6.0 - improved lists and line numbers
- 2025-03-28 v0.5.2 - bumped blinky dependency to 0.2.0
- 2025-03-02 v0.5.1 - fixed font names so as not to overwrite existing Typst symbols
- 2025-02-28 v0.5.0 - adapted to Typst 0.13, released to Typst Universe
- 2025-02-18 v0.4, many small changes and cleanup, and switch to Nimbus fonts
- v0.3.2, ensure page numbers are printed only in anonymous version
- v0.3.1, fixed "locate" deprecation
- v0.3, adjusted some formatting to the ACL style rules
- v0.2, adapted to Typst 0.12


## License information

The ACL style for Typst is distributed under the Apache License 2.0.

The SVG example picture in `pics/spec-paths-cubic01.svg` is (c) 2016 openscad under an MIT License. It comes from [this Github repository](https://github.com/openscad/svg-tests).
