

# minerva-thesis

A template for writing theses following guidelines at [Ghent University](https://www.ugent.be/en) and providing additional features in comparison to standard functions of Typst 0.13:

- Improved layout of outlines (in particular for outline entries spanning multiple lines)
- Support of Parts and Appendices
- Figure and equation numbers including the chapter/appendix number
- Omission of page numbers on blank pages before the beginning of a chapter
- Customised captions and references
- Support of subfigures (via package [subpar](https://typst.app/universe/package/subpar))
- Optional (short) versions of figure captions for outlines (List of Figures, List of Tables)
- Possibility of left-aligned equations (with a settable left margin)
- Possibility to set background colour (`fill`) and `breakable` feature of figures (experimental)

## Usage

For installing the template and compiling the main file (`thesis.typ`) execute:
    
        typst init @preview/minerva-thesis:0.1.3 
        cd minerva-thesis
        typst watch thesis.typ
 


## Example

In the GitHub repository [lvandevelde/typst-minerva-thesis](https://github.com/lvandevelde/typst-minerva-thesis/tree/v0.1.3), a basic example of a PhD thesis is given in the folder `example-preview`. 

The files in this folder illustrate most of the functions of the package, in particular:

- `thesis.typ`: the main file with settings and imports of all contents (title page, front matter, chapters, appendices and bibliography);
- `Ch1/ch1.typ`: the first chapter with tables and figures with extra features (compared to the standard `figure` function;
- `Titlepage/titlepage.typ`: the title page using the `titlepage` function which is specific for Ghent University theses as it uses logos of Ghent University and its faculties for building the title page. You can build your title page manually for usage at other institutions.


## Functions

The documentation on the functions of this package can be found in [`Documentation.md`](https://github.com/lvandevelde/typst-minerva-thesis/blob/v0.1.3/Documentation.md) 
 

## Fonts

In the [example](#example) and the template, the lines for selecting the "UGent Panno Text" font have been commented, such that `thesis.typ` can be compiled out-of-the-box. The "UGent Panno Text" font is not a free font and can only be used for Ghent University purposes. For using this font, it has to be installed on your system (with this specific font name).


## License
This template is licensed under the MIT license.
The logos and icons of Ghent University (stored in folder `img`) are copyrighted and are not covered by the MIT license. Use them only when there is a direct link to Ghent University. 
