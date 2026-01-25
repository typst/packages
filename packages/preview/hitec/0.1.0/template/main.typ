// #import "@preview/hitec:0.1.0": *
#import "../src/lib.typ": *

#let (
  // Metadata
  title,
  author,
  company,
  confidential,
  date,
  double-sided,
  print,
  // Layouts
  doc,
  title-page,
  title-block,
) = documentclass(
  title: [The HITEC template],
  author: "Brian Li",
  company: [The Company, Ltd],
  confidential: [#sym.bar.h Unlimited Distribution #sym.bar.h],
  date: datetime.today(),
  double-sided: true, // Enable double-sided printing
  print: true, // Add margins to binding side for printing
)

#show: doc

#title-block() // Title block without page break
// Use this instead if you want a separate title page
// #title-page()[/* Optional cover footnote */]

= The General Idea

This short paper is a demonstration of what documents written with this class look like.

The template is a Typst adaptation of the classic #link("https://ctan.org/pkg/hitec")[LaTeX HITEC class]. As the original author points out, most available templates _smell too academic_ for industrial technical documents. This template aims to provide a clean and simple layout for technical documents in the hi-tech industry.

The year is no longer 2001. Typst, as a newcomer in the typesetting world, is quite friendly to package maintainers, not to mention the powerful coding assistance that LLMs provide. Therefore, this template is expected to be more maintainable and extensible than its LaTeX counterpart.

= Hitec vs Hitec

This template achieves the same functions and layout style as the original LaTeX HITEC class and amends a few details to better suit modern technical documents. Here are some of the differences:

- *Simplified title block and title page commands.* Instead of adding `titlepage` as an argument when calling `documentclass`, as in the original LaTeX class, this template implements both features as functions that you can call as needed.
- *Supports multiple authors.* You can now add multiple authors by passing an array of strings to the `author` argument. Just don't squeeze an army into it, the header will look messy.
- *Updated default fonts.* The default fonts are updated to `TeX Gyre Heros` for the main text, whereas the original LaTeX class uses `Helvetica`. This change is made because only the former is available in the web app. The difference is minor anyway.
- *More versatility provided by Typst.* The date format in the title is customizable. You can also customize other layout styles by using the `#set` or `#show` commands. Look them up in the documentation. The possibilities are endless.

= Layout

The layout of the document starts with setting up the `documentclass`, which defines the metadata and layout styles. The layout styles are then applied by calling the `#show: doc` command. Any custom layout styles should be added after that command, or they might be overwritten.

== Page Size

The template uses `A4` as its page size; you can specify a different #link("https://typst.app/docs/reference/layout/page#parameters-paper")[paper size string] using:

```typst
#set page(paper: "us-letter")
```

== Title

The title block (without a page break) and title page can be added by calling the `#title-block()` and `#title-page()` functions, respectively.

The date format in the title is customizable via the `date-format` argument. The format string uses the same syntax as the `datetime.display()` function.
```typst
#title-block(
  date-format: "[day] [month repr:short] [year]",
)
```

== Margins

The template uses two sets of margins for ordinary text and for headings, thanks to the `wideblock` function provided by the `marginalia` package. The ordinary text has a larger binding margin to allow for hole punching, whereas the headings have equal margins on both sides to maintain symmetry. You can customize the even/odd margins by setting the `double-sided` argument in the `documentclass` function, or disable double-sided layout by setting the `print` argument to `false`.

Notes or figures can be placed in the binding margin. However, it requires the user to manually import the `marginalia` package, and be aware that the experience is unstable and elements might not appear correctly.

= Summary

The rework of this template is only a small step toward inheriting the rich legacy of the LaTeX package ecosystem. I genuinely hope that Typst will grow into a mature typesetting system with a vibrant community.
