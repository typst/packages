# Typst-linguify

Load strings for different languages easily. This can be useful if you create a package or template for multilingual usage. See the [gentle-clues package](https://github.com/jomaway/typst-gentle-clues) as an example.

## Usage

```typst
#import "@preview/linguify:0.3.0": *

#let lang_data = toml("lang.toml")
#linguify_set_database(lang_data);

#set text(lang: "de")

#linguify(abstract)  // Shows "Zusammenfassung" in the document.
```

The `lang.toml` musst look like this:

```toml
default-lang = "en"

[en]
title = "A simple linguify example"
abstract = "Abstract"

[de]
title = "Ein einfaches Linguify Beispiel"
abstract = "Zusammenfassung"
```

## Features

- Use a `toml` or other file to load strings for different languages. You need to pass a typst dictionary whichs follows the structure of the shown toml file.
- Specify a **default-lang**. If none is specified it will default to `en`
- **Fallback** to the default-lang if a key is not found for a certain language.