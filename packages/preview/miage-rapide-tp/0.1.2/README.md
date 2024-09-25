# miage-rapide-tp

Typst template to generate a practical work report for students of the MIAGE (Méthodes Informatiques Appliquées à la Gestion des Entreprises).

## 🧑‍💻 Usage

- Directly from [Typst web app](https://typst.app/) by clicking "Start from template" on the dashboard and searching for `miage-rapide-tp`.

- With CLI:

```
typst init @preview/miage-rapide-tp:{version}
```

## 🚀 Features

- Cover page
- Table of contents (optionnal)
- `question` = automatically generates a question number (optionnal) with the content of the question
- `code-block` = code block with syntax highlighting. You can pass a filepath or code directly to display in the block
- `remarque` = a remark block with content and color

### Cover page

The conf looks like this:

```typ
#let conf(
  subtitle: none,
  authors: (),
  toc: true,
  lang: "fr",
  font: "Satoshi",
  date: none,
  years: (2024, 2025),
  years-label: "Année universitaire",
  title,
  doc,
)
```

### Question

A question can be added like this:

```typ
#question("Une question avec numéro ?")
#question("Une question sans numéro ?", counter: false)
```

The first argument is the question content, and the second (OPTIONAL) is the counter. If `counter` is set to `false`, the question will not be numbered.

### Code-block

To use a `code-block`, you can do as follows :

```typ
#code-block(read("code/main.py"), "py")
#code-block(read("code/example.sql"), "sql", title: "Classic SQL")
```

The first argument is the code to display, the second is the language of the code, and the third is the title of the code block.

### Remarque

To use a `remarque`, you can do as follows :

```typ
#remarque("Ceci est une remarque")
#remarque("Remarque personnalisée", bg-color: olive, text-color: white)
```

You can change the bg-color and text-color of the remark block to match your needs.

## 📝 License

This is MIT licensed.

> Rapide means fast in French. tp is the abbreviation of "travaux pratiques" which means practical work. MIAGE is a French degree in computer science applied to management.
