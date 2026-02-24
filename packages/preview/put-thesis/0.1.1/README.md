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

### 1. Local copy (Linux, Windows, macOS)

Run:

```sh
typst init @preview/put-thesis
```

The template relies on 3rd party packages that need to be downloaded from the
internet. If you wish to work fully offline, be sure to compile the document at
least once with internet access. Typst caches downloaded packages locally (see
[typst/packages/README#downloads](https://github.com/typst/packages?tab=readme-ov-file#downloads)),
so after that you should be good to go.

### 2. Typst Online Editor

Go to https://typst.app/universe/package/put-thesis and click "Create project in
app".

## Acknowledgements
The Typst implementation was partially inspired by RefDevX's
[kthesis-typst](https://github.com/RafDevX/kthesis-typst), distributed under
the MIT license.
