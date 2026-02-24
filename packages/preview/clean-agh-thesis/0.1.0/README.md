# clean-agh-thesis

This unofficial template allows you to create documents following the AGH University of Science and Technology formatting guidelines. It's designed for bachelor's and master's theses, lab reports, and other academic documents at AGH UST.

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `clean-agh-thesis`.

Alternatively, you can use the CLI to start a new project with this template using the command:
```
typst init @preview/clean-agh-thesis
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `agh` function with the following named arguments:

- `titles`: A tuple of strings containing the title in Polish and English.
- `department`: The name of the department/faculty at AGH UST.
- `author`: The name of the document author.
- `supervisor`: The name of the thesis supervisor.
- `course`: The name of the course or degree program.
- `acknowledgements`: A tuple of strings containing acknowledgement text.
- `masters`: Boolean indicating if this is a master's thesis (`true`) or bachelor's thesis (`false`).
- `bibliography`: The result of a call to the `bibliography` function or `none`.

## Example

Here's how to use the template:

```typ
#import "@preview/clean-agh-thesis:0.1.0": agh

#show: agh.with(
  titles: ("Tytuł pracy w języku polskim", "Title in English"),
  department: "Wydział Elektrotechniki, Automatyki, Informatyki i Inżynierii Biomedycznej",
  author: "Jan Kowalski",
  supervisor: "dr hab. inż. Jan Nowak",
  course: "Informatyka i Systemy Inteligentne",
  acknowledgements: (
    "Dziękuję mojemu promotorowi za wsparcie i cenne wskazówki.",
    "Dziękuję rodzinie za cierpliwość i motywację.",
  ),
  masters: false,
  bibliography: bibliography("refs.bib", title: "Bibliografia"),
)

= Wstęp
== Wprowadzenie

Treść pracy...
```

## Structure

The template automatically handles formatting according to AGH standards, including:
- Title pages in Polish and English
- Proper headings and sections formatting
- Bibliography formatting
- Page numbering
- Margins and spacing

You can focus on writing your content while the template takes care of the formatting requirements.