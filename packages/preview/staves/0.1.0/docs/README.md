# Documentation

This folder contains the documentation for the package.

To view the documentation (e.g. in a browser on GitHub), look at [docs.pdf](docs.pdf) or [docs.md](docs.pdf).
These are generated from `docs.typ`.

Typst Universe is a bit odd. They require documentation as Markdown, not Typst.
So I have written `../build-docs.sh` to convert from Typst to markdown.
(So I can still write the docs in Typst. This way I can ensure correctness. e.g. take a variable such as `all-clefs`, and use it in the docs. So when I add a new clef, it will be automatically added to the docs.)

For the staves themselves, I needed to separate each chunk of code into a separate `.typ` file (in `examples/`), because `pandoc` can't handle imports of `cetz`. For markdown, I use a png image of each code sample. This was a bit tedious to set up the scripting for, but should be straightforward for any new examples.

I commit the compiled doc artefacts into git, because that seems to be the convention for Typst packages.
