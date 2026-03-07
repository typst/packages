# touying-htwk-stripes

> [!WARNING]
> This theme is **NOT** an official theme of Leipzig University of Applied Sciences (HTWK Leipzig).

**touying-htwk-stripes** is a [Touying](https://github.com/touying-typ/touying) theme for creating presentation slides in [Typst](https://github.com/typst/typst), inspired by the presentation template provided by [Leipzig University of Applied Sciences (HTWK Leipzig)](https://www.htwk-leipzig.de/). It is an **unofficial** theme and it is **NOT** affiliated with the HTWK.

## Example

The [example folder](https://github.com/klnsdr/touying-htwk-stripes/tree/main/example) contains a simple example showcasing the usage of the theme.

![An image of all 6 slides of the example presentation](https://github.com/KlnSdr/touying-htwk-stripes/blob/29130c0550bfb8ede4caf77150fb1be46a506390/assets/exampleSlidesCombined.png)

## Usage

```typst
#import "@preview/touying-htwk-stripes:1.0.0": *

#show: htwk-stripes-theme.with(
  aspect-ratio: "4-3",
  title: [Title],
  subtitle: [Subtitle],
  authors: ("Author A",),
  authors-title-slide:
  [
    Author A
  ],
  date: datetime.today(),
  institution: [HTWK Leipzig],
  logo-institution: image("htwk.png"),
  logo-faculty: image("fim.png"),
)

#htwk-title-slide()

#htwk-outline()

= Example Section Title
== Example Slide
A slide with *important information*.

= Second Section
== First Slide
Hello

== Second Slide
World

#htwk-sources(title: "Bibliography", bibliography(title: none,"sources.bib"))
```

### htwk-stripes-theme

Configures the theme and touying.

Example call:

```typst
#show: htwk-stripes-theme.with(
  aspect-ratio: "4-3",
  font: "Arimo",
  title: [Title],
  subtitle: [Subtitle],
  authors: ("Author A", "Author B", "Author C"),
  authors-title-slide:
  [
    Author A
    #linebreak()
    Author B
    #linebreak()
    Author C
  ],
  custom-date: false,
  date: datetime.today(),
  institution: [University of Example],
  logo-institution: image("assets/uoe.svg"),
  logo-faculty: image("assets/foe.svg"),
  sources-title: "Bibliography"
)
```

| Name                | Description                                                                                                                                                                                                                                                         | Type                    | Default              |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- | -------------------- |
| title               | Sets the title of the presentation. Used on the title slide and in the footer of each slide.                                                                                                                                                                        | `str` \| `content`      | `""`                 |
| subtitle            | Sets the subtitle of the presentation. Used on the title slide and in the footer of each slide. If `subtitle` is set the footer will contain `<title> - <subtitle>`. Otherwise `title`.                                                                             | `str` \| `content`      | `""`                 |
| authors             | A list of authors that is joined with `,` displayed in the footer of each non-title slide.                                                                                                                                                                          | `array<str>`            | `()`                 |
| authors-title-slide | The Content displayed on the title slide to show the authors.                                                                                                                                                                                                       | `content`               | `[]`                 |
| custom-date          | A flag used to indicate if `date` should be interpreted as `datetime` or `content`.                                                                                                                                                                                 | `bool`                  | `false`              |
| date                | The date displayed on the title slide and in the footer of each slide. If `custom-date` is `false` and a valid `datetime` is given the date is displayed as `[d]d. M yyyy` with `M` beeing the german full name of the month. Otherwise it is displayed as provided. | `datetime` \| `content` | `datetime.today()`   |
| institution         | The institution for wich the presenter works.                                                                                                                                                                                                                       | `str` \| `content`      | `""`                 |
| aspect-ratio        | The aspect ratio used for the slides. It is passed unchanged to touying.                                                                                                                                                                                            | `str`                   | `"4-3"`              |
| font                | The font used to display the slide contents and titles, nav bar, etc.                                                                                                                                                                                               | `str`                   | `"Libertinus Serif"` |
| primary-color        | The color used in the stripes, bullet points, bold text and level 3 headings.                                                                                                                                                                                       | `color`                 | `rgb("#009ee3")`     |
| text-color-dark       | The color used to display text like titles, authors, institution and normal content. When setting the color globally outside of the theme only unformatted text on the slides is affected.                                                                          | `color`                 | `rgb("#000000")`     |
| logo-institution     | The logo of the institution for which the presenter works. Is used on the upper left corner of the title slide and in the lower right corner of each slide.                                                                                                         | `content`               | `none`               |
| logo-faculty         | The logo of the faculty the presenter works for. Is used in the upper right corner of the title slide.                                                                                                                                                              | `content`               | `none`               |
| sources-title        | The title of the slide containing the bibliography. If set to the acutal value, the slide will not be part of the navigation in the header.                                                                                                                         | `str`                   | `"Quellen"`          |

### htwk-sources

Displays a slide intended for the bibliography which is not displayed in the navigation in the header.

Example call:

```typst
#htwk-sources(title: "Bibliography")[#bibliography(title: none,"sources.bib")]
```

| Name  | Description                                         | Type  | Default     |
| ----- | --------------------------------------------------- | ----- | ----------- |
| title | The title of the slide containing the bibliography. | `str` | `"Quellen"` |

### htwk-outline

Displays a slide containing the outline which is not displayed in the navigation in the header. The function internally calls typst's `outline` configured to only show top level headings.

```typst
#htwk-outline(title: "Outline")
```

| Name  | Description                                    | Type  | Default    |
| ----- | ---------------------------------------------- | ----- | ---------- |
| title | The title of the slide containing the outline. | `str` | `"Inhalt"` |

### htwk-title-slide

Displays the title slide containing information passed to the `htwk-stripes-theme` function. Uses: `logoInstitution`, `logoFaculty`, `title`, `subtitle`, `date`, `authors-title-slide` and `institution`.

Example call:

```typst
#htwk-title-slide()
```
