# simple-research-poster

`simple-research-poster` is a simple Typst template for university research posters.
To get started, run

```sh
typst init @preview/simple-research-poster:0.2.1
```

and you should see this:

<a href="https://github.com/aneziac/simple-research-poster/blob/main/template/poster.typ">
    <img src="./thumbnail.svg" width="100%">
</a>

The default file tree is simple:

- `main.typ` handles the relevant show and set rules, and how the sections are laid out in the grid
- `sections.typ` handles the actual poster content. This is where you place your exposition, results, diagrams, etc.
- `simple-research-poster.typ` is the template file, specifying how sections and the header and footer are constructed
  - For example, here you can add trim, add additional space for the title text, or switch the logo to the left side
- `colors.typ` handles the colors

The template is designed to be as generic as possible, so that it supports arbitrary paper size, arbitrary columns, landscape/portrait orientations, etc.
[Open an issue on Github](https://github.com/aneziac/simple-research-poster) if you have any feature requests or questions.

## Example

This template is a generalization of our code for the poster below:

<a href="https://github.com/aneziac/simple-research-poster/blob/main/examples/coxeter-groups">
    <img src="./examples/coxeter-groups/main.svg" width="100%">
</a>

Click the image above to see the code.
Note the diagrams are all rendered natively in Typst, via CeTZ.
