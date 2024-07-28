# Contributing to the package or template

You can simply fork this repo and work on it on your own. Feel free to PR if this repo is still active !

If you plan to distribute your version of the package, please make sure you pay respect to both [Typst packages guidelines](https://github.com/typst/packages?tab=readme-ov-file#submission-guidelines) and [École polytechnique corporate identity](https://www.polytechnique.edu/presse/kit-media).

## Pushing to Typst packages

Check out [Typst packages repo](https://github.com/typst/packages) to learn more about packages release pipeline.

I personally suggest the following steps :

- fork the Typst packages repo
- in `packages/preview/polytechnique-reports`, for every `x.y.z` version (if the `main` branch currently contains the `x.y.z` release):

    ```bash
    git subtree pull --prefix=x.y.z git@github.com:remigerme/typst-polytechnique.git main
    ```

- PR your fork to publish the package
