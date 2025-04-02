# Blinky: Bibliography Linker for Typst

This package permits the creation of Typst bibliographies in which paper titles are typeset as hyperlinks. Here's an example (with links typeset in blue):

<center>
<img src="https://github.com/alexanderkoller/typst-blinky/blob/main/examples/screenshot.png" width="80%" />
</center>

The bibliography is generated from a Bibtex file, and citations are done with the usual Typst mechanisms. The hyperlinks are specified through DOI or URL fields in the Bibtex entries; if such a field is present, the title of the entry will be automatically typeset as a hyperlink.

See [here](https://github.com/alexanderkoller/typst-blinky/tree/main/examples) for a full example.


## Usage

Adding hyperlinks to your bibliography is a two-step process: (a) use a CSL style with magic symbols (explained below), and (b) enclose the `bibliography` command with the `link-bib-urls` function:

```
#import "@preview/blinky:0.2.0": link-bib-urls

... @cite something ... @cite more ...

#link-bib-urls()[
  #bibliography("custom.bib", style: "./association-for-computational-linguistics-blinky.csl")
]
```

If a Bibtex entry contains a DOI field, the title will become a hyperlink to the DOI. Otherwise, if the Bibtex entry contains a URL field, the title will become a hyperlink to this URL. Otherwise, the title will be shown as normal, without a link.

The `link-bib-urls` accepts an optional argument `link-fill`. You can pass a color to make Typst set all the generated hyperlinks in this color. Example: `#link-bib-urls(link-fill: blue)[ ... ]`.


## CSL with magic expressions

Blinky generates the hyperlinked titles through a regex show rule that replaces a "magic expression" with a [link](https://typst.app/docs/reference/model/link/) command. This "magic expression" is a string of the form `<<<URL|||title>>>`, where `URL` is the URL to which the title should link and `title` is the title of the paper.

You will therefore need to tweak your CSL style to use it with Blinky. Specifically, in every place where you would usually have the paper title, i.e.

```
<text variable="title" prefix=" " suffix=". "/>
```

or similar, your CSL file now instead needs to print the magic expression:

```
<text variable="URL" prefix=" <<<" suffix="|||" />
<text variable="title" suffix=">>>. " />
```

Note how the prefix and suffix of the original title were added to the prefix and suffix of the magic expression.

You can define a [CSL macro](https://docs.citationstyles.org/en/stable/specification.html#macro) that will generate the magic expression and then use it everywhere that the original CSL printed a paper title.

Instead of the magic expression `<<<URL|||title>>>`, you can instead use the magic expression `<_<URL|||title>_>`. This will also link the title to the URL, but it will typeset the title in italics. Please avoid all other formatting in the CSL, as this will interfere with the regex matching that blinky performs.

You can check the [example CSL file](https://github.com/alexanderkoller/typst-blinky/blob/main/examples/association-for-computational-linguistics-blinky.csl) to see what this looks like in practice; compare to [the unmodified original](https://github.com/citation-style-language/styles/blob/master/association-for-computational-linguistics.csl).



## Blinky <= 0.1.1

Blinky versions before 0.2.0 used a different magic expression of the form `!!BIBENTRY!<key>!!` and a custom WASM plugin to resolve the paper key to a hyperlinked title. This was a cumbersome solution that required reading every bibliography file multiple times. Changes made in Typst 0.12 allowed us to simplify how Blinky operates.

At the same time, the step from Blinky 0.1.1 to 0.2.0 was a breaking change to the format of the CSL files. CSL files with magic expressions for Blinky 0.1.1 will no longer work with Blink 0.2.0.


## Contributors

Thank you to:

- [Philipp](https://forum.typst.app/u/philipp/summary) for pointing me in the right direction with the new magic expressions of Typst 0.2.0.
- [scrouthtv](https://github.com/scrouthtv) for contributing a pull request that fixed [#5](https://github.com/alexanderkoller/typst-blinky/issues/5) (cbor decoding in Typst 0.13)


## Compiling plugin from scratch

(This is deprecated, but perhaps useful if we want to resurrect the plugin.)

```
brew install rustup
rustup default stable
rustup target add wasm32-unknown-unknown
cd plugin/blinky/plugin
cargo build --target wasm32-unknown-unknown --release
```

Do _not_ install rust directly, see [here](https://stackoverflow.com/questions/66252428/errore0463-cant-find-crate-for-core-note-the-wasm32-unknown-unknown-t).