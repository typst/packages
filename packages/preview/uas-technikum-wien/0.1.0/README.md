# UAS Technikum Wien Thesis Template 

This is an unofficial clone of the original WORD/LaTeX thesis templates that are made available to the students via the Campus Information System. 

## Getting Started

Install the Typst compiler by following the instructions at <https://typst.app/open-source/>.

Once installed, use the following commands.

```bash
typst init @preview/uas-technikum-wien
typst watch thesis.typ
```

Edit and configure the variables in the main file `thesis.typ` (see the comments therein). In particular, you should set the language [de|en], the degree type [Bachelor|Master], the degree program, your name and ID, the name of your advisor and the location. Furthermore, include/edit the contents for the individual sections that shall go to the sub-folder `sections/`. 

NOTE: In rare cases you'll need to change/correct/add something in the style file `styles/uastw_template.typ` - be careful.

## Usage

The template ([rendered PDF](thesis.pdf)) contains usage examples as example content in section 1. More in-depth information is, of course, available via the [Typst Documentation](https://typst.app/docs/).

