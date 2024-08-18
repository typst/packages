# aio-studi-and-thesis: All-in-one template for students and theses

<p align="center">
  <a href="https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/blob/main/docs/manual-de.pdf">
    <img alt="Manual DE" src="https://img.shields.io/website?down_message=offline&label=manual%20de&up_color=007aff&up_message=online&url=https%3A%2F%2Fgithub.com%2Ffuchs-fabian%2Ftypst-template-aio-studi-and-thesis%2Fblob%2Fmain%2Fdocs%2Fmanual-de.pdf" />
  </a>
  <a href="https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/blob/main/docs/manual-en.pdf">
    <img alt="Manual EN" src="https://img.shields.io/website?down_message=offline&label=manual%20en&up_color=007aff&up_message=online&url=https%3A%2F%2Fgithub.com%2Ffuchs-fabian%2Ftypst-template-aio-studi-and-thesis%2Fblob%2Fmain%2Fdocs%2Fmanual-en.pdf" />
  </a>
  <a href="https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/blob/main/docs/example-de-thesis.pdf">
    <img alt="Example DE" src="https://img.shields.io/website?down_message=offline&label=example%20de&up_color=007aff&up_message=online&url=https%3A%2F%2Fgithub.com%2Ffuchs-fabian%2Ftypst-template-aio-studi-and-thesis%2Fblob%2Fmain%2Fdocs%2Fexample-de-thesis.pdf" />
  </a>
  <a href="https://github.com/fuchs-fabian/typst-template-aio-studi-and-thesis/blob/main/docs/example-en-thesis.pdf">
    <img alt="Example EN" src="https://img.shields.io/website?down_message=offline&label=example%20en&up_color=007aff&up_message=online&url=https%3A%2F%2Fgithub.com%2Ffuchs-fabian%2Ftypst-template-aio-studi-and-thesis%2Fblob%2Fmain%2Fdocs%2Fexample-en-thesis.pdf" />
  </a>
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

You can use this template in the Typst web app by clicking “Start from template” on the dashboard and searching for `aio-studi-and-thesis`.

Alternatively, you can use the CLI to kick this project off using the command

```bash
typst init @preview/aio-studi-and-thesis
```

Typst will create a new directory with all the files needed to get you started.

## Usage

The template ([rendered PDF (DE)](docs/example-de-thesis.pdf)) contains thesis writing advice (in German) as example content.

If you are looking for the details of this template package's function, take a look at the [german manual](docs/manual-de.pdf) or the [english manual](docs/manual-en.pdf).

> Roboto is used as the default font. Please note accordingly if you want to use exactly this font.

## Example configuration

```typ
#import "@preview/aio-studi-and-thesis:0.1.0": *

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

[![Paypal](https://www.paypalobjects.com/de_DE/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=4G9X8TDNYYNKG)
