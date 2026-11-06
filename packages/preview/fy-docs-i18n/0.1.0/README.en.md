# fy-docs-i18n

[简体中文](README.md) | English

Load, query, and report errors with multilingual text in Typst. Store translations in TOML files, select an item by key, and choose a translation using configurable language matchers. This package is independent of document layout, palettes, and other fy-docs packages. It does not automatically read the language from `context`.

Requires Typst 0.15.1 or later. Import version 0.1.0 as `@preview/fy-docs-i18n:0.1.0`.

## Quick start

```typst
#import "@preview/fy-docs-i18n:0.1.0": *

#let dict = (
  greeting: ("zh-Hans": "你好", en: "Hello"),
  invalid-input: ("zh-Hans": "输入无效", en: "Invalid input"),
)
#let i18n = i18n-config(matchers: (language => language == "en",))
#let item = (i18n.item-from)(dict, "greeting")
#(i18n.item-get)(item)

// To stop execution, query your own error dictionary by key:
// (i18n.panic)(dict, "invalid-input")
```

## Data and language matching

A multilingual dictionary (dict) has the contract `dictionary<key: str, item>`. A multilingual item (item) has the contract `dictionary<language: str, text: str>`. Both are ordinary Typst dictionaries without wrapper fields. Language names must be non-empty strings. `(:)` is an empty dictionary, and an empty string is a valid translation.

`matchers` is an array of functions, each accepting a language string and returning bool. Matching follows matcher order first, then language order within the item. The first true result selects the corresponding text. If one matcher accepts several languages, the first dictionary entry wins.

The default matchers for all public functions are: exact `zh-Hans`, the `zh` prefix, and exact `en`, in that order. Language names are case-sensitive. An empty matcher array matches nothing. Put exact matchers before prefix matchers. When a prefix matches several languages, dictionary order still determines the result; add exact matchers for any preferred region or writing system.

## Public functions

### `i18n-dict-from(files, allow-missing: false, matchers: ...)`

Loads translations from a dictionary mapping language names to file paths. Each path accepts a string or `path`. The dictionary keys supply the language names directly, independently of filenames; they are case-sensitive and must be non-empty.

```typst
#let dict = i18n-dict-from((
  en: path("i18n/en.toml"),
  "zh-Hans": path("i18n/zh-Hans.toml"),
))
```

Each TOML file contains translation keys directly, without a wrapper table. For example, `en.toml`:

```toml
greeting = "Hello"
invalid-input = "Invalid input"
```

And `zh-Hans.toml`:

```toml
greeting = "你好"
invalid-input = "输入无效"
```

The first file supplies the baseline set of keys. By default, each subsequent file is checked immediately for added or missing keys. With `allow-missing: true`, the function combines the translations actually supplied, without filling missing values. Translation values must be strings. An empty file dictionary `(:)` returns an empty dictionary. Typst's TOML parser handles duplicate keys within a file.

String paths resolve relative to the package's `dict.typ`; root-relative strings use that file's project or package root. A `path` retains the location where it was created. To read files from a user's project, create `path("...")` in the calling file and pass it to the package. Strings and paths can coexist in the same file dictionary. Paths may include directories, and filenames do not need to match language names.

### `i18n-item-from(dict, key, allow-empty: false, matchers: ...)`

Validates the multilingual dictionary and string key, then returns the corresponding item. A missing key causes an error by default; `allow-empty: true` returns an empty item `(:)`. `matchers` selects the language of validation errors.

### `i18n-item-get(item, matchers: ..., allow-empty: false)`

Validates the item and queries it in matcher order, returning a string. No match causes an error by default; `allow-empty: true` returns `none`. Empty strings are not treated as missing translations.

### `i18n-panic(dict, key, matchers: ...)`

Extracts the item for the key from a user-supplied multilingual dictionary, selects its text, and immediately calls Typst's `panic`. You can supply arbitrary error keys and translations without using the package's internal error resources. An invalid dictionary, missing key, or unmatched translation first produces the corresponding validation or query error.

### `i18n-config(matchers: ...)`

Validates and captures the matcher array, returning a dictionary containing four functions: `dict-from`, `item-from`, `item-get`, and `panic`. Their parameters match the corresponding public functions. They use the captured matchers by default; individual calls can override them with the `matchers` named argument.

Call a stored function as `(i18n.item-get)(item)`. The configuration does not read `context` or create deferred content. Use it to apply the same language strategy to ordinary text and errors.

## Validation and error messages

All public functions validate parameter types and the contents of dictionaries and arrays. Internal type checkers return bool and are not exported through `lib.typ`. Matcher results are checked for bool after invocation; unused matchers are not executed in advance.

The package's own validation errors have Simplified Chinese and English translations selected by the current matching strategy. If no internal error language matches, they fall back to Simplified Chinese. Invalid matcher structures or non-boolean results produce a fixed Chinese error, avoiding recursive calls to the failing matchers. Matchers should be pure functions. Typst reports function signature errors, exceptions within functions, file access failures, and TOML parsing errors itself.

## Local checks and CI

Run from the package directory in the [development repository](https://github.com/Fengyang-Conglomerate/fy-docs-typst-i18n) (test scripts are not included in the preview package):

```sh
typstyle --check .
python3 tests/run.py
```

Use typstyle 0.15.1, Python 3.11 or later, and Typst on PATH. Apply formatting with `typstyle -i .`.

The test script locates source files relative to itself, compiles in a system temporary directory, and cleans up automatically. It is independent of the current directory, repository name, and neighboring projects. Tests cover validation, language matching, configuration binding and overrides, file loading, custom bilingual errors, and isolated versioned package imports. They also check that internal error translations share the same keys and placeholders.

GitHub Actions runs format checks and integration tests on push, pull requests, and manual dispatch. The typstyle download is pinned and verified with SHA-256. The workflow has only `contents: read` permissions and does not publish or push.

The manifest excludes tests, CI, and Git metadata while retaining runtime source, error resources, and documentation. This package is licensed under MIT OR Apache-2.0, at your option. See [LICENSE-MIT](LICENSE-MIT) and [LICENSE-APACHE](LICENSE-APACHE) for the full terms.
