# Typst/Touying Template for MedUni Wien

This is a template built on [`Touying`](https://github.com/touying-typ/touying) to create presentation slides that capture the design of the official PowerPoint templates following Medizinischen Universität Wien [Corporate Design](https://www.meduniwien.ac.at/web/en/studierende/service-center/meduni-wien-vorlagen/).

## Disclaimer

*This theme is __unofficial__. It is __NOT__ affiliated with Medizinischen Universität Wien (Medical University of Vienna). The logo is the intellectual property of the Medical University of Vienna and is subject to copyright. Users are advised to check the official Styleguide before using this template.*

## Example

See [examples](examples) for more details.

## Usage

Use the following code as a starting point to create your own slides.

```typst
#import "@preview/touying:0.6.1": *
#import "@preview/muw-touying-community:0.1.0": *

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

== Title of the slide

=== Subtitle

Hello, MedUni Wien!

```

## License and copyright

- This template builds upon `Touying` and is licensed under [MIT license](LICENSE).
- The MedUni Wien logo is the intellectual property of the Medical University of Vienna and is subject to copyright.
- The image `examples/example_brain_mri.png` is licensed under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/).
- The image `examples/example_infobox_picture.jpg` ([Vienna General Hospital, Main Entrance](https://commons.wikimedia.org/wiki/File:Vienna_General_Hospital,_Main_Entrance.jpg)) by Thomas Ledl is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
- The image `examples/example_wide_picture.jpg` ([Josephinum in Vienna](https://commons.wikimedia.org/wiki/File:Josephinum_P2.JPG)) by Gryffindor stitched by Marku1988 (created with Hugin) is licensed under [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).

## Acknowledgement

This project is greatly inspired by [another unoffical template](https://github.com/felixbd/muw-templates/) for the Medical University of Vienna, which was built on `Typst/Polylux`.

## Suggestions and contributions

Contributions to the template are encouraged! Feel free to send me a message if you find any issue or have any suggestion to improve this template.
