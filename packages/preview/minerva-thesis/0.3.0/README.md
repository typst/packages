
# minerva-thesis

The `minerva-thesis` package provides a template for writing doctoral and master's theses using both generic and [Ghent University](https://www.ugent.be/en) specific functions and features:

- A Ghent University specific title page (optional);
- Multi-language support: The terminology (including terms for "chapter", "part", "section", etc. and various supplements) is pre-defined (and settable) for English and Dutch dissertations, but can be defined for other languages by the user.
- Improved layout of outlines (in particular for outline entries spanning multiple lines);
- Support of Parts, Chapters and Appendices;
- Optional page headers via package [`hydra`](https://typst.app/universe/package/hydra);
- Possibility of left-aligned equations (with a settable left margin);
- Figure and equation numbers including the chapter/appendix number;
- Support of user-defined kinds of figures, next to the standard kinds (`image`, `table` and `raw`), with respect to captions, references and outlines;
- Support of subfigures via package [`subpar`](https://typst.app/universe/package/subpar);
- Optional (short) versions of figure captions for outlines (List of Figures, List of Tables);
- Support of background colour (`fill`) for figures and a `breakable` feature for figures (possible span over multiple pages, *experimental*);
- Automised references to a list or a range of elements, e.g. references to multiple figures: "Figures 1.1, 1.4, and 1.5" or "Figures 1.1-1.3"; 
- Automatic omission of page numbers and headers on blank pages;
- Possibility to include an extended abstract, i.e. an abstract in two-column format;
- Handling of abbreviations via package [`abbr`](https://typst.app/universe/package/abbr);
- Highly-configurable layout (text parameters (font, size, weight, etc.) and functions (smallcaps, etc.), alignment, ...) of chapter titles, headers, captions, etc.


## Usage

For installing the template and compiling the main file (`thesis.typ`) execute:
    
        typst init @preview/minerva-thesis:0.3.0
        cd minerva-thesis
        typst watch thesis.typ
 

 
## Examples

In the folder `examples` of the GitHub Repository [lvandevelde/typst-minerva-thesis](https://github.com/lvandevelde/typst-minerva-thesis/tree/v0.3.0) basic examples of PhD and master's theses are given. 

Theses example files illustrate most of the functions of the package, in particular:

- `thesis.typ`: the main file with settings and imports of all contents (title page, front matter, chapters, appendices and bibliography);
- `Ch1/ch1.typ`: a chapter with tables and figures with extra features (compared to the standard `figure` function);
- `FrontMatter/title-page.typ` (in the PhD thesis example): a tailored title page using the `title-page` function which is specific for Ghent University theses as it uses logos of Ghent University and its faculties. You can modify this function or build your title page manually for usage at other institutions.
- `FrontMatter/extended-abstract.typ` (in the master's thesis example): an extended abstract in double-column format with a separate bibliography


## Functions

The documentation on the functions of this package can be found on the GitHub repository in [`docs/Documentation.md`](https://github.com/lvandevelde/typst-minerva-thesis/blob/v0.3.0/docs/Documentation.md) 
 

## Fonts

In the [examples](#examples) and the template, the lines for selecting the "UGent Panno Text" font have been commented, such that `thesis.typ` can be compiled out-of-the-box. The "UGent Panno Text" font is not a free font and can only be used for Ghent University purposes. For using this font, it has to be installed on your system (with this specific font name).


## License
This template is licensed under the MIT license.
The logos and icons of Ghent University are copyrighted and are not covered by the MIT license. Use them only when there is a direct link to Ghent University. 
