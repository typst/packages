# Citegeist: Direct bibtex access for Typst

This package reads a Bibtex file and returns its contents as as a [Typst dictionary](https://typst.app/docs/reference/foundations/dictionary/). It does not attempt to typeset a bibliography and is not interested in CSL styles; all it does is return the raw Bibtex entries. It leaves all further processing to your Typst code.

Citegeist is a thin wrapper around the [Typst biblatex crate](https://github.com/typst/biblatex), which reads a bibtex file into a Rust data structure. Citegeist simply makes this data structure available to Typst code.


## Usage

Use the `load-bibliography` command to parse a bibtex string into a Typst dictionary:

```
#import "@preview/citegeist:0.1.0": load-bibliography

#let bibtex_string = read("custom.bib")
#let bib = load-bibliography(bibtex_string)

#bib.bender-koller-2020-climbing
```

This will print the bibtex entry for the key `bender-koller-2020-climbing`:

```
(
	entry_type: "inproceedings",
	entry_key: "bender-koller-2020-climbing",
	fields: (
		abstract: "The success of the large neural language models ...",
		doi: "10.18653/v1/2020.acl-main.463",
		editor: "Jurafsky, Dan and Chai, Joyce and Schluter, Natalie and Tetreault,
		Joel",
		month: "July",
		pages: "5185–5198",
		publisher: "Association for Computational Linguistics",
		title: "Climbing towards NLU: On Meaning, Form, and Understanding in the Age of
		Data",
		url: "https://aclanthology.org/2020.acl-main.463",
		year: "2020",
	),
)
```

Note that you have to `read` the contents of the Bibtex file yourself, because Typst packages can only read files within the package.


## Details

The function `load-bibliography` returns a dictionary with one element per bibliography entry in your Bibtex file. The key of the dictionary element is the Bibtex key (in the example, `bender-koller-2020-climbing`); the value is a data structure representing a Bibtex entry.

A Bibtex entry is represented as another dictionary, see the example above. It has three keys: `entry_type` is the Bibtex entry type (e.g. `inproceedings` or `article`); `entry_key` is the key of the Bibtex entry; and `fields` contains all the fields of the Bibtex entry.

