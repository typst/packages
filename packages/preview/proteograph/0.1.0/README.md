# proteograph

proteomics data visualization in Typst


**Table of Contents**

- [Introduction](#introduction)
- [Documentation](#documentation)
- [Local Packages](#local-packages)
- [License](#license)



## Introduction

The ProteoGraph package for Typst is a plotting library for proteomics based on [Lilaq](https://lilaq.org/).
It currently defines functions to display MS2 annotated fragmentation spectra and eXtracted Ion Current (XIC).

## Documentation

Here [proteograph-docs](docs/proteograph-docs.pdf) you have the reference documentation that describes the functions and parameters used in this package. (_Generated with [tidy](https://github.com/Mc-Zen/tidy)_)


## Local Packages

This package is under heavy development, currently only available as _*local-packages*_.

You can read the documentation about typst [local-packages](https://github.com/typst/packages#local-packages) and learn about the path folders used in differents operating systems (Linux / MacOS / Windows).

In Linux you can do:

```sh
git clone https://codeberg.org/olangella/proteograph ~/.local/share/typst/packages/local/proteograph/0.0.1
```

And import the package in your file:

```typ
#import "@local/proteograph:0.0.1": *
```


## License
[GPLv3 License](./LICENSE)
