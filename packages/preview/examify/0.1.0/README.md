# Examify

Examify is a typst template to typeset simple question papers for examinations.

## Installation

You can use this template in the Typst web app by clicking "Start from template" on the dashboard
and searching for `examify`.

Alternatively, you can use the CLI to kick this project off using the command:

```bash
typst init @preview/examify:0.1.0
```

## Configuration

The `example.typ` file at the root of this repository is quite self-explanatory. Here is a sample
code for reference:

```typst
#import "@preview/examify:0.1.0": *

#show: examify.with(
  paper-size: "a4",
  fonts: "New Computer Modern", // Change to your preferred font
  language: "EN",
  institute: "Institute Name", // Not Mandatory
  author: "Teacher Name", // Not Mandatory
  contact-details: "www.example.com", // Not Mandatory
  exam-name: "First Semester Examination", // Not Mandatory
  subject-label: "Subject",
  subject: "Set Theory",
  marks-label: "Full Marks",
  marks: 10,
  class-label: "Class",
  class: "XI",
  time-label: "Time",
  time: "30 Minutes",
)

// Write here
```