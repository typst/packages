# Postgraduate Admission CV

A compact academic CV template for postgraduate admission applications. It provides a colored page banner, optional footer, profile header, section titles, and left-right aligned entries.

## Usage

```typ
#import "@preview/postgraduate-admission-cv:0.1.0": cv, cv-header, section, item, highlight-red

#show: cv.with(
  header-title: [*Postgraduate Admission CV*],
  footer: [applicant@example.com],
)

#cv-header(
  [Applicant Name],
  [University · Major #h(1em) Expected graduation: 2027.06],
  [phone@example.com #h(1.5em) applicant@example.com],
)

#section("Education", "🎓")

#item([*Example University | Data Science | B.S.*], [2023.09–2027.06])

*GPA:* 3.80/4.00 #h(1em)
*Rank:* Top 10%
```

Run `typst init @preview/postgraduate-admission-cv:0.1.0` after the package is accepted into Typst Universe.

## Customization

- `accent-color`: main banner and section line color.
- `header-logo`: optional image path for a logo.
- `header-title`: content shown in the page banner.
- `footer`: optional footer content.
- `cv-header`: name, subtitle, contact line, and optional avatar.

## License

This package is released under the MIT-0 license.
