

This is a template to write a thesis in the TU Delft style. It is an unofficial template, not affiliated with the TU Delft.

| Cover page               | Title page               | Main text                |
|--------------------------|--------------------------|--------------------------|
| ![Cover page](https://raw.githubusercontent.com/Vector04/tudelft-thesis-template/refs/heads/master/docs/example-p1.png) | ![Title Page](https://raw.githubusercontent.com/Vector04/tudelft-thesis-template/refs/heads/master/docs/example-p2.png) | ![Main Text Page](https://raw.githubusercontent.com/Vector04/tudelft-thesis-template/refs/heads/master/docs/example-p6.png) |

## How to use
Initialize the template, either via the web app directly or using

```
typst init @preview/classy-tudelft-thesis:0.1.0
```
A small example of the template in action is given below. Please consult [this](https://github.com/Vector04/tudelft-thesis-template/blob/master/docs/Manual.pdf) document for a larger example of the thesis template in action, with all options and details more thoroughly explained. In addition, the default project also contains sufficient comments/annotations to get you started.
```typst
#import "@preview/classy-tudelft-thesis:0.1.0": *

// Main styling, containg the majority of typesetting including document layout, fonts, heading styling, figure styling, outline styling, etc. Some parts of the styling are customizable.
#show: base.with(
  title: "My document",
  name: "Your Name",
  rightheader: "Your name",
)

#makecoverpage(
  img: image("img/cover-image.jpg"),
  title: [Title of Thesis],
  subtitle: [Subtitle],
  name: [Your Name],
)

#maketitlepage(
  title: [Title of Thesis],
  subtitle: [Subtitle],
  name: "Your Name",
  defense-date: datetime.today().display("[weekday] [month repr:long] [day], [year]") + " at 10:00",
  student-number: 1234567,
  project-duration: [Starting month and year - Ending month and year],
  daily-supervisor: [Your Daily supervisor],
  thesis_commitee: ([Supervisor 1], [TU Delft, Supervisor],
                    [Committee member 2], [TU Delft],
                    [Committee member 3], [TU Delft.])
  cover-description: [Photo by ...],
  publicity-statement: none,
)

#heading(numbering: none, [Preface])
#heading(numbering: none, [Abstract])

#outline()

#show: switch-page-numbering

/* Your content here */

#bibliography(
  "references.bib",
  title: [References],
  style: "american-physics-society",
)

#show: appendix

/* Appendix content here */
```

## License

The template code and starting template files are licensed under the MIT-0 License. 

I do not own the copyright to the TU Delft logo. 

The assets used as placeholders in the template are by [Johannes Andersson](https://unsplash.com/@thejoltjoker?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash) and [karem adem](https://unsplash.com/@fezeikahapra?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash), and are licensed under the [Unsplash License](https://unsplash.com/license).

## Acknowledgements 

The layout was inspired by the LaTeX TU Delft template by [Daan Zwaneveld](https://github.com/dzwaneveld/tudelft-report-thesis-template).
