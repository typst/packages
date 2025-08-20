# Bubble
Simple and colorful template for [Typst](https://typst.app). This template uses a main color (default is `#E94845`) applied to list items, links, inline blocks and headings. You can also set a custom table of content title. Every page is numbered and hase the title of the document and the name of the author at the top.

You can see an example PDF [here](https://github.com/hzkonor/bubble-template/blob/main/main.pdf).

## Usage
You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `bubble`.

Alternatively, you can use the CLI to kick this project off using the command

```bash
typst init @preview/bubble
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `bubble` function with the following named arguments:

- `title`: Title of the document
- `subtitle`: Subtitle of the document
- `author`: Name of the author(s)
- `affiliation`: It is supposed to be the name of your university for example
- `year`: The year you're in
- `class`: For which class this document is 
- `date`: Date of the document, current date if none is set *default is current date*
- `logo`: Path of the logo displayed at the top right of the title page, must be set like an image : `image("path-to-img")` *default is none*
- `main-color`: Main color used in the document *default is `#E94645`*
- `alpha`: Percentage of transparency for the bubbles on the title page *default is 60%*

This template also exports these functions : 
- `blockquote` : Function that highlights quotes with a grey bar at the left
- `primary-color` : to use your main color
- `secondary-color` : to use your secondary color (which is your main color with the alpha transparency set)

If you want to change an existing project to use this template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/bubble:0.1.0": *

#show: bubble.with(
  title: "Bubble template",
  subtitle: "Simple and colorful template",
  author: "hzkonor",
  affiliation: "University",
  date: datetime.today().display(),
  year: "Year",
  class: "Class",
  logo: image("logo.png")
) 

// Your content goes here
```