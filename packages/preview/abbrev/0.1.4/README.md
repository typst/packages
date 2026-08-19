# Abbrev

A **simple Typst package for creating and managing abbreviations**. While more complex packages exist, this one prioritizes ease of use and adapts to any language (English, French, German, etc.) by letting you customize the abbreviation-list title.

## Installation

### Import from Typst Universe
To import the library from Typst Universe, add this to your document:
```typst
#import "@preview/abbrev:0.1.4": *
```

### Local use
To use the library locally, download `lib.typ` and place it in your document's directory (or any location of your choice). Then, into your document, import all (i.e. `*`) from `lib.typ`.

## Usage

### Step 1: Define abbreviations

Start by defining all your abbreviations in a dictionary:

```typst
#define-abbreviations((
  "GPU": "Graphics Processing Unit",
  "XML": "Extensible Markup Language",
  "CPU": "Central Processing Unit",
))
```

### Step 2: Use abbreviations in your document
- **Short form** (shows the abbreviation):
  ```typst
  #abbr("GPU")
  ```
  Output:

  > GPU

- **Full form** (shows the complete text):
  ```typst
  #abbr("GPU", form: "full")
  ```
  Output:

  > Graphics Processing Unit

- **With a suffix** (e.g., plural):
  ```typst
  #abbr("GPU", suffix: "s")
  ```
  Output:

  > GPUs

### Step 3: Display the abbreviation list
Generate an abbreviation list anywhere in your document:
```typst
#abbreviation-outline(
  title: [Abbreviations],
)
```
Output:

<img width="523" height="86" alt="Example list of abbreviations" src="https://github.com/user-attachments/assets/7f84015f-83c9-40ae-86cf-af7c6bb9132f" />


The default title is "List of abbreviations" — customize it as needed. For example, in French: `title: [Liste des abréviations]`.

### Customizing the abbreviation outline
When no abbreviations are used in the document, the outline displays `[No abbreviations used.]` by default. You can customize this message with the `empty` parameter (which accept a content).

```typst
#abbreviation-outline(
  title: [Abbreviations],
  empty: [Nothing to show.],
)
```
Output:

<img width="153" height="62" alt="Example without abbreviations" src="https://github.com/user-attachments/assets/f1c9038f-8e88-4e57-b9b0-6ca9270f5244" />

You can also customize how your abbreviation definitions are displayed using two parameters:
- `separator`: Controls the spacing between the short and long form of the abbreviation. The default is `[~~]` (two non-breaking space generally produces better results). For example, in French, you might use `[~:~~]` to include a colon with a non-breaking space before it.
- `filler`:  Controls the filler characters displayed between the abbreviation and page number. The default is `repeat([.], gap: 0.15em)`, which creates dots with `0.15em` spacing between them.
```typst
#define-abbreviations((
  "ABBA": "Was a Swedish pop music group formed by Agnetha, Björn, Benny Anni-Frid",
))
#abbreviation-outline(
  title: [Abbreviations],
  separator: [:~~],
  filler: repeat([^], gap: 5pt),
)
= Title
I like #abbr("ABBA"). Do you?
```
Output:

<img width="612" height="112" alt="Example with a different separator and filler" src="https://github.com/user-attachments/assets/16c075de-096a-4429-b60a-529d321237a6" />


The `#abbreviation-outline()` function creates an abbreviation list with a level-1 heading by default that is not numbered and does not appear in the chapter outline. Customize this behavior with the following parameters:

Parameter  | Default |	Purpose
-----------|:-------:|---------
`level`    |   `1`   | Sets the heading level
`numbering`| `none`  | Controls whether the title is numbered
`outlined` | `false` | Controls whether the title appears in the chapter outline

## Example

See `example.typ` for a complete working example. To view the compiled output, choose one of the following:

- Compile with the package: Run `typst compile example.typ` and ensure the import statement is `#import "@preview/abbrev:0.1.4": *`.
- Compile locally: Run `typst compile example.typ` after placing `lib.typ` in the same directory as `example.typ` and updating the import statement to import `lib.typ`.
- Use GitHub Actions: Select the latest passed workflow run and download the `pdf-output` artifact (a ZIP file containing the PDF).
