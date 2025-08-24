# casual-szu-report

A Typst template for SZU course reports.

## Usage

Example is at `template/main.typ`. TLDR:

```typst
#import "lib.typ": template

#show: template.with(
  course-title: [养鸡学习],
  experiment-title: [养鸡],
  faculty: [养鸡学院],
  major: [智能养鸡],
  instructor: [鸡老师],
  reporter: [鸡],
  student-id: [4144010590],
  class: [养鸡99班],
  experiment-date: datetime(year: 1983, month: 9, day: 27),
  features: (
    "Bibliography": "template/refs.bib",
  ),
)
// Start here
```

Features:

1. `Bibliography`: Bibliography file path.
2. `FontFamily`: Custom font family. Default: `("Noto Serif", "Noto Serif CJK SC")`
3. `CitationStyle`: Citation Style supported by Typst. Default: `gb-7714-2015-numeric`
  - Only work if have `Bibliography` specified.
4. `CourseID`: Add a Course ID box on top-right of the cover. NOT YET IMPLEMENTED.

## Method

The template will traverse body content, and split it into groups according to Heading-1 layout. Each group content will be wrapped with `table.cell`. So all content will be wrapped in container, you can't use `pagebreak()` in your body content.

## Warning

This is not a serious work and may have some rough edges. And reports from different faculties isn't entirely uniform. Be careful when using it.