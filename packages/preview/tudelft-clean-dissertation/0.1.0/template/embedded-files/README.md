# Files to Embed in the PDF

In order to provide a robust way to include external files in the main document, files can be directly embedded into the pdf. A compatible PDF viewer is able to then list and extract those files. A person viewing the pdf can then, for example, download a `.csv` file from the pdf and use that for processing.

This is more robust than a link to a remote network location (as these tend to eventually suffer from link rot and require an active network connection). 

Embedding files is also a more flexible way than simply grouping the files with the pdf in an archive file, as this can be harder to distribute. 

The only downside is that it is not as robust or interoperable when compared to a traditional archive. Decide for yourself if a file would make more sense to be embedded in the pdf, or provided as a separate file alongside the pdf. 

To include a file as an attachment, consult the [Typst `attach` documentation](https://typst.app/docs/reference/pdf/attach/).

### Including small git repositories

If you manage your scripts or designs with git, you can easily embed the whole repository instead of just the final files. To do so, you can use the `git bundle` command to turn a repository into a single, cloneable, file. 

Generating a bundle file 

```bash
# produces an output file called '<repo-name>.bundle'
git bundle create <repo-name>.bundle --all
```

and cloning this back to a normal repository is done simply with

```bash
# will clone into folder called <repo-name> 
git clone <path/to/<repo-name>.bundle
```

