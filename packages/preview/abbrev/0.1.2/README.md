# Abbrev

A **simple Typst package for creating and managing abbreviations**. While more complex packages exist, this one prioritizes ease of use and adapts to any language (English, French, German, etc.) by letting you customize the abbreviation-list title.

## Installation

### Import from Typst Universe
To import the library from Typst Universe, add this to your document:
```typst
#import "@preview/abbrev:0.1.2": *
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

<img width="616" height="96" alt="Example list of abbreviations" src="https://github.com/user-attachments/assets/c5994568-d17a-4822-b2ef-40180fc0c601" />

The default title is "List of abbreviations" — customize it as needed. For example, in French: `title: [Liste des abréviations]`.

## Example

See `example.typ` for a complete working example. To view the compiled output, choose one of the following:

- Compile with the package: Run `typst compile example.typ` and ensure the import statement is `#import "@preview/abbrev:0.1.2": *`.
- Compile locally: Run `typst compile example.typ` after placing `lib.typ` in the same directory as `example.typ` and updating the import statement to import `lib.typ`.
- Use GitHub Actions: Select the latest passed workflow run and download the `pdf-output` artifact (a ZIP file containing the PDF).

