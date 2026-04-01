# Bananote

This is a template for research notes with Typst. 
It is intended for quickly writing down a research idea,
with a clean visual look that other people will enjoy looking at.

The style has splashes of yellow, inspired by the [Dagstuhl LIPIcs style](https://submission.dagstuhl.de/documentation/authors).


## Usage

Import bananote and populate the header with the title and authors, as follows.

```
#import "@preview/bananote:0.1.0": *

#show: note.with(
  title: [My Research Note],
  authors: (
    ([My Name], [My Affiliation]),
  ),
)

#abstract[
	Here's an abstract.
]

Here's the text of your note.
```

The `authors` field wants an array of authors. Each author can be an array of the form (author, affiliation), or just some content that will be typeset as the author name.

Bananote supports some optional arguments for the `note` function:

- `date`: By default, Bananote prints the compilation date in the top right of the header. You can change the date that should be printed here (as a Typst [datetime](https://typst.app/docs/reference/foundations/datetime/) object), or pass `none` to suppress the date.
- `version`: This will be printed below the date as "Version #version".
- `highlight-by`: Bananote will typeset citations of the authors' own papers in green, rather than blue. More specifically, pass either a string or an array of strings in this argument. Papers will be cited in green if the last name of one of the authors matches one of the strings given to `highlight-by`. By default, no authors will be highlighted.

Bananote comes with a nice configuration of [Pergamon](https://typst.app/universe/package/pergamon). If you import Pergamon, you can use Pergamon's usual citation commands. You can print the bibliography using `print-bananote-bibliography()`.


## Fonts

Bananote typesets headings and the title in [New Computer Modern Sans](https://www.tug.org/FontCatalogue/newcomputermodernsansserif/) if possible, as a callback to the [Koma-Script article classes](https://www.tug.org/FontCatalogue/newcomputermodernsansserif/) in LaTeX. 

New Computer Modern Sans is automatically available in the Typst web app. If you want to use it offline, [download it from here](https://www.ctan.org/tex-archive/fonts/newcomputermodern) and [make it available to Typst](https://typst.app/docs/reference/text/text/#parameters-font).


## Example

<img src="https://github.com/coli-saar/bananote/blob/main/template/thumbnail.png" width=500px border=1px />