# put-thesis

The official Typst template for writing theses for Poznań University of
Technology. Based on
[PUT Dissertation Template](https://www.overleaf.com/latex/templates/put-dissertation-template/dpqxdndmgkpg)
by Dawid Weiss, Marta Szachniuk and Maciej Komosiński (2022), as well as
[Jak pisać prace dyplomowe - uwagi o formie](http://www.cs.put.poznan.pl/mdrozdowski/dyd/txt/jak_mgr.html)
by prof. Maciej Drozdowski (2006).

The template supports Bachelor's and Master's theses, in Polish or English. It
was adapted from a template for the faculty of Computing and Telecommunications
(WIiT), but it attempts to be as unopinionated as possible, and should be easily
adjustable to any faculty or field of study.

## Usage
There are a few ways this template can be used.

### 1. Local copy (Linux, Windows, macOS)
This assumes you already have Typst installed on your system.

1. Download this repository.
2. Copy the contents into:
    - **Linux**: `${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/preview/put-thesis/`
    - **Windows**: `%APPDATA%/typst/packages/preview/put-thesis/`
    - **macOS**: `~/Library/Application Support/typst/packages/preview/put-thesis/`
    - see the official guidelines at [typst/packages/README#local-packages](https://github.com/typst/packages?tab=readme-ov-file#local-packages)
3. Run `typst init @preview/put-thesis:0.1.0`.
4. A new directory `put-thesis` containing the default template should be
   created. Use it as a starting point for your document.

The template relies on 3rd party packages that need to be downloaded from the
internet. If you wish to work fully offline, be sure to compile the document at
least once with internet access. Typst caches downloaded packages locally (see
[typst/packages/README#downloads](https://github.com/typst/packages?tab=readme-ov-file#downloads)),
so after that you should be good to go.

### 2. Typst Online Editor (requires sign-in)
Coming soon!

## Acknowledgements
The Typst implementation was partially inspired by RefDevX's
[kthesis-typst](https://github.com/RafDevX/kthesis-typst), distributed under
the MIT license.
