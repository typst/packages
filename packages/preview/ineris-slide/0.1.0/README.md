# Ineris-slide
This is a Typst template to help formatting slideshows according to the design guidelines of the French institute for industrial environment and risks (Ineris).

## Usage
You can use the CLI to kick this project off using the command
```
typst init @preview/ineris-slide
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template uses [Touying](https://touying-typ.github.io/) to generate the slideshow. To use it, add the following lines at the beginning of your Typst file:

```typ
#import "@preview/touying:0.6.1": *
#import "@preview/ineris-slide:0.1.0": *

#show: ineris-slideshow.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title of your document],
    subtitle: [Subtitle of your document],
    author: [Author(s)],
    date: datetime.today(),
  ),
)

// Your content goes below.
```

The `config-info` function may accept the following arguments:

- `title`: The document's title as a string or content.
- `subtitle`: The document's subtitle as a string or content.
- `author`: The document's author(s) as a string or an array.
- `date`: The document's date as a datetime, or auto for the current time.

The Marianne font is only used if already installed on the computer. Otherwise another sans-serif font is used.

## Special blocks
You can use the following special blocks in your file which use the template colors.

- `#styled-table(..args)`: it accepts the same arguments as the Typst `table` command, but the generated table uses the design guidelines (title row with the same background color as the main palette color, line strokes use also the same color).
- `#focus-block(title, ..args)`: the focus block has a title and a content block. A frame and a background color make it stand out from the slide.

## Special slides
Two special slides are provided:

- `#title-slide()`: this draws the title slide of the slideshow, based on elements provided through the `config-info` function
- `#outline-slide()`: this draws the outline (list of headings) on a slide.
- `#matrix-slide(title: [My title], columns: 2, rows: 4, reversed: false)[Content 1][Content 2]...`: the matrix slide is based on a checkerboard with alternating colors. Each successive content blocks fill one of the checkerboard cells.
- `#focus-slide[Content]`: the focus slide only contains a piece of text in a large font and on a coloured background.
