# hpi math homework

A homework template for Hasso Plattner Institute (HPI) math courses, in
German and English. The first page has a framed assignment header. Later pages
show the authors, course, assignment type and page number. [Preview the example sheet (PDF).](template.pdf)

## Start an assignment

Use the CLI commands below with the Universe release or a local installation.
To try the source repository directly, see [Preview a local checkout](#preview-a-local-checkout).

```sh
typst init @preview/hpi-math-homework:0.1.0 homework
cd homework
typst compile main.typ
```

Edit `main.typ` to enter your name, course, tutorial group and week. The
`#show: homework.with(...)` rule applies the layout to the rest of the file.
For example, here is a complete sheet in English.

```typ
#import "@preview/hpi-math-homework:0.1.0": homework, exercise, solution

#show: homework.with(
  names: "Ada Example and Sam Example",
  course: "Discrete Mathematics",
  tutorium: "3",
  week: 2,
  language: "en",
)

#exercise(title: "Subsets")[How many subsets does a three-element set have?]
#solution[Each element can be present or absent, giving $2^3 = 8$ subsets.]
```

## Customize the sheet

- `language` defaults to `"de"`. Set it to `"en"` for English headings and
  labels.
- `type` sets the assignment type in both headers. It defaults to
  “Hausaufgabe” or “Homework”.
- The starter detects the semester automagically. Uncomment that line, to set it manually. Summer
  runs from April through September. Winter runs from October through March.
- `#exercise[...]` starts a numbered exercise. A `title` appears in parentheses
  after the number. Use `#exercise(numbered: false)[...]` for a bonus question
  that leaves the next number available. Put the answer in `#solution[...]`.

## Preview a local checkout

With Typst 0.12 or later on Linux or macOS, run these commands from the
repository root. The temporary package directory lets the starter's import
resolve to this checkout. [Typst's local package guide](https://github.com/typst/packages#local-packages)

```sh
package_dir=$(mktemp -d)
mkdir -p "$package_dir/preview/hpi-math-homework"
ln -s "$PWD" "$package_dir/preview/hpi-math-homework/0.1.0"
typst compile --package-path "$package_dir" template/main.typ homework.pdf
```

## License

The library uses MIT. The editable starter in `template/` uses MIT-0, so you
can distribute your edited assignments without including a license notice.
[Library license](LICENSE) · [Starter license](LICENSE-MIT-0)
