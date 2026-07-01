# Modern CV

[![say thanks](https://img.shields.io/badge/Say%20Thanks-👍-1EAEDB.svg)](https://github.com/DeveloperPaul123/modern-cv/stargazers)
[![Discord](https://img.shields.io/discord/652515194572111872?logo=Discord)](https://discord.gg/CX2ybByRnt)
![Release](https://img.shields.io/github/v/release/DeveloperPaul123/modern-cv)
[![Build documentation](https://github.com/DeveloperPaul123/modern-cv/actions/workflows/build-documentation.yml/badge.svg)](https://github.com/DeveloperPaul123/modern-cv/actions/workflows/build-documentation.yml)

A port of the [Awesome-CV](https://github.com/posquit0/Awesome-CV) Latex resume template in [typst](https://github.com/typst/typst).

## Requirements

You will need the `Roboto` and `Source Sans Pro` fonts installed on your system or available somewhere. If you are using the `typst` web app, no further action is necessary. You can download them from the following links:

- [Roboto](https://fonts.google.com/specimen/Roboto)
- [Source Sans Pro](https://github.com/adobe-fonts/source-sans-pro)

This template also uses FontAwesome icons via the [fontawesome](https://typst.app/universe/package/fontawesome) package. You will need to install the fontawesome fonts on your system or configure the `typst` web app to use them. You can download fontawesome [here](https://fontawesome.com/download).

To use the fontawesome icons in the web app, add a `fonts` folder to your project and upload the `otf` files from the fontawesome download to this folder like so:

![alt text](assets/images/typst_web_editor.png)

See `typst fonts --help` for more information on configuring fonts for `typst` that are not installed on your system.

### Usage

Below is a basic example for a simple resume:

```typst
#import "@preview/modern-cv:0.1.0": *

#show: resume.with(
  author: (
      firstname: "John", 
      lastname: "Smith",
      email: "js@example.com", 
      phone: "(+1) 111-111-1111",
      github: "DeveloperPaul123",
      linkedin: "Example",
      address: "111 Example St. Example City, EX 11111",
      positions: (
        "Software Engineer",
        "Software Architect"
      )
  ),
  date: datetime.today().display()
)

= Education

#resume-entry(
  title: "Example University",
  location: "B.S. in Computer Science",
  date: "August 2014 - May 2019",
  description: "Example"
)

#resume-item[
  - #lorem(20)
  - #lorem(15)
  - #lorem(25)  
]
```

After saving to a `*.typ` file, compile your resume using the following command:

```bash
typst compile resume.typ
```

For more information on how to use and compile `typst` files, see the [official documentation](https://typst.app/docs).

Documentation for this template is published with each commit. See the attached PDF on each Github Action run [here](https://github.com/DeveloperPaul123/modern-cv/actions).

### Output Examples

| Resumes | Cover letters |
| --- | --- |
| ![Resume](assets/images/resume.png) | ![Cover Letter](assets/images/coverletter.png) |
| | ![Cover Letter 2](assets/images/coverletter2.png)|
