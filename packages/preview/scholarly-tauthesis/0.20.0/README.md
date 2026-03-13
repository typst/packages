# Tampere University Thesis Template

This is a TAU thesis template written in the
[`typst`][typst] typesetting language, a potential
successor to LaTeΧ. The version of Typst used to test
this template is [`0.14.0`][v0.14.0].  See the [Typst
tutorial](https://typst.app/docs/tutorial/) for basic
instructions on how Typst is used.

## Using the template on typst.app

This template is also available on [Typst Universe]
as [`scholarly-tauthesis`][tau-template-page]. Simply
create an account on <https://typst.app/> and start a new
`scholarly-tauthesis` project by clicking on **Start from
template** and searching for **scholarly-tauthesis**.

If you have initialized your project with an older stable
version of this template and wish to upgrade to a newer
release, the simplest way to do it is to change the value
of `$VERSION` ≥ `0.9.0` in the import statements
```typst
#import "@preview/scholarly-tauthesis:$VERSION" as tauthesis
```
to correspond to a newer released version. Alternatively,
you could download the `tauthesis.typ` file from the
[thesis template repository][template-repo], and upload it
into your project on <https://typst.app/>. Then use
```typst
#import "path/to/tauthesis.typ" as tauthesis
```
instead of
```typst
#import "@preview/scholarly-tauthesis:$VERSION" as tauthesis
```
to import the `tauthesis` module.

### Note

Versions of this template before 0.9.0 do not actually work
with typst.app due to a packaging issue.

## Local installation

If [Typst Universe] is online, this template will be
downloaded automatically to
```text
$CACHEDIR/typst/packages/preview/scholarly-tauthesis/$VERSION/
```
when one runs the command
```sh
typst init @preview/scholarly-tauthesis:$VERSION mythesis
```
Here `$VERSION` should be ≥ 0.9.0. The value
`$CACHEDIR` for your OS can be discovered from
<https://docs.rs/dirs/latest/dirs/fn.cache_dir.html>.

### Manual installation

For a manual installation, download the contents of this
repository via Git or as a ZIP file from the template
[tags] page, and store them in the folder
```text
$DATADIR/typst/packages/preview/scholarly-tauthesis/$VERSION/
```
so that a local installation of `typst` can
discover the `tauthesis.typ` file no matter
where you are running it from. To find out the
value `$DATADIR` for your operating system, see
<https://docs.rs/dirs/latest/dirs/fn.data_dir.html>. The
value `$VERSION` is the version `A.B.C` ≥ `0.9.0` of this
template you wish to use.

### Initializing a local copy of the project

Once the package has been installed either automatically or
manually, the command
```sh
typst init @preview/scholarly-tauthesis:$VERSION mythesis
```
creates a folder `mythesis` with the template files in
place. Simply make the `mythesis` folder you current
working directory and run
```sh
typst compile template/main.typ --pdf-standard ua-1
```
in the shell of your choice to compile the document from
scratch. Alternatively, type
```sh
typst watch template/main.typ --pdf-standard ua-1
```
to have a [`typst`][typst] process watch the file for
changes and compile it when a file is changed.

### If all else fails…

… and these installation instructions do not work for some
reason, the package file `tauthesis.typ` can be moved next
to the file `template/main.typ`, and the import statements
```typst
#import "@preview/scholarly-tauthesis:$VERSION" as tauthesis
```
can be changed to
```typst
#import "relative/path/to/tauthesis.typ" as tauthesis
```
in all files that need to import the template package. This
includes at least `template/main.typ` but possibly other
content files as well.

## On the choice of fonts

As of 2025-04-16 the Typst packaging ecosystem has yet to
figure out a best way of distributing template-specific
fonts and other binary-format resources that a template
might rely on. The packaging system currently relies on a
[Git repository](https://github.com/typst/packages), which
means that it is not practical to include the fonts that
Tampere University recommends along with this template.

You should therefore download and install the (static)
OpenType (`.otf`) or TrueType (`.ttf`) versions of the
recommended fonts onto your system, if they are not
already installed. If you want to write your thesis on
[typst.app], it should be enough to upload the required
(static versions) of the `.ttf` or `.otf` font files into
the project there, if they are not already available on
the service.

The current font recommendation is as follows:

- Normal text: [Roboto](https://fonts.google.com/specimen/Roboto),

- Mathematics: [STIX Two Math](https://github.com/stipub/stixfonts/releases) and

- Raw text or code: [Fira Mono](https://fonts.google.com/?query=Fira+Mono).

These are all openly licensed, meaning they should be
accessible for all major operating systems. They also
support the font features, such as small capital letters
and bold text, that are required by this thesis template.

## Archiving the final version of your work

Before submitting your thesis to the university archives,
it needs to be converted to an _accessible_ PDF format.
Typst versions ≥ 0.14.0 should support the creation of
PDF/UA-1 files, when run with the command
```sh
typst compile --pdf-standard ua-1 template/main.typ
```
This should work, by itself, if you do not
include PDF files as images into your document,
or forget to add alternative texts to your images
and equations. To include vector graphics, use
SVG files instead. See the [Typst accessibility
guide](https://typst.app/docs/guides/accessibility/
) for details.

Once you are getting ready to submit your thesis,
check that it fulfills basic accessibility requirements
by running the thesis file through the program
[veraPDF](https://docs.verapdf.org/install/) with
the PDF/UA-1 profile. Profile selection should happen
automatically, if the file was generated with the correct
PDF standard flag of the Typst compiler.

If the program complains that the file `template/main.pdf`
does not conform to the standard, the Muuntaja-service of
Tampere University could be used to do the final conversion
to a weaker PDF/A  standard. See the related instructions
([link][pdfa-instructions]) for how to do it. Basically
it boils down to feeding your compiled PDF document to
the converter at <https://muuntaja.tuni.fi>. **Remember to
check that the output of the converter is not corrupted,
before submitting your thesis to the archives.** Also note
that the converter might strip tags from your document,
making in unaccessible.

In addition to using veraPDF to perform basic PDF/UA-1
conformance checks, you should also have a quick look at
the accessibility tags generated by Typst. This can be done
on the service [showtags](https://texlive.net/showtags)
provided by the helpful people of The LaTeX
Project. On Microsoft Windows®︎, the program
[PAC]("https://pac.pdf-accessibility.org") is also
available. You do not have to go through the entire tag
tree, as it is mainly meant for screen reader consumption,
but it is a good idea to look up alternative texts of
images and equations (`Formula` elements) and check that
they seem sensible.

Once the output of both veraPDF and showtags (or
PAC) seems acceptable, you may submit your thesis to
[Trepo](https://trepo.tuni.fi/).

**Note:** if you are unable to produce an accessible
version of your thesis according to these PDF accessibility
checkers, you should attach the source code of the thesis
in a sensible reading order to the Trepo submission!
This template shows examples of embedding the source code
into the PDF file itself, but note that a separate [ZIP
archive](https://en.wikipedia.org/wiki/ZIP_(file_format))
is the best format for the source code submission.
Visually impaired people might not be able to extract the
attachments from a PDF file, but a separate ZIP archive can
be opened easily on any system.

## Usage

Start out by filling in the thesis metadata into the file
[`metadata.typ`](./template/metadata.typ). Once this is in
place, you may start writing the content of your thesis.

*Front matter* contents are written into the files in
the folder [`frontmatter/`](./template/frontmatter/).
These include the thesis abstracts, preface, glossary and
artificial intelliegence disclaimer page contents.

You can either write your entire *main matter* in the
[`mainmatter/index.typ`](./template/mainmatter/index.typ)
file, or more preferrably, split it into multiple
chapter-specific files, place those in the
[`mainmatter/`](./template/mainmatter) folder and include
them into the index file, which this template tries to
demonstrate. Appendices may be included into the file
[`appendices/index.typ`](./template/appendices/index.typ)
as their own chapters.

*Appendices* are added into the folder
[`appendices/`](./template/appendices). They can
all be written as separate chapters into the file
[appendices/index.typ](./template/appendices/index.typ),
or included into the index file as the index file currently
demonstrates.

You can write your own commands (functions) in the
[`preamble.typ`](./template/preamble.typ) file. This needs
to be imported at the start of each chapter you plan to use
the commands in.

You should probably *not* modify the file
[`tauthesis.typ`](./tauthesis.typ), unless there is a bug
that needs fixing right now, and not when the maintainer of
this project manages to find the time to do it.

## Contributing

Issues may be created in the issue tracker on the [template
GitLab repository][template-repo], if one has a GitLab
account. Merge requests may also be performed after
GitLab account creation, and forking the project. See
GitLab's documentation on this to find out how to do it
([link][forking]).


## License

This project itself uses the MIT license. See the
[LICENSE](./LICENSE) file for details.

<!-- Links -->

[typst.app]: https://typst.app/
[Typst Universe]: https://typst.app/universe
[forking]: https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html
[pdfa-instructions]: https://libguides.tuni.fi/opinnaytteet/pdfa
[tags]: https://gitlab.com/tuni-official/thesis-templates/tau-typst-thesis-template/-/tags
[tau-template-page]: https://typst.app/universe/package/scholarly-tauthesis
[template-repo]: https://gitlab.com/tuni-official/thesis-templates/tau-typst-thesis-template
[typst]: https://github.com/typst/typst
[v0.14.0]: https://github.com/typst/typst/releases/tag/v0.14.0
