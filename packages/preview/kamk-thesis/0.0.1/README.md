# The `kamk-thesis` Package
<div align="center">Version 0.0.1</div>

A Typst template for theses at Kajaani University of Applied Sciences (KAMK): title page, Finnish and English abstracts, table of contents, optional list of symbols, and body chapters with KAMK's official page geometry and automatic page numbering.

## Getting Started

### Local usage

1. Install the [`typst`](https://typst.app/docs/) compiler.
2. Run the following command in your terminal to install the package:

    ```
    typst init @preview/kamk-thesis:0.0.1
    ```
3. Go to project's directory and run the compiler in incremental compilation mode to start working. You may exit this mode with `Ctrl` + `C` when you are done.

    ```bash
    cd kamk-thesis
    typst watch thesis.typ
    ```

### Font installation

The template uses the **Carlito** font for body text. Installation is guide at the [Zensical docs site](https://sourander.github.io/kamk-thesis-typst/riippuvuudet/). Compilation will fail without the font installed.

### Writing your thesis

After installation, you need to modify the `thesis.typ` file to include your own content. Below is a minified example of what the file contains. The `#show` block is where you define the front matter parameters, and the `#include` statements are where you include your body chapters.

```typ
#import "@preview/kamk-thesis:0.0.1" as template

#show: template.frontmatter.with(
  // Perustiedot
  authors: ("Meikäläinen Matti",),
  date: datetime.today(),
  // Other parameters removed for brevity; see the thesis.typ for full example
  // ...
)

// ...

// Body chapters are included from separate files, e.g.:
#include "chapters/johdanto.typ"
#include "chapters/mallipohjankayttaminen.typ"
#include "chapters/sivut.typ"

// ... AI usage declaration, bibliography and appendices follow
// see the thesis.typ for full example.
```

See the Zesical-generated documentation at [https://sourander.github.io/kamk-thesis-typst/](https://sourander.github.io/kamk-thesis-typst/) for more usage examples, Justfile tips, video tutorials and much more. That site is a must-read for anyone writing an actual thesis with this template.

## Problems and Contributing

For any problems, please contact the key maintainer, Jani Sourander. 

- If you are a KAMK student and encounter any issues, please use KAMK's internal communication channels to reach out to me.
- Otherwise, contact using Github issues.

For contributing, see the original repository and the included contribution markdown file.

## Acknowledgments

- Heavily inspired by the [WUT diploma thesis template](https://github.com/fuine/wut-thesis-typst) by Warsaw University of Technology in how the files are organized and named.
- Source code released under the [MIT No Attribution License](LICENSE).
- IMPORTANT! The project contains KAMK logo and design choices that are the property of Kajaani University of Applied Sciences Oy.

