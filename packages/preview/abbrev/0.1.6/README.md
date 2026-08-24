# Abbrev

A **simple Typst package for creating and managing abbreviations**. While more complex packages exist, this one prioritizes ease of use and adapts to any language (English, French, German, etc.) by allowing you to customize elements such as the abbreviation-list heading.

## Installation

### Import from Typst Universe
To import the library from Typst Universe, add this to your document:
```typst
#import "@preview/abbrev:0.1.6": *
```

### Local use
To use the library locally, download `lib.typ` and place it in your document's directory (or any location of your choice). Then, into your document, import all (i.e. `*`) from `lib.typ`.

## Usage

### Step 1: Define abbreviations

Start by defining all your abbreviations in a dictionary with the `#define-abbreviations()` function. You can call this function multiple times to add new abbreviations, passing a dictionary each time. Each abbreviation must be defined earlier in the document's source code than the point where it is used. Here is an example with two calls:

```typst
#define-abbreviations((
  "GPU": "Graphics Processing Unit",
  "XML": "Extensible Markup Language",
))
#define-abbreviations(("CPU": "Central Processing Unit"))
```

### Step 2: Use abbreviations in your document
- **Short form** (shows the abbreviation):
  ```typst
  #abbr("GPU")
  ```
  Output:

  > GPU

- **Long form** (show the definition):
  ```typst
  #abbr("GPU", form: "long")
  ```
  Output:
  > Graphics Processing Unit

- **Full form** (shows the complete text, long and short forms):
  ```typst
  #abbr("GPU", form: "full")
  ```
  Output:

  > Graphics Processing Unit (GPU)

- **With a suffix** (e.g., plural):
  ```typst
  #abbr("GPU", suffix: "s")
  ```
  Output:

  > GPUs
  ```typst
  #abbr("GPU", form: "full", suffix: "s")
  ```
  Output:

  > Graphics Processing Units (GPUs)

- Alternatively, you can specify a **different long form** with the parameter `alt-long`, for example, when translating into another language or using a different plural form:
  ```typst
  #abbr("GPU", form: "full", alt-long: "Unité de traitement graphique")
  ```
  Output:

  > Unité de traitement graphique (GPU)

### Step 3: Display the abbreviation list
Generate an abbreviation list anywhere in your document, even before defining the abbreviations or using them:
```typst
#abbreviation-outline(
  title: [Abbreviations],
)
```
Output:

<img width="523" height="86" alt="Example list of abbreviations" src="https://github.com/user-attachments/assets/7f84015f-83c9-40ae-86cf-af7c6bb9132f" />

### Customizing the abbreviation outline
The default **heading** is `[List of abbreviations]`. Customize it as needed. For example, in French you might use:
```typst
#abbreviation-outline(title: [Liste des abréviations])
```

When **no abbreviations** are used in the document, the outline displays `[No abbreviations used.]` by default. You can customize this message with the parameter `empty` (which accept a content):

```typst
#abbreviation-outline(
  title: [Abbreviations],
  empty: [Nothing to show.],
)
```
Output:

<img width="153" height="62" alt="Example without abbreviations" src="https://github.com/user-attachments/assets/f1c9038f-8e88-4e57-b9b0-6ca9270f5244" />

#### Customizing items in the abbreviation outline

You can also customize how your abbreviation definitions are displayed using these parameters:
- `separator`: Add a content separator immediately after the abbreviation's short form. The default is `[]` . For example, in French, you might use `[~:]` to include a colon with a non-breaking space before it.
- `fill`:  Controls the filler characters displayed between the abbreviation definition and page number. The default is `repeat([.], gap: 0.15em)`, which creates dots with `0.15em` spacing between them.
- `row-gutter`, `column-gutter`: The gaps between rows and columns; `gutter` is a shorthand for setting both to the same value, but does not take precedence over either property. They all default to `auto`, which resolves to `0.65em`.

Here is an example using the parameters listed below:
```typst
#abbreviation-outline(
  title: [Abbreviations],
  separator: [:],
  fill: line(length: 100%, start: (0%, 0.65em)),
  gutter: 1em,
)
#define-abbreviations((
  "ABBA": "a Swedish pop music group formed by Agnetha, Björn, Benny Anni-Frid",
))
= Some title
I like #abbr("ABBA"). Do you?
```
Output:

<img width="609" height="115" alt="Example with a different separator and filler" src="https://github.com/user-attachments/assets/fd149cbd-f048-43b7-9c2e-3e41c5a55855" />


#### Customizing the heading

The `#abbreviation-outline()` function creates an abbreviation list with a level-1 heading by default that is not numbered and does not appear in the chapter outline. Customize this behavior with the following parameters:

Parameter  | Default |	Purpose
-----------|:-------:|---------
`level`    |   `1`   | Sets the heading level
`numbering`| `none`  | Controls whether the heading is numbered. Expects a format string, such as `"1."`
`outlined` | `false` | Controls whether the heading appears in the chapter outline

## Example

See `example.typ` in the [Abbrev GitHub repository](https://github.com/girasole123/Abbrev) for a complete, working example. To view the compiled output, choose one of the following:

- Compile with the package: Run `typst compile example.typ` and ensure the import statement is `#import "@preview/abbrev:0.1.6": *`.
- Compile locally: Run `typst compile example.typ` after placing `lib.typ` in the same directory as `example.typ` and updating the import statement to import `lib.typ`.
- Use GitHub Actions: Select the latest passed workflow run and download the `pdf-output` artifact (a ZIP file containing the PDF).

