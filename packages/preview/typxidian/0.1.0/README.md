# TypXidian

This is a modern [Typst](https://github.com/typst/typst) template inspired by [Obsidian](https://obsidian.md/) for note-taking, thesis and academic project reports.
This project is also available as a LaTeX template at [LaXidian](https://github.com/robertodr01/LaXidiaN). 

<div align="center">
  <img align="center" width="500" height="700" alt="thumbnail" src="https://github.com/user-attachments/assets/4c81e2a4-e645-46b8-a6ac-5ad60e73936a" />
</div>


## Usage

To use this package just add the following code to your [Typst](https://github.com/typst/typst) document:

```typst
#import "@preview/typxidian:0.0.1": template

#show: template.with(
  language: "en",
  title: "Example title",
  subtitle: "Example subtitle",
  authors:("Example author"),
  faculty: "Science",
  department: "Computer Science",
)
```

More information on how to use the template can be found in [main.pdf](https://github.com/angelonazzaro/typxidian/blob/main/main.pdf).

## Notes

### Callouts, Definitions and Theorems

Obisidan's callouts, along with custom definitions and theorems are a work in progress and will be released soon.

### Compilation
If you split individual chapters into different files, make sure you include them and compile only your `main.typ` file. This will avoid problems when using references etc.\

# Contributing

Feel free to contribute by opening an issue or a pull request.
