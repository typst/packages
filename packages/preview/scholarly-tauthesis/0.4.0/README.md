# Tampere University Thesis Template

This is a TAU thesis template written in the  [`typst`][typst]
typesetting language, a potential successor to LaTeΧ. The
version of typst used to test this template is
[`0.11.0`][v0.11.0].

## Local installation

To install this template locally, download this repository via
Git or as a ZIP file from the [tags] page. Then, make a symbolic
link

	$DATADIR/typst/packages/preview/scholarly-tauthesis/$VERSION/ -> /path/to/root/of/tauthesis/

so that a local installation of `typst` can discover the
`tauthesis.typ` file no matter where you are running it from. To
find out the value `$DATADIR` for your operating system, see
<https://docs.rs/dirs/latest/dirs/fn.data_dir.html>. The value
`$VERSION` is the version `A.B.C` ≥ `0.4.0` of this template you
wish to use.

If [Typst Universe] is online and this package has been approved
there by the service maintainers, this template will be
downloaded automatically to

	$CACHEDIR/typst/packages/preview/scholarly-tauthesis/$VERSION/

The value `$CACHEDIR` for your OS can be discovered from
<https://docs.rs/dirs/latest/dirs/fn.cache_dir.html>.

[tags]: https://gitlab.com/tuni-official/thesis-templates/tau-typst-thesis-template/-/tags
[Typst Universe]: https://typst.app/universe

Once the package has been installed, the command

	typst init @preview/scholarly-tauthesis:$VERSION

creates a folder `tauthesis` with the template files in place.
Simply make the `tauthesis` folder you current working directory
and run repository and run
```sh
typst compile main.typ
```
in the shell of your choice to compile the document from scratch.
Alternatively, type
```sh
typst watch main.typ &> typst.log &
```
to have a [`typst`][typst] process watch the file for changes and
compile it when a file is changed. Possible error messages can
then be viewed by checking the contents of the mentioned file
`typst.log`.

This template can also be uploaded to the typst online editor at
<https://typst.app/>. However, the file paths related to the
`tauthesis` file will need to be changed if this is done
manually. See the tutorial at <https://typst.app/docs/tutorial/>
to learn the basics of the language. Some examples are also given
in the template itself.

[typst]: https://github.com/typst/typst
[v0.11.0]: https://github.com/typst/typst/releases/tag/v0.11.0

## Using the template on typst.app

This is very easy, once the typst maintainers have approved the
`scholarly-tauthesis` package into the [Typst Universe] service.
Simply create an account on <https://typst.app/> and start a new
`tauthesis` project by clicking on **Start from template →
scholarly-tauthesis**.

## Archiving the final version of your work

Before submitting your thesis to the university archives, it needs to be converted to PDF/A format.
See the related instructions ([link][pdfa-instructions]) for how to do it. Basically it boils down
to feeding your compiled PDF document to the converter <https://muuntaja.tuni.fi>. **Remember to
check that the output of the converter is not corrupted, before submitting your thesis to the
archives.**

[pdfa-instructions]: https://libguides.tuni.fi/opinnaytteet/pdfa

## Usage

You can either write your entire *main matter* in the [`main.typ`](./main.typ) file, or more
preferrably, split it into multiple chapter-specific files and place those in the
[`contents/`](./content) folder, which this template tries to demonstrate. If you choose to write
your own commands (functions) in the [`preamble.typ`](./preamble.typ) file, this needs to be
imported at the start of each chapter you plan to use the commands in. Sections that come before the
main matter, like the Finnish and English abstracts
([`tiivistelmä.typ`](./content/tiivistelmä.typ)|[`abstract.typ`](./content/abstract.typ)) and
[`preface.typ`](./content/preface.typ) must *not* be removed from the [`contents`](./content)
folder, as the automation supposes that they are located there.

You should probably *not* modify the file [`tauthesis.typ`](./tauthesis.typ), unless there is a bug
that needs fixing right now, and not when the maintainer of this project manages to find the time to
do it.

## Contributing

Issues may be created in the issue tracker of this GitLab repository, if one has a GitLab account.
Merge requests may also be performed after GitLab account creation, and forking the project. See
GitLab's documentation on this to find out how to do it [link][forking].

[forking]: https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html

## License

This project itself uses the MIT license. See the [LICENSE](./LICENSE) file for details.
