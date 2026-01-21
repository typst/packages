# minimalistic-latex-cv

This is a Typst template for a minimalistic LaTeX-style CV. It provides a simple
structure for a CV with a header, a section for professional experience, a section
for education, and a section for skills and languages.

## Usage

You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `minimalistic-latex-cv`.

Alternatively, you can use the CLI to kick this project off using the command

```
typst init @preview/minimalistic-latex-cv
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `cv` function with the following named arguments:

- `name`: The name of the person.
- `metadata`: A dictionary of metadata of the person to be displayed in the header.
- `photo`: The path to the photo of the person.
- `lang`: The language of the document.

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `cv`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/minimalistic-latex-cv:0.1.1": cv

#show: cv.with(
  name: "Your Name",
  metadata: (
    email: "your@email.com",
    telephone: "+123456789",
  ),
  photo: image("photo.jpeg"),
  lang: "en",
)

// Your content goes below.
```
