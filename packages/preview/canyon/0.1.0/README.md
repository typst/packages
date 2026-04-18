# Canyon: A Book Template That Puts You in Full Control

Mainstream typst templates are written so as to bring functionality and to be used in an
`#import` then `#show`  workflow; however, that frequently comes at the cost of introducing (i)
new syntax and (ii) opaque template-side code and settings.

Canyon (`canyon-0.1.0`) explores a different approach in which a new canyon-based document is a
book _stencil_ that users can freely edit and adapt, with:

- _No_ opaque template-side code or settings;
- _No_ canyon `#import` statements;
- _No_ canyon-specialized `#show` rules;
- _Full access_ to the entire typst project;
- The _familiar typst syntax_ to work with; and
- Full _separation of concepts_ for (i) metadata, (ii) configuration, (iii) elements, (iv)
  layout, and (v) contents.

Therefore, canyon users have access to _all_ document settings as if they had manually started
writing the document from scratch on their own—except they hadn't!—and thus have _full access to
everything typst_ in that project.

## Overview

Out-of-the-box canyon books come with the following:

1. (i) Front-matter; (ii) Body; and (iii) Back-matter book structure;
1. (i) Cover page, and (ii) numbered Chapter page images;
1. All `#set` and `#show` rules are accessible; hence, customizable;
1. The "openright" chapter pagination—through `#pagebreak(to: "odd")`;
1. Front-matter with Title pages; Credits; Contents; List of Figures, Tables, Equations, and
   Exhibits; and a Preface;
1. Book body with regular Chapters (single Part);
1. Back-matter with Appendix, Bibliography, Glossary, Index, and Discalimers;
1. Figures, Tables, Exhibits, Problems, and Equations are Chapter-numbered: `1.1` instead of
   `1`, with configurable separators by type _group_, i.e., a separate one for:  (i) Equations,
   (ii) Figures and Tables, (iii) Exhibits, and (iv) Problems;
1. A simple and configurable 3-color system with: (i) a thematic color (default: _dark indigo_),
   (ii) a page background color (default: _light sepia_), and (iii) a cover text color (default:
   _dark indigo_).

A _selection_ of canyon book pages using default settings are grouped in the thumbnail below:

![Selection of canyon pages thumbnail](https://raw.githubusercontent.com/cnaak/canyon.typ/refs/heads/dev/thumbnail.png)

## Suggested Canyon Workflows

Owing to its full customization and separation of concepts approach, canyon enables simple
book-writing workflows, which can be as basic as:

### The Basic (i) Metadata and (v) Contents

*Workflow:*

- Quickly editing `SETUP/META.typ` for document _metadata_;
- Replacing the image placeholders on `SETUP/ELEMENTS.typ` with your actual cover/chapter art `RES/<images>`;
- Being up and running for book content `2-BODY/<chapters>` creation and adaptation.

The end-result will look like the thumbnail with your artwork, metadata, and contents.

### Including General (ii) Configuration

*Workflow:*

- Basic workflow with:
- Quickly setting general document _configurations_ on `SETUP/CONFIG.typ`;
- Editing `__setup.typ` files in the `1-FRONT`, `2-BODY`, and `3-BACK` template stencil
  directories to finely control how these broad book sections components are displayed.

The end-result will have custom language/paper/sections/text size/fonts and broad color scheme.

### Including Fine-Grained (iii) Element and (iv) Layout Customizations:

*Workflow:*

- General configuration workflow with:
- Editing `SETUP/ELEMENTS.typ` for fine-grained element _customizations_ such as: (i) the set of
  typst native `page`, `par`, `text`, and `block` elements; and (ii) custom `canyon` elemens,
  such as: `exhibit` (for code listings, examples, etc.), and `problem` (for textbooks); or even
  (iii) creating your own custom element types;

The end-result can be a highly customized book, than can bear little resemblance to the default
canyon book style, hopefully achieved without too much pain.

## Release Summary

- `0.1.0` - initial release

## Citing

This package can be cited with the following bibliography database entry:

```yml
canyon-package:
  type: web
  author: Naaktgeboren, C.
  title: "Canyon: A Book Template That Puts You in Full Control"
  url: https://github.com/cnaak/canyon.typ
  version: 0.1.0
  date: 2026-04-17
```

