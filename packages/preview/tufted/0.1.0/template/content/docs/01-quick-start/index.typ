#import "../index.typ": template, tufted
#show: template.with(title: "Quick Start")

= Quick Start

== Installation

To initialize a new project using the `tufted` template, run the following command in your terminal:

```sh
typst init @preview/tufted:0.0.1 my-website
cd my-website
```

== Building

The template includes a `Makefile` to automate the build process. To build the website, run:

```sh
make html
```

This command compiles all `.typ` files in the `content/` directory into HTML files in the `_site/` directory.
