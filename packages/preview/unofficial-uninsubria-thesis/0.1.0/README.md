# Tesi uninsubria

DISCLAIMER: the template was forked from https://github.com/roland-KA/clean-dhbw-typst-template. there may be some inaccuracies in the docs and source.

A (modernized) [Typst](https://typst.app/) template for documents like Bachelor theses, project documentation etc. 

You can see an example of how the template looks in this [PDF file](https://github.com/sbOogway/uninsubria-thesis/blob/main/template/main.pdf).

## Introduction and Motivation

In my experience as an end-user (i.e. reader) of documents like Bachelor theses and similar works which are currently produced at DHBW, there is room for improvement with respect to their usability.  There exists a recommendation at DHBW on how to structure and design such documents. I have the impression that some of the usability issues I identified are rooted directly within these recommendations, but others stem from the fact that some recommendations are just not thoroughly followed.

In order to give an example on how an improved document structure and layout could look like, I have created the present "*Clean DHBW Typst Template*". In the meantime it is the official Typst template for Computer Science at DHBW Karlsruhe. But of course anyone interested is welcome to use it too.

Of course such a concept is always a bit biased in some way. Therefore I explain the whys and hows below and I'm looking forward to the discussions it will provoke 😃. The name has been chosen in the sense "clean" is used in Software Engineering in terms like *clean architecture* or *clean code*, where it describes concepts and structures which are easy to understand, to use und to maintain. Furthermore they have a clear separation of concerns and responsibilities – for the case at hand that means: the template defines the typography, whereas the author is responsible for the contents.

There exists already a Typst template for these sorts of documents: It's the ["supercharged-dhbw"-template](https://github.com/DannySeidel/typst-dhbw-template) by Danny Seidel. It is a great piece of work with a lot of functionality covering a broad variety of use cases. But with respect to structure and layout, it implements exactly the above criticized state (which is without doubt what many people want or maybe have to use). I discussed with Danny on how to realize further development. We agreed to keep `supercharged-dhbw` more or less as-is in order to reflect current state and needs and in consequence to build this new template as a fork of his work. This gave me also  more freedom to go new ways.


## Usage

You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `tesi-uninsubria`.

Alternatively (if you use Typst on your local computer), you can use the CLI to kick this project off using the command

```shell
typst init @preview/uninsubria-thesis MyFancyThesis
```

Typst will create a new directory (`MyFancyThesis` in this example) with all the files needed to get you started.

## Support

If you have questions, find bugs or have proposals for new features regarding the template or if you want to contribute, please create an issue in the [GitHub-repo](https://github.com/sbOogway/uninsubria-thesis?tab=readme-ov-file).

For more general questions with respect to Typst, please consult the [Typst documentation](https://typst.app/docs/), the [Typst book](https://sitandr.github.io/typst-examples-book/book/about.html) or use the [Typst forum](https://forum.typst.app/), where you find a helpful and responsive community.

## Fonts

This template uses the following fonts (from Google fonts):

- [Source Serif 4](https://fonts.google.com/specimen/Source+Serif+4)
- [Source Sans 3](https://fonts.google.com/specimen/Source+Sans+3)

If you want to use typst locally, you can download the fonts from the links above and install them on your system (_Hint_: You need the TTF-files located within the `static` subfolders of both font-distributions). Otherwise, when using the web version, add the fonts to your project.

For further information on how to add fonts to your project, please refer to the [Typst documentation](https://typst.app/docs/reference/text/text/#parameters-font).

[**Source Serif 4**](https://fonts.google.com/specimen/Source+Serif+4) (formerly known as *Source Serif Pro*) has been chosen for the **body text** as it is a high-quality font especially made for on-screen use and the reading of larger quantities of text. It was designed in 2014 by [Frank Grießhammer](https://fonts.adobe.com/designers/frank-griesshammer) for Adobe as a companion to *Source Sans Pro*, thus expanding their selection of Open Source fonts. It belongs to the category of transitional style fonts. Its relatively large x-height is typical for on-screen fonts and adds to the legibility even at small sizes. The font ist constantly being further developed. In the meantime there are special variants available e.g. for small print (*Source Serif Caption*, *Source Serif Small Text*) or large titles (*Source Serif Display*) and headings (*Source Serif Headings*). For people with a Computer Science background, the font might be familiar as it is used for the online documentation of the Rust programming language.

For the **headlines** as well as for **other guiding elements** of the document, the font [**Source Sans 3**](https://fonts.google.com/specimen/Source+Sans+3) has been chosen. It comes as a natural choice since *Source Serif 4* has been especially designed for this combination. But it has its virtues of its own, e.g. its reduced run length which permits more characters per line. This helps to avoid line-breaks within headings in our use case. *Source Sans 3* (originally named *Source Sans Pro*) has been designed by [Paul D. Hunt](https://blog.typekit.com/2013/11/20/interview-paul-hunt/) in 2012 as Adobes first Open Source font. It has its roots in the family of Gothic fonts thus belonging to a different category than *Source Serif 4*. But under [Robert Slimbachs](https://de.wikipedia.org/wiki/Robert_Slimbach) supervision, both designers succeeded to create a combination that fits well and at the same time the different rootings make the pairing not too "boring".

## Packages Used

This template uses the following packages:

- [codelst](https://typst.app/universe/package/codelst): To create code snippets
- [hydra](https://github.com/tingerrr/hydra): To display the current heading within the header.
- [glossarium](https://github.com/typst-community/glossarium): For the glossary of the document.


The logo is property of Universita degli studi dell'Insubria. Use it only if you have consent. Typst is not responsible for any misuse.
