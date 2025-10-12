# touying-criterion

[![Build Document](https://github.com/thy0s/touying-criterion/actions/workflows/build.yml/badge.svg)](https://github.com/thy0s/touying-criterion/actions/workflows/build.yml)
[![Repo](https://badgen.net/static/GitHub/Repo/blue?icon=github)](https://github.com/thy0s/touying-criterion)
[![License](https://badgen.net/static/License/MIT/blue)](https://opensource.org/license/mit)

"Criterion" slide master for the [typst](https://typst.app) presentation package [touying](https://touying-typ.github.io). 

It uses the *Source Sans 3* font as default, which can be downloaded [here](https://api.fontsource.org/v1/download/source-sans-3).


You can either initialize the template in a new folder with:
```bash
typst init @preview/touying-criterion:0.1.0
```

... or import the template to an existing document with:

```typst
#import "@preview/touying-criterion:0.1.0": *
```

## Configuration

Use `#show: touying-criterion.with()` to configure the template as needed.

- `aspect-ratio`: Default is *"16-9"*, alternatively *"4-3"*
- `lang`: The language of the respective presentation (*default "en"*)
- `font`: The font of the presentation (*default "Source Sans 3"*)
- `text-size`: Size of the text content (*default "22pt"*)
- `show-level-one`: (bool) Show section heading on the content slides (*default: true*)
- `footer`: The footer of the content slides (*default: none*)

Other parameters, such as `title`, `subtitle`, `author`, `date` and `institution` are taken from the `config-info` object, which looks as follows: 

```typst
  config-info(
    title: [The "Criterion" slide template],
    subtitle: [Straightforward Presentations],
    author: [thy0s],
    date: datetime.today(),
    institution: [Funk Town State University],
  )
```

## Slide types
- `#outline-slide`: Dedicated outline slide with 2 parameters
    + `depth`: Maximum heading level to display (*default: 2*)
    + `title`: Override the default *"Outline"*, e.g. when using a different language
- `#focus-slide` - High contrast slide with no configuration options

The template also shows a `#new-section-slide` for every level one heading and allows for overriding the default settings of `show-level-one` and `footer` by calling the `#slide` function directly.

## Credit 
Parts of this template were inspired by and taken from the [university theme](https://github.com/touying-typ/touying/blob/main/themes/university.typ) and the [metropolis theme](https://github.com/touying-typ/touying/blob/main/themes/metropolis.typ) aswell as the [clean-math-presentation](https://github.com/JoshuaLampert/clean-math-presentation).

## Contribution
If you have any problems with this template feel free to open an issue. Also, if you have anything usefult to add to this template, you can open a pull request and it will be looked at. 

All constructive contributions are welcome and highly appreciated!

## Examples

### Title Slide
![0](thumbnail.png)

### Outline Slide
![1](https://github.com/thy0s/touying-criterion/blob/assets/images/outline.png)

### Section Slide
![2](https://github.com/thy0s/touying-criterion/blob/assets/images/section_heading.png)

### Content Slide (Without L1 Heading)
![3](https://github.com/thy0s/touying-criterion/blob/assets/images/content.png)

### Content Slide (With L1 Heading)
![6](https://github.com/thy0s/touying-criterion/blob/assets/images/content_l1.png)

### Focus Slide
![5](https://github.com/thy0s/touying-criterion/blob/assets/images/focus.png)
