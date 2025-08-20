# bone-resume
This is a Typst template.

## Usage
You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `bone-resumee`.

Alternatively, you can use the CLI to kick this project off using the command
```
typst init @preview/bone-resume
```

Typst will create a new directory with all the files needed to get you started.

## Configuration
This template exports the `resume-init` function with the following named arguments:

- `authors`: Your name.
- `title(optional)`: The resume's title as content.
- `footer(optional)`: The resume's footer as content.

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `bone-resume`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/bone-resume:0.1.0": bone-resume

#show: bone-resume.with(
  author: "六个骨头"
)

= 个人介绍
A Student.

// Your content goes below.
```
