# dashing-dept-news
A fun newsletter layout for departmental news. The template contains a hero image, a main column, and a margin with secondary articles.

Place content in the sidebar with the `article` function, and use the cool customized `blockquote`s and `figure`s!

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `dashing-dept-news`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/dashing-dept-news
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `newsletter` function with the following named arguments:

- `title`: The newsletter's title as content.
- `edition`: The edition of the newsletter as content or `none`. This is
  displayed at the top of the sidebar.
- `hero-image`: A dictionary with the keys `image` and `caption` or `none`.
  Image is content with the hero image while `caption` is content that is
  displayed to the right of the image.
- `publication-info`: More information about the publication as content or
  `none`. It is displayed at the end of the document.

The function also accepts a single, positional argument for the body of the
newsletter's main column and exports the `article` function accepting a single content argument to
populate the sidebar.

The template will initialize your package with a sample call to the `newsletter`
function in a show rule. If you, however, want to change an existing project to
use this template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/dashing-dept-news:0.1.1": newsletter, article
#show: newsletter.with(
  title: [Chemistry Department],
  edition: [
    March 18th, 2023 \
    Purview College
  ],
  hero-image: (
    image: image("newsletter-cover.jpg"),
    caption: [Award-wining science],
  ),
  publication-info: [
    The Dean of the Department of Chemistry. \
    Purview College, 17 Earlmeyer D, Exampleville, TN 59341. \
    #link("mailto:newsletter@chem.purview.edu")
  ],
)

// Your content goes here. Use `article` to populate the sidebar and `blockquote` for cool pull quotes.
```
