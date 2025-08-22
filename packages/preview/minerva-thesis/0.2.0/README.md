

# minerva-thesis

The `minerva-thesis` package provides a template for writing doctoral and master's theses with [Typst](https://typst.app/) presenting both [Ghent University](https://www.ugent.be/en) specific features and additional generic functions and features (in comparison to standard functions of Typst 0.13):

- A Ghent University specific title page. 
- Improved layout of outlines (in particular for outline entries spanning multiple lines)
- Support of Parts and Appendices
- Figure and equation numbers including the chapter/appendix number
- Omission of page numbers on blank pages before the beginning of a chapter
- Customised captions and references
- Support of subfigures via package [`subpar`](https://typst.app/universe/package/subpar)
- Optional (short) versions of figure captions for outlines (List of Figures, List of Tables)
- Possibility of left-aligned equations (with a settable left margin)
- Possibility to set a background colour (`fill`) for figures and a `breakable` feature for figures (possible span over multiple pages, *experimental*)
- Possibility to include an extended abstract, i.e. an abstract in two-column format with a separate bibliography (via package [`alexandria`](https://typst.app/universe/package/alexandria))
- Handling of abbreviations via package [`abbr`](https://typst.app/universe/package/abbr)


## Usage

For installing the template and compiling the main file (`thesis.typ`) execute:
    
        typst init @preview/minerva-thesis:0.2.0
        cd minerva-thesis
        typst watch thesis.typ
 

 
## Examples

In the folder `examples` of the GitHub Repository [lvandevelde/typst-minerva-thesis](https://github.com/lvandevelde/typst-minerva-thesis) basic examples of a PhD and a master's thesis are given. 

Theses example files illustrate most of the functions of the package, in particular:

- `thesis.typ`: the main file with settings and imports of all contents (title page, front matter, chapters, appendices and bibliography);
- `Ch1/ch1.typ`: a chapter with tables and figures with extra features (compared to the standard `figure` function);
- `FrontMatter/title-page.typ` (in the PhD thesis example): a tailored title page using the `title-page` function which is specific for Ghent University theses as it uses logos of Ghent University and its faculties. You can modify this function or build your title page manually for usage at other institutions.
- `FrontMatter/extended-abstract.typ` (in the master's thesis example): an extended abstract in double-column format with a separate bibliography


## Functions

The documentation on the functions of this package can be found in [`docs/Documentation.md`](https://github.com/lvandevelde/typst-minerva-thesis/blob/v0.2.0/docs/Documentation.md) 
 

## Fonts

In the  [examples](#examples) and the template, the lines for selecting the "UGent Panno Text" font have been commented, such that `thesis.typ` can be compiled out-of-the-box. The "UGent Panno Text" font is not a free font and can only be used for Ghent University purposes. For using this font, it has to be installed on your system (with this specific font name).


## License
This template is licensed under the MIT license.
The logos and icons of Ghent University are copyrighted and are not covered by the MIT license. Use them only when there is a direct link to Ghent University. 
