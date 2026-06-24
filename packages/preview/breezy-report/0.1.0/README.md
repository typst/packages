# breezy-report

A clean, colour-customisable engineering report template for Typst. Designed for university assignment submissions. The submission date is auto-populated.

## Usage

```typst
#import "@preview/breezy-report:0.1.0": *

#show: breezy.with (
  semester: "Semester 1 2026",
  courseCode: "ENGE500",
  courseName: "Engineering Mathematics I",
  title: "My Report: With an extended title",
  studentID: "12345678",
  author: "Jane Smith",
  accentColour: rgb("#300649"),
)

//Your content goes here
```

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `accentColour` | `rgb("#300649")` | Primary accent colour |
| `tableHeaderTextColour` | `white` | Table header text colour |
| `bibFile` | `none` | Path to `.bib` file (if applicable) |

## Default fonts
 - **Georgia**: Body text.
 - **Montserrat**: Headings and title page. Must be installed locally - download from [Google Fonts](https://fonts.google.com/specimen/Montserrat).
 - **DejaVu Sans**. Fallback font for headings & title page is Montserrat is not installed.

## Example pages
![An example title page from the breezy-report template with dark purple bars across the top and bottom of the page, with the student name, ID, course name and course ID overlayed. The title is in the centre of the page.](imgs/1.png)

![An example contents page from the breezy-report template.](imgs/2.png)

![An example page from the breezy-report template. A dark purple bar is the page header with the course ID and assignment title on the left, the student ID on the right. List items, the headings, and the table headers are coloured in the accent colour of dark purple. Code block has a light purple background with slightly rounded corners.](imgs/3.png)