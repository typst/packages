# Typst glossary

> Glossarium is based in great part of the work of [Sébastien d'Herbais de Thun](https://github.com/Dherse) from his master thesis available at: <https://github.com/Dherse/masterproef>. His glossary is available under the MIT license [here](https://github.com/Dherse/masterproef/blob/main/elems/acronyms.typ).

Glossarium is a simple, easily customizable typst glossary inspired by [LaTeX glossaries package](https://www.ctan.org/pkg/glossaries) . You can see various examples showcasing the different features in the `examples` folder.

![Screenshot](.github/example.png)

## Manual 

### Import and setup

This manual assume you have a good enough understanding of typst markup and scripting. 

For Typst 0.6.0 or later import the package from the typst preview repository:

```typ
#import "@preview/glossarium:0.4.0": make-glossary, print-glossary, gls, glspl 
```

For Typst before 0.6.0 or to use **glossarium** as a local module, download the package files into your project folder and import `glossarium.typ`:

```typ
#import "glossarium.typ": make-glossary, print-glossary, gls, glspl 
```

After importing the package and before making any calls to `gls`,` print-glossary` or `glspl`, please ***MAKE SURE*** you add this line
```typ
#show: make-glossary
```

> *WHY DO WE NEED THAT ?* : In order to be able to create references to the terms in your glossary using typst ref syntax `@key` glossarium needs to setup some [show rules](https://typst.app/docs/tutorial/advanced-styling/) before any references exist. This is due to the way typst works, there is no workaround.
>
>Therefore I recommend that you always put the `#show: ...` statement on the line just below the `#import` statement.


### Printing the glossary

First we have to define the terms. 
A term is a [dictionary](https://typst.app/docs/reference/types/dictionary/) composed of 2 required and 2 optional elements: 

- `key` (string) *required, case-sensitive, unique*: used to reference the term.
- `short` (string) *required*: the short form of the term replacing the term citation. 
- `long` (string or content) *optional*: The long form of the term, displayed in the glossary and on the first citation of the term. 
- `desc` (string or content) *optional*: The description of the term.
- `plural` (string or content) *optional*: The pluralized short form of the term. 
- `longplural` (string or content) *optional*: The pluralized long form of the term. 
- `group` (string) *optional, case-sensitive*: The group the term belongs to. The terms are displayed by groups in the glossary.

Then the terms are passed as a list to `print-glossary`

```typ
#print-glossary(
    (
    // minimal term
    (key: "kuleuven", short: "KU Leuven"),
    
    // a term with a long form and a group
    (key: "unamur", short: "UNamur", long: "Namur University", group: "Universities"),

    // a term with a markup description
    (
      key: "oidc", 
      short: "OIDC", 
      long: "OpenID Connect", 
      desc: [OpenID is an open standard and decentralized authentication protocol promoted by the non-profit
      #link("https://en.wikipedia.org/wiki/OpenID#OpenID_Foundation")[OpenID Foundation].],
      group: "Accronyms",
    ),

    // a term with a short plural 
    (
      key: "potato",
      short: "potato",
      // "plural" will be used when "short" should be pluralized
      plural: "potatoes",
      desc: [#lorem(10)],
    ),

    // a term with a long plural 
    (
      key: "dm",
      short: "DM",
      long: "diagonal matrix",
      // "longplural" will be used when "long" should be pluralized
      longplural: "diagonal matrices",
      desc: "Probably some math stuff idk",
    ),
  )
)
```

By default, the terms that are not referenced in the document are not shown in the glossary, you can force their appearance by setting the `show-all` argument to true.

You can also disable the back-references by setting the parameter `disable-back-references` to `true`.

Group page breaks can be enable by setting the parameter `enable-group-pagebreak` to `true`.

You can call this function from anywhere in you document.


### Referencing terms.

Referencing terms is done using the key of the terms using the `gls` function or the reference syntax.

```typ
// referencing the OIDC term using gls
#gls("oidc")
// displaying the long form forcibly
#gls("oidc", long: true)

// referencing the OIDC term using the reference syntax
@oidc
```

#### Handling plurals

You can use the `glspl` function and the references supplements to pluralize terms.
The `plural` key will be used when `short` should be pluralized and `longplural` will be used when `long` should be pluralized. If the `plural` key is missing then glossarium will add an 's' at the end of the short form as a fallback.

```typ
#glspl("potato")
```

Please look at the examples regarding plurals.

#### Overriding the text shown

You can also override the text displayed by setting the `display` argument.

```typ
#gls("oidc", display: "whatever you want") 
```

## Final tips

I recommend setting a show rule for the links to that your readers understand that they can click on the references to go to the term in the glossary.

```typ
#show link: set text(fill: blue.darken(60%))
// links are now blue ! 
```

## Changelog

### 0.4.0

- Support for plurals has been implemented, showcased in [examples/plural-example/main.typ](examples/plural-example). Contributed by [@St0wy](https://github.com/St0wy). 
- The behavior of the gls and glspl functions has been altered regarding calls on undefined glossary keys. They now cause panics. Contributed by [@St0wy](https://github.com/St0wy). 

### 0.3.0

- Introducing support for grouping terms in the glossary. Use the optional and case-sensitive key `group` to assign terms to specific groups. The appearanceof the glossary can be customized with the new parameter `enable-group-pagebreak`, allowing users to insert page breaks between groups for better organization. Contributed by [indicatelovelace](https://github.com/indicatelovelace).

### 0.2.6

#### Added

- A new boolean parameter `disable-back-references` has been introduced. If set to true, it disable the back-references (the page number at the end of the description of each term). Please note that disabling back-references only disables the display of the page number, if you don't have any references to your glossary terms, they won't show up unless the parameter `show-all` has been set to true.

### 0.2.5

#### Fixed

- Fixed a bug where there was 2 space after a reference. Contributed by [@drupol](https://github.com/drupol)

### 0.2.4

#### Fixed

- Fixed a bug where the reference would a long ref even when "long" was set to false. Contributed by [@dscso](https://github.com/dscso) 

#### Changed

- The glossary appearance have been improved slightlyby. Contributed by [@JuliDi](https://github.com/JuliDi)

### Previous versions did not have a changelog entry
