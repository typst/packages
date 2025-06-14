= Modern Technique Report

A template support modern technique report in Typst.

= Usage

```typst
#import "@preview/modern-technique-report:0.1.1": *

#show: modern-technique-report.with(
  title: [Project Name \ Multiline When too Long],
  subtitle: [
    *Fourth Edition*, \ by _H.L. Royden_ and _P.M. Fitzpatrick_
  ],
  series: [Mathematics Courses \ Framework Series],
  author: grid(
    align: left + horizon,
    columns: 3,
    inset: 7pt,
    [*Member*], [B. Alice], [qwertyuiop\@youremail.com],
    [], [B. Alice], [qwertyuiop\@youremail.com],
    [], [B. Alice], [qwertyuiop\@youremail.com],
    [*Advisor*], [E. Eric], [qwertyuiop\@youremail.com],
  ),
  date: datetime.today().display("[year] -- [month] -- [day]"),
  background: image("bg.jpg"),
  theme_color: rgb(21, 74, 135),
  font: "New Computer Modern",
  title_font: "Noto Sans",
)
```

Then a cover page and a content page will be automatically generated. Template also manipulates the style of headings and some contents.
