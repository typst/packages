# The `cyberschool-errorteaplate` Package

This package is a template based on the colors of the Cyberschool of Rennes,
France. It is based on Latex templates I wanted to use in Typst.

Feel free to make suggestions on the [dedicated repo](https://github.com/ErrorTeaPot/Cyberschool_template).

## Getting Started

These instructions will get you a copy of the project up and running on the typst
web app.

```typ
#import "@preview/cyberschool-errorteaplate:0.1.6": *

#show: conf.with(
  title: "Title",
  pre-title: "Pre-title",
  authors: (
    (
      name: "name",
      affiliation: "affiliation",
      email: "email",
    ),
  ),
  logos: (
    image.with("<image path>"),
    image.with("<image path>"),
  ),
  abstract: "abstract text",
  outline-title: "Contents",
)
```

### Installation

To help with development, fork [this repository](https://github.com/ErrorTeaPot/Cyberschool_template), make your changes and then create a pull request.
For additional information about the guidelines and stuff, refer to the README of
[this repository](https://github.com/typst/packages).

## Additional Documentation and Acknowledgments

Thanks to [lucasrqt](https://github.com/lucasrqt) for the original Latex template
on which this one is based on.
