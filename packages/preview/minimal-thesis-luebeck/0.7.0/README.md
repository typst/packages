# minimal thesis template

This repo contains a minimalistic template for writing a thesis.
The main objective of the template is to produce a nice document with as little code as possible. No nonsense, no extras.

While this is **not** an official template for the "Universität zu Lübeck", it is loosely inspired by its official LaTeX template by Till Tantau.
The official LaTeX template is a lot prettier.
However, it is also more code.

To be clear: Using this template does not guarantee any compliance with university standards.
Consult your advisor for tips and rules on writing a thesis.

## Installation

### Typst web application

Just select this template by its name and version and start writing!

### Typst CLI (local)

In your CLI, navigate to your empty project directory and use `typst init @preview/minimal-thesis-luebeck:<version>` with `<version>` being the current version (e.g. `0.7.0`).
I recommend using VS Code and the [tinymist extension](https://github.com/Myriad-Dreamin/tinymist) for working with a local installation.

## Usage

When installed, this template provides you with a `thesis.typ` file.
This is where you write your thesis.

Note that by default this template is configured to write thesis using english language in a german environment. However, you can exchange all strings in the template to match your preferred languages.

_Hint_: You can take a look at `tutorial.typ` if you are new to Typst.

## Template Contents
- **thesis.typ**: The central document that finally produces your PDF document. Initially, this includes `tutorial.typ` to give some examples. Just remove the tutorial when you start working.
- **thesis.bib**: The bibliography. Put your references here.
- **texts**: Contains texts that are separate from your main thesis such as the abstract. If you like, you can also put chapters of your thesis here. Personally however, I like having everything in one place.
- **images**: Contains all images. You should replace the example images with your own. Also, you might need to adjust some sizes afterwards (`config/titlepage.typ`).

## Credits

This template is inspired by this one: [thesis-template-typst
](https://github.com/ls1intum/thesis-template-typst?tab=MIT-1-ov-file#readme)

The example image of a cat was generated using OpenAI's DALL-E.
