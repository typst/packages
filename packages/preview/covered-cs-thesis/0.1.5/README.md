# Computer Science Bachelor or Master Thesis Typst Template for the University Heidelberg

A template for writing a bachelor's or master's computer science thesis at the University Heidelberg.

## Usage

Either initialize the template via
```sh
typst init @preview/covered-cs-thesis:0.1.5
```
Or use the cover function standalone:
```typ
#import "@preview/covered-cs-thesis:0.1.5": *

/// This function creates the a title page that fulfills the requirements
/// that the Institut für Informatik of Heidelberg University has for a bachelor or master thesis.
#cs-thesis-cover(
  /// Your name [string]
  author: "Max Mustermann",
  /// Your matriculation number (Matrikelnummer) [string]
  matriculation-number: "12345678",
  /// What your thesis is (bachelor/master) [string]
  thesis-type: "Bachelor-Arbeit",
  /// The title of your thesis [string]
  title: "What are ducks?",
  /// Your university [string]
  university: "Universität Heidelberg",
  /// Your institute [string]
  institute: "Institut für Informatik",
  /// The working group that supervises your thesis [string]
  working-group: "Duck Feather Laboratory",
  /// Your supervisor [string]
  supervisor: "Professor Einstein",
  /// The date of your submission [anything]
  date-submission: [#datetime.today().display()],
  /// Language of your thesis ["en" OR "de"]
  language: "de",
)
```

## License

This template is licensed under the [Unlicense license](./LICENSE).


## Images

![thumbnail](./thumbnail.png)
