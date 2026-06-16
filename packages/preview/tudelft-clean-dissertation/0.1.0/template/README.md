# Unofficial dissertation template for TU Delft

This directory contains the recommended structure and styling for a dissertation at the TU Delft. This is an unofficial template. Fixes, reworks, and improvements are welcome.

### Software requirements

The scripts and utilties in this template assume a UNIX working environment. If you are using windows, you may need to change a few scripts around or use WSL. Make sure the software below is installed on your system.

* Typst (compiling document)
* Inkscape (figure design)
* Git (versioning)

Versioning your dissertation with git is fast and easy. Please use it to keep a reproducible copy of your dissertation available for others.

### Files to add to template

Some things to consider before starting:

1. What licence will you choose for your dissertation? Add the legal text of the license to [LICENSE](LICENSE) and update [metadata.toml](metadata.toml).
2. Do you want to include the propositions in this repository? If you prefer to keep them separate, I would suggest moving the [propositions](propositions) directory to another location. If you want to keep it linked, but separate, consider adding your propositions as a git submodule.
3. You will need to design a cover for your dissertation. While you do not need to include the cover in the digital version of the dissertation, it would be shame to omit the design you used for the printed copies. This creates the dilemma that you need to have 2 versions of the thesis: one to send to the printer (without the cover) and one for the repository for people to read (with the cover). You can compile the version for print by adding the typst compile flag `--input forprint=`. Without the flag it will include the cover in the output pdf. See also [utils/compile_thesis_for_print.sh](utils/compile_thesis_for_print.sh). Note that everything assumes that your cover design is present as `/cover/cover-frontside.pdf` and `/cover/cover-backside.pdf`.
4. Rather than including pages of python code, consider embedding/attaching files directly in the pdf. Have a look at the contents of [/embedded-files/README.md](embedded-files/README.md) for more information. If you do not plan on using the feature, remove that directory. 
5. You may wish to include appendices in your dissertation. These are located in [/appendix/](appendix/). They will be rendered after backmatter, but before the acknowledgements. If you do not plan on adding appendices, remove that directory.

### Chapter Structure

Each chapter should have its own directory in [chapters/](chapters/). Each chapter should have its own `figures` directory. See the next section for a recommendation about structure for that. The chapter directory should also contain a `literature.bib` to include references for that chapter. If you prefer to work with a single large `.bib` file that is also an option. I suggest putting that under `chapters/references.bib` in that case. Each chapter should also include a `main.typ` file, which includes the central content of the chapter. When practical, I suggest spinning out large chunks of the chapter into separate files. For example, you might want to put the supplementary material into `supplementary.typ` and the introduction in `introduction.typ`. The number and name of these side sections is up to you; just make sure you reference them in `main.typ` with

```typst
#include "<separate-file>.typ"
```

Each chapter must also define a reference (i.e. the name you can reference with @name to refer to the chapter), and a sidebar label. Note that this sidebar label must be a very short string, as there is not a lot of vertical space in the thesis. If you really cannot keep it short, you can change the `box_height` in [style/dissertation.typ](/style/dissertation.typ), or leave it empty.

### Figure Structure for Inkscape

You can create figures in whatever software you prefer. I recommend [Inkscape](https://inkscape.org/), and the structure recommendation here is designed for inkscape, but will likely translate well to software like Adobe Illustrator.

Figures will be specified in some source file (`figure-source.svg` for inkscape) and exported to a pdf (`figure.pdf`), which can be imported into Typst. The name of the figure should be generic (i.e. `figure-source.svg` not `fig-spectrum-source.svg`) as the identification is handled by the *directory* that the file is in. Figure 1 will be at [chapters/01_background/figures/**figure_1**/figure-source.svg](chapters/01_background/figures/figure_1/fig-source.svg). This structure is important for some of the scripts.

The figure will consist of sub-panels (multiple images or plots). These should be stored as a subfolder of the figure directory. The images/plots therein should be **linked** in inkscape. That means the image will not be embedded in the inkscape file, but rather inkscape looks up the file every time the document is opened. That way the size of `figure-source.svg` stays small. The output `figure.pdf` should never be added to git; only the files that can be used to reconstruct it (`figure-souce.svg` and panels).

Have a look at the example in [chapters/01_background/figures/figure_1](chapters/01_background/figures/figure_1/)

> [!tip] Tip: decide on a font choice at the start of the figure design phase. 
> Keeping a consistent choice throughout will go a long way to making your dissertation feel cohesive.

### Compiling document

To compile the document, the recommended way is to use the compile_thesis scripts in the `utils/` directory. If you don't want to use the scripts, use the following instead:

In the root directory of the project (the one this markdown document is in) run[^1]:

```
typst compile thesis.typ {--font-path ./fonts --input commit="<first-8-characters-of-current-commit>"}
```

If you want to work in a dynamic way (edit thesis and see updates), run

```
typst watch thesis.typ {--font-path ./fonts --input commit="<first-8-characters-of-current-commit>"}
```

To see the changes reflected live in the pdf, I suggest you download a PDF viewer that supports automatic reloading once it detects the file changes on disk. [SumatraPDF](https://www.sumatrapdfreader.org/free-pdf-reader) seems to work well on Windows, and `evince` works well for linux.

### Modifying the template 

The styling of the document can be done by inline edits (for example changing text colour in a chapter), or by changing the template files, located in the [style/](/style/) directory (and imported through `template.typ`). Under normal conditions, you should not need to touch the files.

If you do find the need to make edits in `style/`, consider if your changes would be welcome additions to the source template. If so, please create a pull request or get in touch to see if your changes can be merged. For fixes to the template, or convenience improvements, help is greatly appreciated. If you are only making changes that are relevant for your particular thesis, then you can leave those contributions limited to your own directory.

The central page for the template is on Codeberg at [codeberg.org/NemoAndrea/tudelft-clean-dissertation-template](https://codeberg.org/NemoAndrea/tudelft-clean-dissertation-template)

### 🛠 Tooling

It is recommend that you use Visual Studio Code with the `typst-lsp` plugin to write your typst source code. Make sure to disable "Export PDF" option in favour of the compilation method listed above. To keep a clean line length in source files, I suggest installing a plugin like `Reflow Paragraph` to easily reflow paragraphs to `~80ch`.

Literature management can easily be managed with [Zotero](https://zotero.org/). Library entries were copied over manually to the `.bib` bibliography files. Configure Zotero to have `BibLaTeX` as the default export format for quick copy (`ctrl` + `shift` + `c`) to make this workflow manageable. 

[^1]: The input commit is optional. It will included as transparent text in the header of the document if you specify it. It is recommended you include it as it allows you to trace back the source and version of stray pdfs.

