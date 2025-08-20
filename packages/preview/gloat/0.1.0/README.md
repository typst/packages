# The `gloat` Package

<div align="center">Version 0.1.0</div>

A resume/curriculum vitae package and template geared towards the physical sciences and research-based careers.
Still in early development; releases should not yet be considered stable.
Be sure to pin the version used to prevent your project from breaking!

Originally modified from [guided-resume-starter-cgc][cgc].

[cgc]: https://typst.app/universe/package/guided-resume-starter-cgc

![
Example CV created using the `gloat` package. 
It has a header with the author name, address, and contact information. 
It also has sections detailing education, research experience, publications, and awards.
](thumbnail.png)

## Getting Started

These instructions will get you a copy of the project up and running on the typst web app.

```typ
#import "@preview/gloat:0.1.0": *

#show: cv.with(
  author: "Firstname Lastname",
  address: "Address here",
  contacts: (
    [#link("mailto:youremail@email.com")[youremail\@email.com]],
    [#link("https://github.com/user")[gh/user]],
    [#link("https://www.linkedin.com/in/user/")[in/user]],
  ),
  updated: datetime.today(),
)

= Education

#edu(
  institution: "Some college",
  degrees: (
    [B.Sc. Physics],
  ),
  date: datetime(year: 2024, month: 05, day: 03),
  gpa: "4.00",
)

= Research Experience

#exp(
  role: "Job Title",
  org: "Some organization",
  location: "Place where work took place",
  start: datetime(year: 2023, month: 10, day: 11),
  end: "Present",
  details: [
    - List what you did here in bullet points.
  ],
)
```

### Installation

To install the latest release of this package from preview, use the `import` function:

```typ
#import "@preview/gloat:0.1.0": *
```

Alternatively, the package can be cloned and installed locally from github.
This will allow you to make edits to the package if you so desire.

```sh
$ git clone https://github.com/eweix/gloat
$ cd gloat
$ /bin/bash ./scripts/package @local
```

## Usage

Each function in this package creates an entry in the CV.
This can be a degree using the `edu` function, a paper from the `paper` function, or work experience using the `exp` function.
Please do submit feature requests with additional functions that might be useful!

### Degrees/Education

```typ
#import "@preview/gloat:0.1.0": *

#edu(
    degrees:(
    [B.A. Finnish Literature],
    )
    date: datetime(year: 2025, month: 1, day: 1),
    institution: "Some college",
    location: "Some city",
)
```

### Experience

```typ
#import "@preview/gloat:0.1.0": *

#exp(
  role: "Job Title",
  org: "Amazing Inc.",
  start: "June 2022", // or datetime
  end: "Present",
  location: "Cleveland OH, US",
  details: [
    - An impressive accomplishment
    - Another accomplishment
  ],
)
```

### Papers, preprints, and abstracts

```typ
#import "@preview/gloat:0.1.0": *

#paper(
  authors: (
    [Firstname Lastname],
    [Another Author],
  ),
  published: datetime(year: 2025, month: 1, day: 1),
  title: "A very impressive paper",
  vol: "12",
  issue: "2",
  pages: "355-372",
  journal: "Prestigious Journal",
)

#preprint(
  authors: (
    [Firstname Lastname],
    [Second Author],
    [Another Author],
  ),
  title: "Preprint title",
  published: datetime(year: 2025, month: 3, day: 21),
  archive: "bioRxiv",
  DOI: "doi",
  status: "Submitted",
)

#abstract(
  authors: (
    [Firstname Lastname],
    [Second Author],
    [Another Author],
  ),
  number: 1153,
  pages: "p 160",
  title: "A super cool title for an awesome poster",
  conference: "Totally legitimate conference",
  date: datetime(year: 2025, month: 4, day: 25),
  location: "Some town",
  kind: "",
)
```

> [!TIP]
> To bold your name in a publication or presentation list, use a show rule:
>
> ```typ
> #show regex("Firstname Lastname"): name => text(weight: "bold", name)
> ```

### Presentations

```typ
#pres(
  authors: (
    [Firstname Lastname],
    [Second Author],
    [Another Author],
  ),
  number: 1153,
  pages: "p 160",
  title: "A super cool title for an awesome poster",
  conference: "Totally legitimate conference",
  date: datetime(year: 2025, month: 4, day: 25),
  location: "Some town",
  kind: "Talk",
)

```

### Awards

```typ
#import "@preview/gloat:0.1.0": *

#award(
  name: "Name of the award",
  from: "Institution that granted the award",
  date: "2025",
  details: [
    Amount and other details can go here, but may not be necessary.
  ],
)
```

### Service

```typ
#import "@preview/gloat:0.1.0": *

#ser(
  role: "Role",
  org: "Organization",
  start: datetime(year: 2025, month: 4, day: 15),
  end: "Present",
  summary: [
    Summary of the role.
  ],
)
```

### Skills

```typ
#import "@preview/gloat:0.1.0": *

#skills((
  (
    "Expertise",
    (
      [Systems Biology],
      [Signal Processing],
      [MinDE System],
    ),
  ),
  (
    "Software",
    (
      [Docker],
      [git],
      [Typst],
      [LaTeX],
    ),
  ),
))
```
