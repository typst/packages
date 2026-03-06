# Citegeist: Direct bibtex access for Typst

This package reads a Bibtex file and returns its contents as as a [Typst dictionary](https://typst.app/docs/reference/foundations/dictionary/). It does not attempt to typeset a bibliography and is not interested in CSL styles; all it does is return the raw Bibtex entries. It leaves all further processing to your Typst code.

Citegeist is a thin wrapper around the [Typst biblatex crate](https://github.com/typst/biblatex), which reads a bibtex file into a Rust data structure. Citegeist simply makes this data structure available to Typst code.


## Usage

Use the `load-bibliography` command to parse a bibtex string into a Typst dictionary:

```
#import "@preview/citegeist:0.2.1": load-bibliography

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
		abstract: "The success of the large neural language models on many NLP tasks is
		exciting. However, we find that these successes sometimes lead to hype in which these
		models are being described as ``understanding'' language or capturing ``meaning''. In
		this position paper, we argue that a system trained only on form has a priori no way
		to learn meaning. In keeping with the ACL 2020 theme of ``Taking Stock of Where We've
		Been and Where We're Going'', we argue that a clear understanding of the distinction
		between form and meaning will help guide the field towards better science around
		natural language understanding.",
		address: "Online",
		author: "Bender, Emily M. and Koller, Alexander",
		booktitle: "Proceedings of the 58th Annual Meeting of the Association for
		Computational Linguistics",
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
	parsed_names: (
		author: (
			(family: "Bender", given: "Emily M.", prefix: "", suffix: ""),
			(family: "Koller", given: "Alexander", prefix: "", suffix: "")
		),
		editor: (
			(family: "Jurafsky", given: "Dan", prefix: "", suffix: ""),
			(family: "Chai", given: "Joyce", prefix: "", suffix:"")
		)
	)
)
```

Note that you have to `read` the contents of the Bibtex file yourself, because Typst packages can only read files within the package.


## Details

The function `load-bibliography` returns a dictionary with one element per bibliography entry in your Bibtex file. The key of the dictionary element is the Bibtex key (in the example, `bender-koller-2020-climbing`); the value is a data structure representing a Bibtex entry.

A Bibtex entry is represented as another dictionary, see the example above. It has three keys: `entry_type` is the Bibtex entry type (e.g. `inproceedings` or `article`); `entry_key` is the key of the Bibtex entry; and `fields` contains all the fields of the Bibtex entry.

The `parsed_names` entry contains the values of all name-list fields, as parsed by the biblatex crate.
The crate is pretty good at respecting the different ways in which names can be specified in the
original Biblatex.

## Changelog

## 0.2.1

- Bumped biblatex to [0.11.0](https://github.com/typst/biblatex/releases/tag/v0.11.0)
for improved parsing of Bibtex files. Thanks to [Y.D.X.](https://github.com/YDX-2147483647) for the pull request!
- Implemented much more careful error handling in the WASM plugin. This should eliminate the dreaded _wasm `unreachable` instruction executed_ error.

## 0.2.0

Expose parsed names to Typst.

## 0.1.0

Initial release.
