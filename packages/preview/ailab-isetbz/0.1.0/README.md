# AILAB-ISETBZ: AI Lab Report Template at ISET Bizerte

## Installation
You can use this template in the **Typst** web app by clicking `Create project in app` from the dashboard after searching for `ailab-isetbz`. As an alternative, you can start this project with the following command in the CLI:
```bash
typst init @preview/ailab-isetbz:0.1.0
```
**Typst** will create a new directory with all the files needed to get you started.

## How To
The title, abstract, students, emails, GitHub profiles, and terms pertaining to the lab report can all be defined in the section below.
```typst
#let title = "Lab Report"
#let abstract = "The main topics discussed in the manuscript."
#let students = ("Student 1", "Student 2")
#let emails = ("student1@bizerte.r-iset.tn", "student2@bizerte.r-iset.tn")
#let profiles = ("profile1", "profile2") // GITHUB Profiles
#let terms = ("Typst", "GitHub", "Docker", "Julia", "Lab Report")
```
The next step makes it possible to display the lab report and import the template.
```typst
#import "@preview/ailab-isetbz:0.1.0": *
#show: AILAB.with(
  title: text(smallcaps(title)),
  abstract: abstract,
  authors: 
  (
    (
      name: students.at(0),
      email: emails.at(0),
      profile: profiles.at(0)
    ),
    (
      name: students.at(1),
      email: emails.at(1),
      profile: profiles.at(1)
    ),
  ),
  index-terms: terms,
  // bibliography-file: "Biblio.bib",
)
```
The task that has to be completed can be highlighted in the block that follows.
```typst
#exo[Title][Content...]
```
Use the following block if you wish to include the solution:
```typst
#solution[The solution]
```
Use this block if a test is necessary:
```typst
#test[Some test]
```

## Example Usage
A detailed example can be found [here](https://github.com/a-mhamdi/ailab-isetbz/tree/main/Typst/example).

## Acknowledgements
This template was inspired by the [charged-ieee](https://github.com/typst/packages/tree/main/packages/preview/charged-ieee) package.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
