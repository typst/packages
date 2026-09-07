# Coral CV

Coral CV is an elegant, ATS-friendly résumé, CV, and cover-letter set with a
compact information layout, a Pampas paper background, and coral accents.

## Start a new application

In the Typst web app, choose **Start from template**. With the CLI, run:

```sh
typst init @preview/coral-cv:0.1.0 my-application
```

The initialized project contains `main.typ` for the CV and `cover-letter.typ`
for a matching Fireside-inspired application letter. Compile either document:

```sh
typst compile my-application/main.typ
typst compile my-application/cover-letter.typ
```

## Use as a package

```typst
#import "@preview/coral-cv:0.1.0": *

#show: resume.with(
  author: "Your Name",
  location: "Auckland, New Zealand",
  email: "hello@example.com",
  phone: "+64 21 000 0000",
  font: "Libertinus Serif",
)

== Experience

#work(
  title: "Product Designer",
  company: "Example Studio",
  location: "Auckland, NZ",
  dates: dates-helper(start-date: "2024", end-date: "Present"),
)
- Describe a measurable contribution or result.
```

The package exports `resume`, `cover-letter`, `work`, `edu`, `project`,
`certificates`, `extracurriculars`, `dates-helper`, and generic layout helpers.
The `resume` function accepts the same core contact and positioning options as
`basic-resume`, plus `contact-lines` for controlled multi-line contact details.

The initialized files use `Libertinus Serif`, which is embedded in the Typst
CLI for portable compilation. You can pass another installed font through the
`font` parameter, such as `Charter`.

## Cover letter

```typst
#import "@preview/coral-cv:0.1.0": cover-letter

#show: cover-letter.with(
  author: "Your Name",
  email: "hello@example.com",
  date: datetime.today().display("[day] [month repr:long] [year]"),
  recipient: [Hiring Manager \\ Example Studio],
  subject: "Product Designer",
)

I am writing to apply for the Product Designer position...
```

The cover letter uses a Fireside-inspired editorial layout with a large title,
sender details at the upper right, recipient details below, and subtle vertical
centering for short letters. It uses Coral CV's colors and has no package
dependencies.

## Acknowledgements

The API and compact résumé layout are inspired by
[`basic-resume`](https://github.com/stuxf/basic-typst-resume-template) by
Stephen Xu, version 0.2.9, released under the Unlicense. The cover-letter layout
is inspired by [`fireside`](https://typst.app/universe/package/fireside), whose
template files are released under CC0. Coral CV is a local, dependency-free
implementation and does not import either package.

## License

Coral CV is released under the [MIT No Attribution License](LICENSE).
