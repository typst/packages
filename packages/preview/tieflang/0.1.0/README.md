# TiefLang

TiefLang is a namespaced, stack-based language resolver with dictionary-backed keys. Essentially a modular translation engine for Typst templates. If your template is multilingual, you need TiefLang. Otherwise, you're out here writing your own translation system, in which case... Wowie. Gz. Please use a library ;)

## Setup

Import the library:

```typst
#import "@preview/tieflang:0.1.0": (
  configure-translations, tr, // These you'll always need
  pop-lang, push-lang, trk, // These are optional
  select-language, // You should only import this if you plan to expose select-language. See the common pitfalls section.
)
```

First, create a dictionary with your translations like so:

```typst
#let translations = (
  de-DE: (
    key1: [Bahnhofsstraße 1],
    key2: (
      subkey1: [Wohnung 1],
      subkey2: [Wohnung 2],
    ),
  ),
  de-CH: (
    key1: [Bahnhofsstrasse 1],
    key2: (
      subkey1: [Top 1],
      subkey2: [Top 2],
    ),
  ),
  en-US: (
    key1: [Bahnhof Street 1],
    key2: (
      subkey1: [Flat 1],
      subkey2: [Flat 2],
    ),
  ),
)
```

Then simply call `configure-translations(translations)`. This is sufficient for mono-templates that don't call other libraries using TiefLang.

The language codes used here can be anything and are not bound to 'xx-XX'. There are currently no fallback mechanisms. Be sure to document your available language codes, best practice is to create a dictionary with the available ones like so:

```typst
#let languages = (
  de-DE: "de-DE",
  de-CH: "de-CH",
  en-US: "en-US",
  german: "de-DE",
  german-germany: "de-DE",
  german-switzerland: "de-CH",
  english-united-states: "en-US",
)
```

This way, users have a human readable and type friendly interface for interacting with the internationalizations.

## Usage

Access your translations using the `tr` command:

```typst
// These produce the same output!
#tr().key1
#tr("key1")
#trk("key1")
```

That is the basic usecase, probably enough for most templates. `trk()` works identically to `tr(key)`, the latter being syntactic sugar.

## User facing

You have two options when it comes to user facing APIs. Either expose a `lang` parameter in your template and call `push-lang(lang)` or instruct the user to select their language using the `push-lang`/`select-lang` methods (these are currently aliases).

If you chose to call push-lang yourself, I recommend calling `pop-lang(lang)` after it as to allow nested language changes to work.

*In the background, the languages are a stack. Do not call `pop-lang` without first pushing a language.*

## Advanced

### `tr` vs `trk`

`tr()` with no arguments returns the translation dictionary for the current language in the namespace. `trk("key")` is always a direct key lookup.

However, `tr("key")` also works and simply delegates the lookup to the `trk()` function.

```typst
// All produce the same output
#tr().key1
#tr("key1")
#trk("key1")
```

### Nested keys and dot notation

Keys can be nested in dictionaries and accessed using dot notation.

```typst
#trk("key2.subkey1")
```

Similarly, `tr()` can be used with nested keys:

```typst
#tr().key2.subkey1
```

### Function values and arguments

Translations can be functions. When the value is a function, `tr`/`trk` call it with any extra arguments you pass.

```typst
#let translations = (
  en-US: (
    welcome: (name) => [Hello #name],
  ),
)

#configure-translations(translations)
#trk("welcome", "Lena") // Outputs Hello Lena
#(tr().welcome)("Lena") // Also outputs Hello Lena
```

### Namespaces

If you have multiple libraries using TiefLang, keep their translations separate with namespaces. Each `configure-translations` call stores data under a namespace, and you then pass that namespace to `tr`/`trk`.

```typst
#configure-translations(core, namespace: "core")
#configure-translations(ui, namespace: "ui")

#tr("title", namespace: "ui")
```

### Language stack semantics

Languages are a stack. `push-lang` pushes a language on top, and `pop-lang` removes the top entry. `select-language` and `restore-language` are aliases.

```typst
#push-lang("de-DE")
#tr("key1")
#pop-lang()
```

### Strict mode and missing keys

By default, missing keys return a bold red placeholder like `??? key ???`. If you want missing keys to be hard errors, enable strict mode. **Strict mode is recommended for production templates, but will break builds on missing keys.**

```typst
#configure-translations(translations, strict: true)
```

### Multiple configuration calls

Calling `configure-translations` multiple times is fine as long as each namespace is distinct. Each namespace keeps its own language list, default language, and translation dictionary.

### Default language and fallback

You can set a default language per namespace. If the language stack is empty, this default is used.

```typst
#configure-translations(translations, default: "de-CH")
#tr("key1") // uses de-CH if no language was pushed
```

### Unknown languages

If you try to use a language that doesn't exist in the current namespace, TiefLang throws an error: `Language definition for 'xx-YY' does not exist.`

## Common pitfalls

There's pitfalls I have to document because otherwise, someone is going to make an issue. Excuse the sass, you try figuring out what all can break on your 5th coffee.

### "How did I do the language setting???" ~ Some user

You don't *have* to set languages in your template. Sometimes, not always, it's better if you don't. But then, you need to do one of the following:

- Import and expose `select-language` from your template and tell the user to use it. This is the preferred way if you're building a standalone template, as it's easier on the user.
- Let the user `#import "@preview/tieflang:0.1.0": select-language`. This is preferred if you are building a package that isn't a standalone template, as it does not contaminate the exports.

For more information, you may contact me for typst best practices.

### pop-lang is pulling from a stack

Calling `pop-lang` without a matching `push-lang` will throw an error.

### Language codes must exist

Using a language code that is not in your translations will error immediately.

### Default locale is en-US

Forgetting to set `default` means TiefLang falls back to `en-US` for that namespace.

Remember to either set default or accept that `en-US` is your default locale and don't forget that it is then essentially required.

### Nested keys are not magic

Nested keys require dot notation; `"key2.subkey1"` is not the same as `"key2"` or `"subkey1"`.

## Strict mode is kinda important

In non-strict mode, missing keys render as `??? key ???` instead of failing fast.
