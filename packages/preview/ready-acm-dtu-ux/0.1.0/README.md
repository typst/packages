# acm-dtu-ux

An ACM-based Typst template for UX Design Prototyping (02810) / UX Engineering (02266) assignments at Technical University of Denmark (DTU).

This is a student-made adaptation to Typst based on the original LaTeX template provided in the course. Hopefully it can be promoted by course staff for who likes Typst more than LaTeX. :)

## Usage

> [!NOTE]
> When working locally, you might need to install additional fonts: **Inconsolata**,
> **Libertinus Sans & Serif**.
>
> Libertinus is the newer and maintained version of Linux Libertine and Biolinum,
> which you can find at https://github.com/alerque/libertinus, or via Homebrew Cask `font-libertinus`.
>
> Linux Libertine is the original choice of the ACM Journal for their LaTeX templates.
>
> Inconsolata is only used for raw blocks, if you don't like it, you can override it by calling:
>
> ```typst
> #show raw: set text(font: "<your-mono-font>")
> ```
>
> **after** the `project.with` instantiation.

Either start a project from the Typst interface using this template or use it in your existing project:

```typst
#import "@preview/acm-dtu-ux:0.1.0": *

#show: project.with(
  title: "One AR to rule them all",
  authors: (
    (name: "Joe Author", email: "s______@student.dtu.dk", affiliation: "Technical University of Denmark", postal: "Lyngby"),
    (name: "Jack Author", email: "s______@student.dtu.dk", affiliation: "Technical University of Denmark", postal: "Lyngby"),
    (name: "William Author", email: "s______@student.dtu.dk", affiliation: "Technical University of Denmark", postal: "Lyngby"),
    (name: "Averell Author", email: "s______@student.dtu.dk", affiliation: "Technical University of Denmark", postal: "Lyngby"),
  ),
  // Insert your abstract, if any, after the colon, wrapped in brackets. If left empty, it will not show up as a chapter altogether.
  // Example: `abstract: [This is my abstract...]`
  abstract: [],
)

// your content here
// #show raw: set text(font: "Consolas")

// any appendices? add the following:
#appendix([
= Ethical Analysis <appendix:ethical>


= The Jupyter Notebook <appendix:jupter>

// ...
])
```

## Preview

![Screenshot of acm-dtu-ux package in use](preview.png)
