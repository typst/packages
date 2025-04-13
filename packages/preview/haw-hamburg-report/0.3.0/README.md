# HAW Hamburg Typst Template

This is an **`unofficial`** template for writing a report in the `HAW Hamburg` department of `Computer Science` design using [Typst](https://github.com/typst/typst).

## Required Fonts

To correctly render this template please make sure that the `New Computer Modern` font is installed on your system.

## Usage

To use this package just add the following code to your [Typst](https://github.com/typst/typst) document:

```typst
#import "@preview/haw-hamburg:0.3.0": report

#show: report.with(
  language: "en",
  title: "Example title",
  author:"Example author",
  faculty: "Engineering and Computer Science",
  department: "Computer Science",
  include-declaration-of-independent-processing: true,
)
```

## How to Compile

This project contains an example setup that splits individual chapters into different files.\
This can cause problems when using references etc.\
These problems can be avoided by following these steps:

- Make sure to always compile your `main.typ` file which includes all of your chapters for references to work correctly.
- VSCode:
  - Install the [Tinymist Typst](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) extension.
  - Make sure to start the `PDF` or `Live Preview` only from within your `main.typ` file.
  - If problems occur it usually helps to close the preview and restart it from your `main.typ` file.
