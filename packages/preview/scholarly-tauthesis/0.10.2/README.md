# Tampere University Thesis Template

This is a TAU thesis template written in the  [`typst`][typst]
typesetting language, a potential successor to LaTeΧ. The
version of typst used to test this template is
[`0.13.0`][v0.13.0].

## Using the template on typst.app

This template is also available on [Typst Universe] as
[`scholarly-tauthesis`][tau-template-page]. Simply create an account on
<https://typst.app/> and start a new `scholarly-tauthesis` project by clicking
on **Start from template** and searching for **scholarly-tauthesis**.


If you have initialized your project with an older stable version of this
template and wish to upgrade to a newer release, the simplest way to do it is
to change the value of `$VERSION` ≥ `0.9.0` in the import statements
```typst
#import "@preview/scholarly-tauthesis:$VERSION" as tauthesis
```
to correspond to a newer released version. Alternatively, you could download
the `tauthesis.typ` file from the [thesis template repository][template-repo], and
upload it into you project on <https://typst.app/>. Then use
```typst
#import "path/to/tauthesis.typ" as tauthesis
```
instead of
```typst
#import "@preview/scholarly-tauthesis:$VERSION" as tauthesis
```
to import the `tauthesis` module.

### Note

Versions of this template before 0.9.0 do not actually work with typst.app due
to a packaging issue.

## Local installation

If [Typst Universe] is online, this template will be downloaded automatically
to

	$CACHEDIR/typst/packages/preview/scholarly-tauthesis/$VERSION/

when one runs the command

	typst init @preview/scholarly-tauthesis:$VERSION mythesis

Here `$VERSION` should be ≥ 0.9.0. The value `$CACHEDIR` for your OS can be
discovered from <https://docs.rs/dirs/latest/dirs/fn.cache_dir.html>.

### Manual installation

For a manual installation, download the contents of this repository via Git or
as a ZIP file from the template [tags] page, and store them in the folder

	$DATADIR/typst/packages/preview/scholarly-tauthesis/$VERSION/

so that a local installation of `typst` can discover the `tauthesis.typ` file
no matter where you are running it from. To find out the value `$DATADIR` for
your operating system, see <https://docs.rs/dirs/latest/dirs/fn.data_dir.html>.
The value `$VERSION` is the version `A.B.C` ≥ `0.9.0` of this template you wish
to use.

### Initializing a local copy of the project

Once the package has been installed either automatically or manually, the command

	typst init @preview/scholarly-tauthesis:$VERSION mythesis

creates a folder `mythesis` with the template files in place. Simply make the
`mythesis` folder you current working directory and run
```sh
typst compile main.typ
```
in the shell of your choice to compile the document from scratch.
Alternatively, type
```sh
typst watch main.typ &> typst.log &
```
to have a [`typst`][typst] process watch the file for changes and compile it
when a file is changed. Possible error messages can then be viewed by checking
the contents of the mentioned file `typst.log`.

### If all else fails…

… and these installation instructions do not work for some reason, the package
file `tauthesis.typ` can be moved next to the file `template/main.typ`, and the
import statements
```typst
#import "@preview/scholarly-tauthesis:$VERSION" as tauthesis
```
can be changed to
```typst
#import "relative/path/to/tauthesis.typ" as tauthesis
```
in all files that need to import the template package. This includes at least
`template/main.typ` but possibly other content files as well.

## Archiving the final version of your work

Before submitting your thesis to the university archives, it needs to be
converted to PDF/A format. Typst versions ≥ 0.12.0 should support the creation
of PDF/A-2b files, when run with the command
```sh
typst compile --pdf-standard a-2b template/main.typ
```
If a verification program such as [veraPDF](https://docs.verapdf.org/install/)
still complains that the file `template/main.pdf` does not conform to the
standard, the Muuntaja-service of Tampere University should be used to do the
final conversion. See the related instructions ([link][pdfa-instructions]) for
how to do it. Basically it boils down to feeding your compiled PDF document to
the converter at <https://muuntaja.tuni.fi>. **Remember to check that the
output of the converter is not corrupted, before submitting your thesis to the
archives.**


## Usage

You can either write your entire *main matter* in the
[`main.typ`](./template/main.typ) file, or more preferrably, split it into
multiple chapter-specific files and place those in the
[`contents/`](./template/content) folder, which this template tries to
demonstrate. If you choose to write your own commands (functions) in the
[`preamble.typ`](./template/preamble.typ) file, this needs to be imported at
the start of each chapter you plan to use the commands in. Sections that come
before the main matter, like the Finnish and English abstracts
([`tiivistelmä.typ`](./template/content/tiivistelmä.typ)|[`abstract.typ`](./template/content/abstract.typ))
and [`preface.typ`](./template/content/preface.typ) must *not* be removed from
the [`contents`](./template/content) folder, as the automation supposes that
they are located there.

You should probably *not* modify the file [`tauthesis.typ`](./tauthesis.typ), unless there is a bug
that needs fixing right now, and not when the maintainer of this project manages to find the time to
do it.

## Contributing

Issues may be created in the issue tracker on the [template GitLab
repository][template-repo], if one has a GitLab account. Merge requests may
also be performed after GitLab account creation, and forking the project. See
GitLab's documentation on this to find out how to do it ([link][forking]).


## License

This project itself uses the MIT license. See the [LICENSE](./LICENSE) file for details.

<!-- Links -->

[Typst Universe]: https://typst.app/universe
[forking]: https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html
[pdfa-instructions]: https://libguides.tuni.fi/opinnaytteet/pdfa
[tags]: https://gitlab.com/tuni-official/thesis-templates/tau-typst-thesis-template/-/tags
[tau-template-page]: https://typst.app/universe/package/scholarly-tauthesis
[template-repo]: https://gitlab.com/tuni-official/thesis-templates/tau-typst-thesis-template
[typst]: https://github.com/typst/typst
[v0.13.0]: https://github.com/typst/typst/releases/tag/v0.13.0
