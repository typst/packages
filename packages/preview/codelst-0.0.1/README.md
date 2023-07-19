# codelst (v0.0.1)

**codelst** is a [Typst](https://github.com/typst/typst) package for rendering sourcecode with line numbers and some other additions.

## Usage

For Typst 0.6.0 or later simply import the package from the typst preview repository:

```typst
#import "@preview/codelst:0.0.1": sourcecode
```

For Typst before 0.6.0 or to use **codelst** as a local module, download the package files into your project folder and import `codelst.typ`:

```typst
#import "codelst.typ": sourcecode
```

After importing the package, simple wrap any fenced code block in a call to `#sourcecode()`:

````typst
#import "@preview/codelst:0.0.1": sourcecode

#sourcecode[```typc
#show "ArtosFlow": name => box[
  #box(image(
    "logo.svg",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]
````

See `example.typ` for usage examples.

