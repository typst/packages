# Oicana
*Dynamic PDF Generation based on Typst*

https://oicana.com

Oicana offers seamless PDF templating across multiple platforms. Define your templates in Typst, specify dynamic inputs, and generate high quality PDFs from any environment - whether it's a web browser, server application, or desktop software.

> **Oicana is in Alpha! It is rough around the edges and has a limited number of integrations.**

## What Oicana offers

- *Multi-platform* - The same templates work with all Oicana integrations.
- *Powerful Layouting* - Templates can use all of Typst's functionality including its extensive package ecosystem.
- *Performant* - Create a PDF in single digit milliseconds.
- *Version Control Ready* - Templates are mostly text files and can live next to your source code.
- *Escape Vendor Lock-in* - Reuse templates with other Typst based solutions. The Typst compiler is open source!

## Example usage

```typst
#import "@preview/oicana:0.1.0": setup

#let read-project-file(path) = return read(path, encoding: none);
#let (input, oicana-image, config) = setup(read-project-file);

this is the current value of the input with the key "data":
#input.data

The image passed into the template with the input key "logo": \
#oicana-image("logo")
```

## Getting started

The [getting started guide][getting-started] will show you how to
1. Create an Oicana Template
2. Compile a PDF based on the template from an ASP.NET application
3. Add dynamic inputs to the template

If you would like to dive in head first, check out [the example templates][example-templates].

## Licensing

This package is available under the [MIT license](./LICENSE.md).

Oicana itself is source available under PolyForm Noncommercial License 1.0.0. For other licensing details, please take a look at [the website][Oicana]. 


[Oicana]: "https://oicana.com"
[Typst web app]: "https://typst.app"
[tytanic]: https://github.com/typst-community/tytanic
[typstyle]: https://github.com/Enter-tainer/typstyle
[typship]: https://github.com/sjfhsjfh/typship
[example-templates]: https://github.com/oicana/oicana-example-templates
