# ens-internship
An unofficial template for internship reports at ENS Paris-Saclay.

## Usage

```typ
#show: ens-internship.with(
  title: "A simple report template created with Typst",
  subtitle: "Master's degree final-year internship",
  lang: "en",
  authors: ("Author 1", "Author 2"),
  mentors: ("Mentors 1", "Mentors 2"),
  logo: "template/logo.png",
  place: "Place of the intership",
  date: "Beginning date",
  table-of-contents: true,
  bibliography: bibliography("refs.yaml"),
)
```

### Options

| Argument          | Type            | Description                                |
|-------------------|-----------------|--------------------------------------------|
| title             | [string](https://typst.app/docs/reference/foundations/str/)          | The title of the internship report         |
| subtitle          | [string](https://typst.app/docs/reference/foundations/str/)          | The subtitle of the internship report      |
| lang              | [string](https://typst.app/docs/reference/foundations/str/)          | French ("fr") or English ("en")            |
| authors           | [string](https://typst.app/docs/reference/foundations/str/) or [array](https://typst.app/docs/reference/foundations/array/) | A string if there is one author and an array if there are many authors |
| mentors           | [string](https://typst.app/docs/reference/foundations/str/) or [array](https://typst.app/docs/reference/foundations/array/) | A string if there is one mentors and an array if there are many mentors |
| logo              | [string](https://typst.app/docs/reference/foundations/str/) or [none](https://typst.app/docs/reference/foundations/none/)  | The path of the file
| place             | [string](https://typst.app/docs/reference/foundations/str/)          | The place of the internship                |
| date             | [string](https://typst.app/docs/reference/foundations/str/)          | The date of the internship                |
| table-of-contents | [bool](https://typst.app/docs/reference/foundations/bool/)   | True to display the table of contents      |
| bibliography      | [content](https://typst.app/docs/reference/foundations/content/)  or [none](https://typst.app/docs/reference/foundations/none/)        |  The result of a call to the bibliography function or none |
