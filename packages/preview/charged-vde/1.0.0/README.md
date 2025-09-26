# Inofficial VDE Template "charged-vde"
This is an unofficial Typst template for a two-column paper from the proceedings
of the german VDE. The word template can be found
[here](https://www.vde-verlag.de/buecher/proceedings/schreibanleitungen.html).

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `charged-vde`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/charged-vde
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `vde` function with the following named arguments:

- `title`: The paper's title as content.
- `authors`: An array of author dictionaries. Each of the author dictionaries
  must have a `name` key and an affiliation id,
- `affiliations`: Here the affiliations can be named.
- `emails`: Here the emails of the corresponding author(s) can be listed
- `lang`: Specify the language, either `en` for English or `de` for German.
- `abstract`: The abstract of the paper will be pasted here.

The body of the paper comes after the `#show` statement in normal typst syntax.

```typ
#import "@preview/charged-vde:1.0.0": charged-vde

#show: charged-vde.with(
  title: [Test],
  authors: (
    (name: "Max Mustermann", affiliation: "1"),
    (name: "Erika Musterfrau", affiliation: "1,2")
  ),
  affiliations: (
    (id: "1", name: "University"),
    (id: "2", name: "Company")
  ),
  email: [{max,erika}\@university.de, erika\@company.de],
  lang: "en",
  abstract: [#lorem(100)],
)

// Your content goes below.

= Introduction <intro>
#lorem(150)

#bibliography("library.bib")

```

# License
"MIT No Attribution" (MIT-0) License