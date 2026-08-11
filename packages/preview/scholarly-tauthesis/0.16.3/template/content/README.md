# content/

This is where you should add typst text files related to the actual content of
your thesis. Note that when you want to include images, code or typst code from
other files in here, any import paths need to be relative to the file itself.
For example, to include all of the code from the
[`preamble.typ`](../preamble.typ) file in the `template/` folder, the import
statement needs to be
```typst
#import "../preamble.typ": *
```
This is different when compared to most LaTeΧ compilers, where import paths are
relative to the `main` file.
