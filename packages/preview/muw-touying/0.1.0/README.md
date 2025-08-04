# Typst/Touying Template for MedUni Wien

This is a template built on [`Touying`](https://github.com/touying-typ/touying) to create presentation slides that captures the design of the official PowerPoint templates following [Medizinischen Universität Wien Corporate Design](https://www.meduniwien.ac.at/web/en/studierende/service-center/meduni-wien-vorlagen/).

## Disclaimer

*This theme is __unofficial__. It is __NOT__ affiliated with Medizinischen Universität Wien (Medical University of Vienna). The logo is the intellectual property of the Medical University of Vienna and is subject to copyright. Users are advised to check the official Styleguide before using this template.*

## Example

See [examples](examples) for more details.

## Usage

Use the following code as a starting point to create your own slides.

```typst
#import "@preview/touying:0.6.1": *
#import "colors.typ" as muw_colors
#import "lib.typ": *

#set text(lang: "en")
#show: muw-slides.with(
  config-common(slide-level: 2),
  config-info(
    title: [Title slide with a blue/white background],
    author: [Univ. Prof. Dr. Peter Strasser],
    institution: [Universitätsklinik für XY],
    organization: [Medizinische Universität Wien],
  ),
  page-numbering-start: 2,
)


// Your slide starts here

#title-slide-dunkelblau()

= Section Header
Version – white background

== Title, subtitle and content

=== Subtitle

Hello, MedUni Wien!

```

## License and copyright

- This template builds upon Touying and is licensed under [MIT license](LICENSE).
- The MedUni Wien logo is the intellectual property of the Medical University of Vienna and is subject to copyright.
- Some beautiful pictures used in the example template are copyright of Nihon Falcom Corporation and are used for demonstration purpose only.

## Acknowledgement

This project is greatly inspired by [another unoffical template](https://github.com/felixbd/muw-templates/) for the Medical University of Vienna, which was built on `Typst/Polylux`.

## Suggestions and contributions

Contributions to the template are encouraged! Feel free to send me a message if you find any issue or have any suggestion to improve this template.
