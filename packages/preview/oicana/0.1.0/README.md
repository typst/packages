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

Considering a Typst project with the following `typst.toml`:
```toml
[package]
name = "example"
version = "0.1.0"
entrypoint = "main.typ"

[tool.oicana]
manifest_version = 1

[[tool.oicana.inputs]]
type = "json"
key = "data"
development = "data.json"

[[tool.oicana.inputs]]
type = "blob"
key = "logo"
development = { file = "company-logo.png" }
```

This package will collect the two inputs and prepare them for use in your Typst code. Previewing the following `main.typ` file in a Typst editor, would show the contents of the `data.json` and `company-logo.png` files:
```typst
#import "@preview/oicana:0.1.0": setup

#let read-project-file(path) = return read(path, encoding: none);
#let (input, oicana-image, config) = setup(read-project-file);

this is the current value of the input with the key "data":
#input.data

The image passed into the template with the input key "logo": \
#oicana-image("logo")
```

 If compiled through one of the Oicana integrations (for example out of C# code), the input values given by the integration would be used instead of the defined `development` values from the manifest file.
 
 A Typst project that configures Oicana in it's manifest file and uses the package `@preview/oicana` is called an [Oicana template in the documentation][oicana-template].

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
[example-templates]: https://github.com/oicana/oicana-example-templates
[getting-started]: https://docs.oicana.com/getting-started
[oicana-template]: https://docs.oicana.com/templates
