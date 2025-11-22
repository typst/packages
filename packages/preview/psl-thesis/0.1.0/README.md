# PSL University PhD thesis template

This is a Typst template for a thesis manuscript at Paris Sciences et Lettres (PSL)
University. Original covers in Word and LaTeX format are available on [PSL's
website](https://psl.eu/formation/choisir-sa-formation/college-doctoral-de-luniversite-psl).
Front and back covers are generated using images by Pierre Guillou, available
[here](https://pierre.guillou.net/psl-cover/2018/). A similar LaTeX template by Arthur
Chavignon is available on 
[Overleaf](https://www.overleaf.com/latex/templates/template-phd-psl-university-paris-sciences-et-lettres/jtntgmybzjxn).

## Usage

You can use this template in the Typst web app by clicking "Start from tempate" on the
dashboard and searching for `psl-thesis`.

Alternatively, you can use the CLI to kick this project off using the command

```bash
typst init @preview/psl-thesis
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `psl-thesis-covers` function with the following named
arguments:

- `title`: The title of the thesis.
- `author`: The author of the thesis.
- `date`: The denfense date.
- `institute`: The institute where the thesis was prepared.
- `institute-logo`: A content (e.g. result of the `image` function) to place in the
  front cover footer, or `none`.
- `doctoral-school`: Dictionnary containing the `name` and `number` of the doctoral
  school.
- `specialty`: The specialty of the thesis.
- `jury`: An array of dictionaries containing the `firstname`, `lastname`, `title` and
  `role` of each jury member.
- `abstracts`: A dictionary containing the thesis abstracts in French and English,
  displayed on the back cover.
- `keywords`: A dictionary containing the thesis keywords in French and English,
  displayed on the back cover.

The function also accepts a single, positional argument for the body of the thesis. The
front cover language can be either French or English, and is set by calling the `text`
function with the `lang` argument before calling `psl-thesis-covers`.

The template will initialize your package with a sample call to the `psl-thesis-covers`
function in a show rule. Example sections and chapter styling are also included. If you
want to use your own thesis layout with only the front and back covers, you can use the
`psl-thesis-covers` function alone:

```typst
#import "@preview/psl-thesis:0.1.0": psl-thesis-covers

// Choose between fr and en to set the front cover language.
#set text(lang: "fr", font: "Montserrat", size: 11pt)

#show: psl-thesis-covers.with(
  title: [Recherches sur les substances radioactives],
  author: [Marie Skłodowska-Curie],
  date: [le 25 juin 1903],
  doctoral-school: (name: [Faculté des sciences], number: [123]),
  institute: [à la Faculté des Sciences de Paris],
  institute-logo: image("./logo-institute.svg", height: 3.5cm),
  specialty: [Sciences Physiques],
  jury: (
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "President",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "Referee",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "Referee",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "MD, PhD, Affiliation",
      role: "Member",
    ),
    (
      firstname: "Name",
      lastname: "Surname",
      title: "PhD, Affiliation",
      role: "PhD supervisor",
    ),
  ),
  abstracts: (fr: lorem(128), en: lorem(128)),
  keywords: (fr: lorem(4), en: lorem(4)),
)

// Your thesis content goes here.
```

