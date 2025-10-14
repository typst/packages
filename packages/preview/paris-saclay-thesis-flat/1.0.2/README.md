# The `paris-saclay-thesis-flat` Typst package

An unofficial, flat-design Typst template for Paris-Saclay University theses

[![Maintenance Level: Actively Maintained](https://badgen.net/badge/Maintenance%20Level/Actively%20Maintained?color=97ca00)](https://gist.github.com/cheerfulstoic/d107229326a01ff0f333a1d3476e068d)

<p align="center">
<img src="https://github.com/sebmestrallet/typst-paris-saclay-thesis-flat/blob/main/thumbnails/p1.png?raw=true" alt="page 1 of an example thesis based on this template" width="49%">
<img src="https://github.com/sebmestrallet/typst-paris-saclay-thesis-flat/blob/main/thumbnails/p2.png?raw=true" alt="page 2 of an example thesis based on this template" width="49%">
</p>

<details>
<summary>About the name</summary>

- `typst-paris-saclay-thesis-flat` is the name of the GitHub repo, `paris-saclay-thesis-flat` is the name of the Typst template
- The Typst template name does not contain `typst`, because it is redundant[^typst_template_naming]
- The Typst template name is not just `paris-saclay-thesis`, because it is not an official template[^typst_template_naming]. I got rid of the ugly white gradients in the vertical banner, so here is a flat-design version (was accepted by the university library for my thesis).

[^typst_template_naming]: https://github.com/typst/packages?tab=readme-ov-file#submission-guidelines

</details>

## Usage

<!-- from https://github.com/typst/templates/tree/main/charged-ieee -->

You can use this template in the [Typst web app](https://typst.app/) by clicking "Start from template" on the dashboard and searching for `paris-saclay-thesis-flat`.

Alternatively, you can use the CLI to kick this project off using the command:
```bash
typst init @preview/paris-saclay-thesis-flat
cd paris-saclay-thesis-flat
```

Then download the _Segoe UI This_ font, e.g. from [here](https://font.download/font/segoe-ui-this), and place the .ttf files e.g. in a `fonts/` subfolder.

If you use the CLI, you must tell the binary where to look for additional fonts with the `--font-path` argument:
```bash
typst watch main.typ --font-path fonts
```

And if you use [VS Code](https://code.visualstudio.com/) and [tinymist](https://github.com/Myriad-Dreamin/tinymist), set `["${workspaceFolder}/fonts"]` for `tinymist.fontPaths` in VS Code settings.

In the web app, [project fonts are automatically discovered](https://typst.app/docs/reference/text/text/#parameters-font).

## Configuration

This template exports the `paris-saclay-thesis` function with the following named arguments:
- `candidate-name`: Name of the PhD candidate [type: content]
- `title-fr`: Thesis title in French [content]
- `title-en`: Translated thesis title, in English [content]
- `keywords-fr`: Keywords of the thesis subject, in French [strings array]
- `keywords-en`: Translated keywords of the thesis subject, in English [strings array]
- `abstract-fr`: Abstract of the thesis, in French [content]
- `abstract-en`: Translated abstract of the thesis, in English [content]
- `NNT`: National thesis number [content]
- `doctoral-school`: Line mentioning the doctoral school [content]
- `doctoral-school-code`: Short code of the doctoral school (usually the acronym) to fetch the right logo [string]
- `specialty`: Line mentioning the specialty [content]
- `graduate-school`: Line mentioning the graduate school [content]
- `university-component`: Line mentioning the university component ("référent") [content]
- `research-unit-and-advisors`: Paragraph mentioning the research unit and the PhD advisors [content]
- `defense-date`: Date of the PhD defense [content]
- `thesis-examiners`: List of thesis examiners [array of dictionaries, each with a `name`, `title` and `status` field, of type content]

Some spacings are adjustable, see [`src/lib.typ`](src/lib.typ) for the complete list of arguments.

The template will initialize your package with a sample call to the `paris-saclay-thesis` function in a show rule. If you want to change an existing project to use this template, you can add a show rule like this at the top of your file:

```typst
#import "@preview/paris-saclay-thesis-flat:1.0.2": paris-saclay-thesis

#show: paris-saclay-thesis.with(
  candidate-name: [Frodon Sacquet],
  title-fr: [Propriétés et conséquences psychiques, magiques et géopoliques du métal Au lorsque forgé en Anneau Unique],
  title-en: [Properties and psychic, magical and geopolitical consequences of Au metal when forged into the One Ring],
  keywords-fr: ("Or", "montagne du Destin", "Magie occulte"),
  keywords-en: ("Gold","Mount Doom", "Occult magic"),
  abstract-fr: lorem(200),
  abstract-en: lorem(200),
  NNT: [1955UPASX000],
  doctoral-school: [École doctorale n°573 : INTERFACES - approches interdisciplinaires,\ fondements, applications et innovation],
  doctoral-school-code: "INTERFACES",
  specialty: [Spécialité de doctorat : Sciences des matériaux],
  graduate-school: [Graduate School : Physique],
  university-component: [Référent : Faculté des sciences d'Orsay],
  research-unit-and-advisors: [
    Thèse préparée dans l'unité de recherche *Fondcombe*,\ sous la direction d'*Elrond*, seigneur de Fondcombe,\ 
    et l'encadrement de *Gandalf*, magicien de l'ordre des Istari.
  ],
  defense-date: [20 octobre 1955],
  thesis-examiners: (
    (
      name: [*Aragorn*],
      title: [Roi du Gondor],
      status: [Président]
    ),
    (
      name: [*Legolas*],
      title: [Prince des Elfes Sylvains],
      status: [Rapporteur &\ Examinateur]
    ),
    (
      name: [*Gimli*],
      title: [Guerrier du royaume d'Erebor],
      status: [Rapporteur &\ Examinateur]
    ),
    (
      name: [*Faramir*],
      title: [Intendant du Gondor],
      status: [Examinateur]
    ),
  ),
)

// Your content goes below.
```

## Resources

- [Official MS Word & LaTeX templates](https://www.universite-paris-saclay.fr/recherche/doctorat-et-hdr/le-guide-de-la-soutenance-de-doctorat#Ressources) from the Paris-Saclay University

# License

[MIT-0](./LICENSE)