
# Tidy
*Keep it tidy.*

[![Typst Package](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2FMc-Zen%2Ftidy%2Fmain%2Ftypst.toml&query=%24.package.version&prefix=v&logo=typst&label=package&color=239DAD)](https://typst.app/universe/package/tidy)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Mc-Zen/tidy/blob/main/LICENSE)
[![User Manual](https://img.shields.io/badge/manual-.pdf-purple)][guide]


**tidy** is a package that generates documentation directly in [Typst](https://typst.app/) for your Typst modules. It parses docstring comments similar to javadoc and co. and can be used to easily build a beautiful reference section for the parsed module.  Within the docstring you may use (almost) any Typst syntax − so markup, equations and even figures are no problem!

Features:
- **Customizable** output styles. 
- Automatically [**render code examples**](#example). 
- **Annotate types** of parameters and return values.
- Automatically read off default values for named parameters.
- [**Help** feature](#generate-a-help-command-for-you-package) for your package. 
- [Docstring tests](#docstring-tests). 


The [guide][guide] fully describes the usage of this module and defines the format for the docstrings. 

## Usage

Using `tidy` is as simple as writing some docstrings and calling:
```typ
#import "@preview/tidy:0.3.0"

#let docs = tidy.parse-module(read("my-module.typ"))
#tidy.show-module(docs, style: tidy.styles.default)
```

The available predefined styles are currenty `tidy.styles.default` and `tidy.styles.minimal`. Custom styles can be added by hand (take a look at the [guide][guide]). 

## Example

A full example on how to use this module for your own package (maybe even consisting of multiple files) can be found at [examples](https://github.com/Mc-Zen/tidy/tree/main/examples).

```typ
/// This function computes the cardinal sine, $sinc(x)=sin(x)/x$. 
///
/// #example(`#sinc(0)`, mode: "markup")
///
/// - x (int, float): The argument for the cardinal sine function. 
/// -> float
#let sinc(x) = if x == 0 {1} else {calc.sin(x) / x}
```

**tidy** turns this into:

<h3 align="center">
  <img alt="Tidy example output" src="docs/images/sincx-docs.svg" style="max-width: 100%; padding: 10px 10px; box-shadow: 1pt 1pt 10pt 0pt #AAAAAA; border-radius: 4pt; box-sizing: border-box; background: white">
</h3>


## Access user-defined functions and images

The code in the docstrings is evaluated via `eval()`. In order to access user-defined functions and images, you can make use of the `scope` argument of `tidy.parse-module()`:

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
The docstrings in `my-module.typ` may now access the image with `#img` and can call any function or variable from `my-module` in the style of `#my-module.my-function()`. This makes rendering examples right in the docstrings as easy as a breeze!

## Generate a help command for you package
With **tidy**, you can add a help command to you package that allows users to obtain the documentation of a specific definition or parameter right in the document. This is similar to CLI-style help commands. If you have already written docstrings for your package, it is quite low-effort to add this feature. Once set up, the end-user can use it like this:

```typ
// happily coding, but how do I use this one complex function again?

#mypackage.help("func")
#mypackage.help("func(param1)") // print only parameter description of param1
```

This will print the documentation of `func` directly into the document — no need to look it up in a manual. Read up in the [guide][guide] for setup instructions. 

## Docstring tests
It is possible to add simple docstring tests — assertions that will be run when the documentation is generated. This is useful if you want to keep small tests and documentation in one place. 
```typ
/// #test(
///   `num.my-square(2) == 4`,
///   `num.my-square(4) == 16`,
/// )
#let my-square(n) = n * n
```
With the short-hand syntax, a unfulfilled assertion will even print the line number of the failed test:
```typ
/// >>> my-square(2) == 4
/// >>> my-square(4) == 16
#let my-square(n) = n * n
```
A few test assertion functions are available to improve readability, simplicity, and error messages. Currently, these are `eq(a, b)` for equality tests, `ne(a, b)` for inequality tests and `approx(a, b, eps: 1e-10)` for floating point comparisons. These assertion helper functions are always available within docstring tests (with both `test()` and `>>>` syntax). 


## Changelog

### v0.3.0
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
  - Add executable examples to docstrings. 
  - Documentation for variables (as well as functions). 
  - Docstring tests. 
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

Initial Release.

[guide]: https://github.com/Mc-Zen/tidy/releases/download/v0.3.0/tidy-guide.pdf