<!-- Reference: https://github.com/typst-community/typst-package-template -->

# aio-studi-and-thesis: All-in-one template for students and theses

<p align="center">
  <a href="https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/blob/main/LICENSE">
    <img alt="MIT License" src="https://img.shields.io/badge/license-MIT-brightgreen">
  </a>
</p>

This template can be used for extensive documentation as well as for final theses such as bachelor theses.

It is characterised by the fact that it is highly customisable despite the predefined design.

Initially, all template parameters are optional by default. It is then suitable for documentation.
To make it suitable for theses, only one parameter needs to be changed.

## ⚠️ **Disclaimer - Important!**

- It is a template and does not have to meet the exact requirements of your university
- It is only supported in German and English (Default setting: German)

## Getting Started

You can use this [template](https://typst.app/universe/package/aio-studi-and-thesis) in the Typst web app by clicking “Start from template” on the dashboard and searching for `aio-studi-and-thesis`.

Alternatively, you can use the CLI to kick this project off using the command

```bash
typst init @preview/aio-studi-and-thesis
```

Typst will create a new directory with all the files needed to get you started.

## Usage

The [example PDF (DE)] contains thesis writing advice (in German). Attention, the font is not displayed correctly in the linked PDF ([GitHub Issue](https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/issues/3))!

If you are looking for the details of this template package's function, take a look at the [german manual] or the [english manual].

> `Roboto` is used as the default font. Please note accordingly if you want to use exactly this font. Otherwise, please change it. This may be necessary if you do not use Typst via the web app.

## Example configuration

```typ
#import "@preview/aio-studi-and-thesis:0.1.1": *

#show: project.with(
  lang: "de",
  authors: (
    (name: "Firstname Lastname"),
  ),
  title: "Title",
  subtitle: "Subtitle",
  cover-sheet: (
    cover-image: none,
    description: []
  )
)
```

## Donate with [PayPal](https://www.paypal.com/donate/?hosted_button_id=4G9X8TDNYYNKG)

If you think this template is useful and saves you a lot of work and nerves (Word and LaTex can be very tiring) and lets you sleep better, then a small donation would be very nice.

<a href="https://www.paypal.com/donate/?hosted_button_id=4G9X8TDNYYNKG" target="_blank">
  <!--
    https://github.com/stefan-niedermann/paypal-donate-button
  -->
  <img src="https://raw.githubusercontent.com/stefan-niedermann/paypal-donate-button/master/paypal-donate-button.png" style="height: 90px; width: 217px;" alt="Donate with PayPal"/>
</a>

<!-- URLs for docs -->

[example PDF (DE)]: https://github.com/typst/packages/blob/main/packages/preview/aio-studi-and-thesis/0.1.1/docs/example-de-thesis.pdf
[german manual]: https://github.com/typst/packages/blob/main/packages/preview/aio-studi-and-thesis/0.1.1/docs/manual-de.pdf
[english manual]: https://github.com/typst/packages/blob/main/packages/preview/aio-studi-and-thesis/0.1.1/docs/manual-en.pdf