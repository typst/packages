
# Tidy
*Keep it tidy.*

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FMc-Zen%2Ftidy%2Fv0.4.2%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/tidy)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Mc-Zen/tidy/blob/main/LICENSE)
[![Test Status](https://github.com/Mc-Zen/tidy/actions/workflows/run_tests.yml/badge.svg)](https://github.com/Mc-Zen/tidy/actions/workflows/run_tests.yml)
[![User Manual](https://img.shields.io/badge/manual-.pdf-purple)][guide]




**tidy** is a package that generates documentation directly in [Typst](https://typst.app/) for your Typst modules. It parses doc-comments and can be used to easily build a reference section for a module.  Doc-comments use Typst syntax − so markup, equations and even figures are no problem!

----
**IMPORTANT**

In version 0.4.0, the default documentation syntax has changed. You can take a look at the [migration guide][migration guide] or revert to the old syntax with `tidy.parse-module(old-syntax: true, ...)`. 

You can still find the documentation for the old syntax in the [0.3.0 user guide](https://github.com/Mc-Zen/tidy/releases/download/v0.3.0/tidy-guide.pdf). 

----

Features:
- **Customizable** output styles. 
- Automatically [**preview code examples**](#example). 
- **Annotate types** of parameters and return values.
- **Cross-references** to definitions and function parameters. 
- Automatically read off default values for named parameters.
- [**Help** feature](#generate-a-help-command-for-you-package) for your package. 
- [Doc-tests](#doc-tests). 


The [guide][guide] fully describes the usage of this module and defines documentation syntax. 

## Usage

Using `tidy` is as simple as writing some doc-comments and calling:
```typ
#import "@preview/tidy:0.4.2"

#let docs = tidy.parse-module(read("my-module.typ"))
#tidy.show-module(docs, style: tidy.styles.default)
```

The available predefined styles are currently `tidy.styles.default` and `tidy.styles.minimal`. Custom styles can be added by hand (take a look at the [user guide][guide]). 

## Example

A full example on how to use this module for your own package (maybe even consisting of multiple files) can be found at [examples](https://github.com/Mc-Zen/tidy/tree/main/examples).

```typ
/// This function computes the cardinal sine, $sinc(x)=sin(x)/x$. 
///
/// ```example
/// #sinc(0)
/// ```
///
/// -> float
#let sinc(
  /// The argument for the cardinal sine function. 
  /// -> int | float
  x
) = if x == 0 {1} else {calc.sin(x) / x}
```

**tidy** turns this into:

<div align="center">

  ![Tidy example output](https://github.com/user-attachments/assets/e145ca9f-12ab-41ed-a392-80785b29a880)

</div>


## Access user-defined functions and images

The code in the doc-comments is evaluated through the [`eval`](https://typst.app/docs/reference/foundations/eval/) function. In order to access user-defined functions and images, you can make use of the `scope` argument of `tidy.parse-module()`:

```typ
#{
    import "my-module.typ"
    let module = tidy.parse-module(read("my-module.typ"))
    let an-image = image("img.png")
    tidy.show-module(
        module,
        style: tidy.styles.default,
        scope: (my-module: my-module, img: an-image)
    )
}
```
The doc-comments in `my-module.typ` may now access the image with `#img` and can call any function or variable from `my-module` in the style of `#my-module.my-function()`. This makes rendering examples right in the doc-comments as easy as a breeze!

## Generate a help command for you package
With **tidy**, you can add a help command to you package that allows users to obtain the documentation of a specific definition or parameter right in the document. This is similar to CLI-style help commands. If you have already written doc-comments for your package, it is quite low-effort to add this feature. Once set up, the end-user can use it like this:

```typ
// happily coding, but how do I use this one complex function again?

#mypackage.help("func")
#mypackage.help("func(param1)") // print only parameter description of param1
```

This will print the documentation of `func` directly into the document — no need to look it up in a manual. Read up on setup instructions in the [user guide][guide]. 

## Doc-tests
It is possible to add simple doc-tests — assertions that will be run when the documentation is generated. This is useful if you want to keep small tests and documentation in one place. 
```typ
/// #test(
///   `num.my-square(2) == 4`,
///   `num.my-square(4) == 16`,
/// )
#let my-square(n) = n * n
```
<!-- With the short-hand syntax, a unfulfilled assertion will even print the line number of the failed test:
```typ
/// >>> my-square(2) == 4
/// >>> my-square(4) == 16
#let my-square(n) = n * n
``` -->
A few test assertion functions are available to improve readability, simplicity, and error messages. Currently, these are `eq(a, b)` for equality tests, `ne(a, b)` for inequality tests and `approx(a, b, eps: 1e-10)` for floating point comparisons. These assertion helper functions are always available within doc-comment tests. 


## Changelog

### v0.4.2
_Fixes and Improvements_
- Code examples can now also show code that is _not_ executed on lines starting with `<<<`. 
- The type `tiling` is now supported and it is shown with the new gradient. 
- Fixes formatting of multiline default arguments. 

### v0.4.1
_Fixes_
- Strings containing `"//"` can now be used in default arguments.
- References like `@section` can now link to labels outside the documentation. 
- Fixes issues with upcoming Typst 0.13.

### v0.4.0
_Major redesign of the documentation syntax_
- New features
  - New parser for the new documentation syntax. The old parser is still available and can be activated via `tidy.parse-module(old-syntax: true)`. There is a [migration guide][migration guide] for adopting the new syntax. 
  - Cross-references to function arguments.
  - Support for detecting _curried functions_, i.e., function aliases with prepended arguments using the `.with()` function. 
  

### v0.3.0
_Adds a help feature and more options_
- New features:
  - Help feature. 
  - `preamble` option for examples (e.g., to add `import` statements). 
  - more options for `show-module`: `omit-private-definitions`, `omit-private-parameters`, `enable-cross-references`, `local-names` (for configuring language-specific strings). 
- Improvements:
  - Allow using `show-example()` as standalone. 
  - Updated type names that changed with Typst 0.8.0, e.g., integer -> int. 
- Fixes:
  - allow examples with ratio widths if `scale-preview` is not `auto`.
  - `show-outline`
  - explicitly use `raw(lang: none)` for types and function names. 

### v0.2.0
- New features:
  - Add executable examples to doc-comments. 
  - Documentation for variables (as well as functions). 
  - Doc-tests. 
  - Rainbow-colored types `color` and `gradient`. 
- Improvements:
  - Allow customization of cross-references through `show-reference()`. 
  - Allow customization of spacing between functions through styles. 
  - Allow color customization (especially for the `default` theme). 
- Fixes:
  - Empty parameter descriptions are omitted (if the corresponding option is set). 
  - Trim newline characters from parameter descriptions. 
- ⚠️ Breaking changes:
  - Before, cross-references for functions using the `@@` syntax could omit the function parentheses. Now this is not possible anymore, since such references refer to variables now. 
  - (only concerning custom styles) The style functions `show-outline()`, `show-parameter-list`, and `show-type()` now take `style-args` arguments as well. 

### v0.1.0

_Initial Release_

[guide]: https://github.com/Mc-Zen/tidy/releases/download/v0.4.2/tidy-guide.pdf

[migration guide]: https://github.com/Mc-Zen/tidy/tree/v0.4.2/docs/migration-to-0.4.0.md