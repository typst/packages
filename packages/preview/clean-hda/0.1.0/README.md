# Clean HDA

A [Typst](https://typst.app/) template for h_da thesis and papers in the department of Computer Sciences.


The template recreates
[mbredel/thesis-template](https://github.com/mbredel/thesis-template) by
forking the the existing template of [DHBW](https://github.com/roland-KA/clean-dhbw-typst-template), which looked the most similar to the
original latex implementation for h_da students. 

This is an **unofficial** template for [Hochschule Darmstadt - University of Applied Sciences](www.h-da.de) for the department of Computer Sciences.
Contributions and takeover by h_da affiliated are welcome. 
 
## Getting started

Run the following command in your terminal to create a new project using this template:


Make sure to replace `<version>` with the actual version you want to use, e.g. `0.1.0`.

```console
typst init @preview/clean-hda:<version> MyMasterThesis
```

## Getting started for template development

You may want to follow these steps if you want to contribute to the template itself and make your development easier for fast iteration cycles.

1. Add this as a git submodule
```console
git submodule add https://github.com/stefan-ctrl/clean-hda-typst-template hda_template
```

2. Include as the following in your `main.typst`:

```typst
#import "./hda_template/template/main.typ": *
```

Contributions are welcome.

## Forked from DHBW Template

Please review the original forked documentation for more information, configuration and usage options :
[roland-KA/clean-dhbw-typst-template](https://github.com/roland-KA/clean-dhbw-typst-template)

To see the direct changes compared to the forked project, consider
taking a look at the [CHANGELOG.MD](./CHANGELOG.md).
