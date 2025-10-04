
# FIIT Thesis Template with Typst

Status: finished 🎉

---

This is a Typst template for writing bachelor's thesis and diploma at the
Faculty of Informatics and Information Technologies (FIIT) in Slovak Technical
University in Bratislava (STU). The template was crafted using the for the
[official requirements and conditions, as of May 2025](https://www.fiit.stuba.sk/studium/bakalarsky-projekt/bp.html?page_id=1862)
provided by the faculty, with [this LaTeX template](https://www.overleaf.com/latex/templates/stu-fiit-bachelor-thesis-template-slovak-university-of-technology/pppyykvvhqgq) being the basis for how the document looks.

The template is available in these languages: **Slovak** (sk), **English** (en)

Theses that already use this template:

- [Extending a RISC-V processor with bit instructions, Kirill Putiatin](https://opac.crzp.sk/?fn=detailBiblioForm&sid=BBB70232DB8D19E5F026BDDCF3EF)
- [Development of an Adverse Media Screening System using Face Recognition via Existing APIs, Illia Chaban](https://opac.crzp.sk/?fn=detailBiblioForm&sid=BBB70232DB8D19E5F027B5DCF3EF)

# Showcase

Here's a quick look on different template **styles**. You can choose any one of
these styles, it's up to your personal preference. The previews are just for
visual clarity, they are going to be slightly different from the final
documents.

| `legacy` | `regular` | `compact` |
| ------------- | -------------- | -------------- |
| ![Legacy style of the template, resized to an A6 paper sheet.](/build/legacy1.png) ![Legacy style of the template, resized to an A6 paper sheet.](/build/legacy2.png) | ![Legacy style of the template, resized to an A6 paper sheet.](/build/regular1.png) ![Legacy style of the template, resized to an A6 paper sheet.](/build/regular2.png) | ![Legacy style of the template, resized to an A6 paper sheet.](/build/compact1.png) ![Legacy style of the template, resized to an A6 paper sheet.](/build/compact2.png) |

# Usage

You can use [Typst's online editor](https://typst.app/) to edit and display
your thesis. [Sign up](https://typst.app/signup), sign in and click "Start from
template". Search for "fiit-thesis" and start writing!

## Building your thesis locally

1. [Install Typst](https://github.com/typst/typst?tab=readme-ov-file#installation).
If you're on Linux, it should be pretty easy.

2. Next, initialize the template using:

```bash
typst init @preview/fiit-thesis
```

3. Start watching the changes of your thesis using:
```bash
typst watch main.typ --watch
```

4. Begin writing your thesis!

If you're new to Typst, we recommend to start reading the [Typst
tutorial](https://typst.app/docs/tutorial/).

Don't forget to intialize a Git repository and backup your work somewhere!

## Cheatsheet

| Option | Type | Example/Default | Description | Possible values |
| ------------- | -------------- | -------------- | -------------- | -------------- |
| title | `str` | `"Moja záverečná práca"` | thesis title | |
| thesis | enum (`str`) | `"bp2"` | type of your thesis | `"bp1"`, `"bp2"`, `"dp1"`, `"dp2"`, `"dp3"` |
| author | `str` | `"Jožko Mrkvička"` | your name | |
| supervisor | `str` or `array` of `str` | `"prof. Jozef Mrkva, PhD."` | your supervisor | `str` if you have one supervisor, `array` if many |
| abstract | `dict` | `( sk: lorem(150), en: lorem(150) )` | abstract in two languages | keys are the language, with `str` as values |
| id | `str` | `"FIIT-12345-123456"` | id from AIS | |
| lang | enum(`str`) | `"en"` | language of your thesis | `"sk"`, `"en"` |
| acknowledgment | `str` | `"Omitted"` | thanks at the start of the thesis | |
| assignment | path | `none` | recommended to leave as default, see "How to insert the thesis assignment?" | |
| tables-outline | `bool` | `false` | enable tables outline | |
| figures-outline | `bool` | `false` | enable figures outline | |
| abbreviations-outline | `array` | `( ("SSL", "Secure socket layer"), ... )` | list of abbreviations, if you need one | |
| disable-cover | `bool` | `false` | disable cover page (the first one) | |
| style | enum (`str`) | `regular` | select style of the document | `"regular"`, `"legacy"`, `"compact"`, `"pagecount"`, `"legacy-noncompliant"` |

## Template

The template supports general customization options. First, you should choose
the language that you are writing this paper in using `lang` argument.
Currently supported languages are listed at the top of this page. If you choose
an unsupported language, the template will generate a compile error.

Next, you should insert general info for your thesis: `title`, `author`, `id`,
`supervisor`. They are pretty straight-forward, so just write the correct data
into them. `id` is your thesis ID number from the informational system.
`supervisor` supports two options: either one supervisor's name as a string,
or an array of pairs, where each pair contains position of the supervisor and
their name. With the second option, you can add multiple supervisors, but
please make sure that you write the positions in the language of the rest of
the thesis.

`thesis` selects the type of your work. The allowed values are: `bp1`, `bp2`,
`dp1`, `dp2`, `dp3`. These values control what text is displayed on the title
and cover pages. Sometimes, you might get an error while upgrading your thesis
to the final stage. Pay attention to those errors, as they tell you how exactly
your work should be structured.

`abstract` is a dictionary of the translated abstracts that you provide with
your work. The keys are the language identifiers, like the `lang` argument.
The values are the abstract text. `en` and `sk` keys are required for thesis
to compile. The template shows an example of how the dictionaries are created
in Typst.

`acknowledgment` sets the acknowledgment text. You can write anything you want
here.

`assignment` sets the assignment PDF file path. This isn't the ideal way to
insert your assignment from AIS, see "How to insert the thesis assignment?"

`table-outline` is a boolean, set it to true to enable list of tables.

`figures-outline` enables list of figures (pictures).

`abbreviations-outline` is an array of pairs, where each pair contains an
abbreviation and its explanation. If you leave this argument as default or
explicitly empty, the list of abbreviations will not show.

`disable-cover` lets you disable the first (cover) page of the thesis. That's
it.

`style` selects the style of the document. The style affects mostly cosmetic
parameters. Here are the possible options:

- `regular`: the default, inspired by the LaTeX template, embraces the digital format
- `legacy`: fully devoted to imitating the old LaTeX template, virtually no differences
- `compact`: tighter layout with less empty space wasted, useful if your thesis is long
- `pagecount`: apply this one to estimate how many pages of pure text you got
- `legacy-noncompliant`: **don't use this one.** It uses the same citation standard (IEEE) that the old LaTeX template used, but it is not approved by FIIT STU

## Appendices

To style the appendices correctly, you need to use a simple `show` rule with a
special function: `section-appendices`. Every heading you put after this will
be considered an appendix and numbered accordingly. You can add nested headings
as usual, they will be numbered and labeled correctly.

```typst
#show: section-appendices.with()
```

To reference the appendix, just use regular Typst referencing. The word
"Appendix" will be inserted automatically with regard to your language of
choice.

## Resumé

The resumé chapter is a chapter that is needed only when you write your thesis
in a language other from Slovak. There is a special function for that:
`resume`. Here's how to use it:

```typst
#resume()[
  #lorem(250) // any resume content should go here
]
```

## Assertions

This template has integrated a few useful assertions that will help you to
remember important points about your thesis. For example, if you forget to
write a resumé and your language is set to English, the assertion will refuse
all compilation attempts. This particular assertion is set only for BP2/DP3.

The assertion will give you a helpful error message. If for some reason, you
think an assertion is wrong, please open an issue in our GitHub repository.

## How to hand in the thesis?

To hand in the thesis, it needs to be separated into two parts, and your thesis
assignment needs to be inserted into the final PDF.

### How to separate the thesis?

The file needs to be separated into the main part, and the appendices part.
You can use external tools for that, or settle for Typst compiler arguments.
The `--pages` argument to the CLI compiler can be used to specify which pages
should be rendered for the output. In the examples, we use page 29 as the first
appendix page.

Here's an example how to split just your main part:

```bash
typst compile --pages=1-28 main.typ BP_JozkoMrkvicka.pdf
```

And your appendices part:

```bash
typst compile --pages=29- main.typ BP_prilohy_JozkoMrkvicka.pdf
```

### How to insert the thesis assignment?

You might notice the warning page in the thesis right after you load the
template. This page can be removed by specifying an assignment file path. Typst
doesn't support inserting PDFs into documents, but package `muchpdf` partially
solves this issue. However, due to how it works (renders the PDF into an SVG),
**we cannot recommend using this option.** This rendering erases text data from
the PDF, and automated AIS tools most likely rely on those.

To get rid of the warning page, use external tools like `pdfarrange` (GUI) and
`pdftk` (CLI).

# Developing

To develop the template, you should install [Task](https://taskfile.dev/). Here
are the tasks that you can run:

- `push`: run this before pushing
- `build`: compile the template example
- `watch`: watch the template example
- `open`: open the template example in your system default viewer
- `thumbnail`: compile the template thumbnail
- `install-local`: install the package into @local namespace
- `uninstall-local`: uninstall the package from @local namespace
- `install-preview`: install the package into @preview namespace
- `uninstall-preview`: uninstall the package from @preview namespace

If you want to help, you can take a look at the GitHub issues in the template
repository. If anything goes wrong, feel free to open a new issue or contact
me directly.

# Contact

If you have any questions, feel free to contact me: [Sasetz](https://github.com/sasetz/)

