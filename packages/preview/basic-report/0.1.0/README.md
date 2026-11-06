# Basic Report

A [Typst](https://typst.app/home/) template for shorter non-fiction documents like reports, manuals, requirements documentation, student assignments etc. An example document (PDF) that shows how it looks like, can be found [here](https://github.com/roland-KA/basic-report-typst-template/blob/main/template/main.pdf).

The template comes without bells and whistles and consists just of
- a titlepage with
    - logo
    - title & document category
    - info block (date, author, affiliation)
- the TOC 
- and then the contents (with currently three levels of headings)

The TOC uses roman page numbers, the rest of the document arabic numbers.

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `basic-report`.

Alternatively, you can use the CLI to kick this project off using the command

```shell
typst init @preview/basic-report
```

Typst will create a new directory with all the files needed to get you started.

## Fonts

 _**Vollkorn**_ is used for the body text. It's a high quality font for long texts designed by [Friedrich Althausen](http://friedrichalthausen.de/). It was one of the first Google Fonts. But I recommend to download it from the designers [project web page](http://vollkorn-typeface.com/), because that variant has the small caps font included (on [Google Fonts](https://fonts.google.com/specimen/Vollkorn) that's a separate font). 

 In it's current version it's an extensive font with 12 styles as well as true small caps, a variety of localisations, a complete set of figures (proportional/tabular, lining/old style, small caps), many ligatures etc.

 [_**Ubuntu**_](https://design.ubuntu.com/font) is the contrasting companion for headings, labels, the header, the titlepage etc. Designed by [Dalton Maag](https://www.daltonmaag.com/) it adds a contemporary touch with its own personality. Ubuntu is available via [Google Fonts](https://fonts.google.com/specimen/Ubuntu).


## Packages Used

The [Hydra package](https://github.com/tingerrr/hydra) is used to display the current heading within the header.


## Configuration

The template exports one function `basic-report` with the following named parameters:

-  `doc-category (str)`:  The documents category (e.g. "User Manual", "Lab Report", "Monthly Review")
-  `doc-title (str)`: The documents title
-  `author (str)`: The author; if there are several authors, they can just be listed within one string argument.
-  `affiliation (str)`: Organisation/Company etc.
-  `logo (image)`: an `image` (usage: e.g. `image("path/to/image.svg")`)
-  `language (str)`: Language of the document (default is "de")

Have a look at the example file [`main.typ`](https://github.com/roland-KA/basic-report-typst-template/blob/main/template/main.typ) whithin the [`template`](https://github.com/roland-KA/basic-report-typst-template/tree/main/template) directory on how to use the `basic-report`-function with these parameters.