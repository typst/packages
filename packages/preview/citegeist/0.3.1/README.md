# Citegeist: Direct bibtex access for Typst

This package reads a Bibtex file and returns its contents as as a [Typst dictionary](https://typst.app/docs/reference/foundations/dictionary/). It does not attempt to typeset a bibliography and is not interested in CSL styles; all it does is return the raw Bibtex entries. It leaves all further processing to your Typst code.

Citegeist is a thin wrapper around the [Typst biblatex crate](https://github.com/typst/biblatex), which reads a bibtex file into a Rust data structure. Citegeist simply makes this data structure available to Typst code.


## Usage

Use the `load-bibliography` command to parse a bibtex string into a Typst dictionary:

```
#import "@preview/citegeist:0.3.1": load-bibliography

#let bibtex_string = read("custom.bib")
#let bib = load-bibliography(bibtex_string, source: "custom.bib")

#bib.bender-koller-2020-climbing
```

This will print the bibtex entry for the key `bender-koller-2020-climbing`:

```
(
	entry_type: "inproceedings",
	entry_key: "bender-koller-2020-climbing",
	position: 0,
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
Typst passes only the file contents to Citegeist; `read("custom.bib")` does not automatically reveal the filename. Pass `source: "custom.bib"` if you want parse errors to include a source label.


## Duplicate keys

By default, a duplicate citation key aborts the whole parse with an error.
You can opt in to tolerating duplicates:

```
load-bibliography(bib, on-duplicate: "keep-first")  // drop later duplicates
load-bibliography(bib, on-duplicate: "keep-last")   // drop earlier duplicates
load-bibliography(bib, on-duplicate: "error")       // default
```



## Parsed names

The `parsed_names` entry contains the values of all BibTeX/BibLaTeX name-list fields, as parsed by the Typst biblatex crate. This includes fields such as `author`, `editor`, and `translator`. Each entry in `parsed_names` is an array of name dictionaries; for example, `entry.parsed_names.author.at(0)` is the first parsed author.

Every parsed name dictionary contains these string fields:

- `family`: the surname or family name, e.g. `Rousse` in `Jean de la Rousse`.
- `given`: the given name or forename, e.g. `Jean`.
- `prefix`: a name particle that belongs before the family name, e.g. `de la`. This is often empty.
- `suffix`: a suffix after the family name, e.g. `Jr.`. This is often empty.

BibLaTeX also supports an extended name format where a `.bib` file can attach extra metadata to a name:

```
author = {given=Jean Pierre Simon, given-i=JPS, prefix=de la, prefix-i=d, family=Rousse}
```

Citegeist preserves the following BibLaTeX name options when they are present:

- `given-initials`: manual initials for the given name, from BibLaTeX's `given-i` option. In the example above, this is `JPS`. This is useful when initials should not be computed mechanically from the words in `given`.
- `prefix-initials`: manual initials for the name prefix, from BibLaTeX's `prefix-i` option. In the example above, this is `d` for the prefix `de la`.
- `use-prefix`: a boolean from BibLaTeX's `useprefix` option. It indicates whether the prefix should be treated as part of the family name for bibliography logic such as sorting or label generation.
- `id`: an explicit identity string for the person. This is not normally printed; it gives downstream code a stable way to decide whether two differently written names should be treated as the same person.

Undefined name options are omitted from the name dictionary instead of being represented as `none`.


## Details

The function `load-bibliography` returns a dictionary with one element per bibliography entry in your Bibtex file. The key of the dictionary element is the Bibtex key (in the example, `bender-koller-2020-climbing`); the value is a data structure representing a Bibtex entry.

A Bibtex entry is represented as another dictionary, see the example above. It has five keys: `entry_type` is the Bibtex entry type (e.g. `inproceedings` or `article`); `entry_key` is the key of the Bibtex entry; `position` is the zero-based position of the entry in the bibliography; `parsed_names` contains parsed author/editor/translator names (see below); and `fields` contains all the fields of the Bibtex entry.

If duplicate entries are filtered with `on-duplicate`, `position` is counted after deduplication, so the returned entries are numbered from 0 without gaps.

Iteration over the dictionary returns entries in the order in which they appear in the BibTeX file.


## Efficiency note

Using Citegeist from within Typst is _much_ slower than calling the biblatex crate from Rust. This is because (a) Citegeist converts biblatex data structures into dictionaries that can be processed by Typst (this adds a ~40% time overhead over the Bibtex parsing itself), and (b) Typst plugins are run as [interpreted WASM bytecode](https://typst.app/blog/2025/typst-0.13/#faster-plugins).

In my experiments with Citegeist, interpreted WASM (wasmi) is roughly 15x slower than JIT-compiled WASM (wasmtime), which again is roughly 2x slower than native Rust binaries.
Until Typst finds a way to support JIT-compiled WASM, this is a performance penalty we will have to live with.


## Compilation

To build the WASM plugin:

```
cargo build-wasm
```

This builds the Rust plugin for `wasm32-unknown-unknown` and then runs
Binaryen's `wasm-opt -Oz` on the result. If `wasm-opt` is not on `PATH`, the
command downloads a prebuilt Binaryen release into `.tools/`. Set
`CITEGEIST_WASM_OPT=/path/to/wasm-opt` to use a specific binary, or set
`CITEGEIST_NO_BINARYEN_DOWNLOAD=1` to require a locally installed `wasm-opt`.

To run the tests:

```
cargo test --manifest-path plugin/citegeist/plugin/Cargo.toml
```


## Changelog

## 0.3.1

- Improved Bibtex parsing speed by 3x; thanks to @SchrodingerBlume for reminding me of Rust compile-time optimizations.

## 0.3.0

- Much more informative error reporting.
- Entries are now returned in the order they appear in the `.bib` file (previously the order was unspecified, because entries were stored in a `HashMap`; thanks to @SchrodingerBlume for the pull request).
- Entries now include a zero-based `position` field, counted in the returned entry order after any duplicate filtering.
- New `on-duplicate` parameter: `"error"` (default, unchanged), `"keep-first"`, or `"keep-last"`, controlling how a duplicate citation key is handled instead of always aborting the parse (thanks to SchrodingerBlume for the pull request).
- `parsed_names` now preserves BibLaTeX extended name options as `id`, `given-initials`, `prefix-initials`, and `use-prefix` keys when they are present.
- Bumped biblatex dependency to 0.12.


## 0.2.2

- Performance improvements.
- New parameter `keep-raw-names`: If `false` is passed, the returned dictionary will no longer contain the raw strings for name fields (author, editor, ...). They are still available as parsed data structures.
- New parameter `sentence-case-titles`: If `true` is passed, titles are rewritten to [sentence case](https://apastyle.apa.org/style-grammar-guidelines/capitalization/sentence-case); otherwise the capitalization is retained as in the Bibtex file.


## 0.2.1

- Bumped biblatex to [0.11.0](https://github.com/typst/biblatex/releases/tag/v0.11.0)
for improved parsing of Bibtex files. Thanks to [Y.D.X.](https://github.com/YDX-2147483647) for the pull request!
- Implemented much more careful error handling in the WASM plugin. This should eliminate the dreaded _wasm `unreachable` instruction executed_ error.


## 0.2.0

Expose parsed names to Typst.


## 0.1.0

Initial release.
