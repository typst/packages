# sunny-orasis
A paper template made for the French national conference **ORASIS**.

The template was made following the official author guidelines, while looking as close as possible to the official LaTeX template.
This should also work for the **RFIAP** and **CAP** conferences.

## Usage

This package is meant to be used as a starting template, with the included `template/main.typ`.

However, you can also import the template using the following line:
```typst
#import "@preview/sunny-orasis:0.1.0": orasis
```
and then create the document in your main file:
```typst
#show: orasis.with(
  
  title: "Mon merveilleux article pour ORASIS",
  
  authors: (
    (name: "M. Oimême", affiliation: "1"),
    (name: "M. Oncopain", affiliation: "2"),
  ),
  
  affiliations: ("Mon Institut", "Son Institut"),
  emails: ("Mon adresse électronique",),
  
  abstract_fr: [
    Ceci est mon résumé pour les journées francophones des jeunes chercheurs en vision par ordinateur (ORASIS). Il doit occuper une dizaine de lignes.
  ],
  keywords_fr: [Exemple type, format, modèle.],
  
  abstract_en: [
    This is the English version of the abstract. Exactly as in French it must be short. It must exhibit the same content...
  ],
  keywords_en: [Example, model, template.],
)
```
And that's it ! You can then simply type your paragraphs using the classic Typst syntax for headings etc.

## Dependencies

This template was tested with Typst 0.12.0