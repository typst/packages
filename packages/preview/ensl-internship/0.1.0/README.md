# ensl-internship
An unofficial template for internship reports at ENS de Lyon.

## Usage

```typ
#show: ensl-internship.with(
  title: "A simple report template created with Typst",
  subtitle: "Master's degree final-year internship",
  keywords: ("Kerlyon", "Lorem", "Ipsum"),
  abstract: lorem(25),
  lang: "en",
  authors: ("Author 1", "Author 2"),
  mentors: ("Mentors 1", "Mentors 2"),
  logo: image("../assets/Logo_CNRS.png", height: 50pt),
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
| keywords          | [array](https://typst.app/docs/reference/foundations/array/)         | List of keywords                           |
| abstract          | [string](https://typst.app/docs/reference/foundations/str/)          | Abstract                          |
| authors           | [string](https://typst.app/docs/reference/foundations/str/) or [array](https://typst.app/docs/reference/foundations/array/) | A string if there is one author and an array if there are many authors |
| mentors           | [string](https://typst.app/docs/reference/foundations/str/) or [array](https://typst.app/docs/reference/foundations/array/) | A string if there is one mentors and an array if there are many mentors |
| logo              | [content](https://typst.app/docs/reference/foundations/content/)  or [none](https://typst.app/docs/reference/foundations/none/)  | The logo, it is recommand to use a height of 50pt
| place             | [string](https://typst.app/docs/reference/foundations/str/)          | The place of the internship                |
| date             | [string](https://typst.app/docs/reference/foundations/str/)          | The date of the internship                |
| table-of-contents | [bool](https://typst.app/docs/reference/foundations/bool/)   | True to display the table of contents      |
| bibliography      | [content](https://typst.app/docs/reference/foundations/content/)  or [none](https://typst.app/docs/reference/foundations/none/)        |  The result of a call to the bibliography function or none |
