# Typst-linguify

Load strings for different languages easily. This can be useful if you create a package or template for multilingual usage. 

## Usage

The usage depends if you are using it inside a package or a template or in your own document.

### For end users and own templates

You can use linguify global database.

Example:
```typst
#import "@preview/linguify:0.4.0": *

#let lang_data = toml("lang.toml")
#linguify_set_database(lang_data);

#set text(lang: "de")

#linguify("abstract")  // Shows "Zusammenfassung" in the document.
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

### Inside a package

So that multiple packages can use linguify simultaneously, they should contain their own database. A linguify database is just a dictionary with a certain structure. (See database structure.)

Recommend is to store the database in a separate file like `lang.toml` and load it inside the document. And specify it in each `linguify()` function call.

Example: 
```typ
#import "@preview/linguify:0.4.0": *

#let database = toml("lang.toml")

#linguify("key", from: database, default: "key")
```

## Features

- Use a `toml` or other file to load strings for different languages. You need to pass a typst dictionary which follows the structure of the shown toml file.
- Specify a **default-lang**. If none is specified it will default to `en`
- **Fallback** to the default-lang if a key is not found for a certain language.
- [Fluent](https://projectfluent.org) support 
