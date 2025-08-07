# Contributing to the package or template

You can simply fork this repo and work on it on your own. Feel free to PR if this repo is still active !

If you plan to distribute your version of the package, please make sure you pay respect to [Typst packages guidelines](https://github.com/typst/packages?tab=readme-ov-file#submission-guidelines).

## Pushing to Typst packages

Check out [Typst packages repo](https://github.com/typst/packages) to learn more about packages release pipeline.

I personally suggest the following steps :

- fork the Typst packages repo
- in the root directory, for every `x.y.z` version (if the `main` branch currently contains the `x.y.z` release) :

    ```bash
    git subtree add --prefix=packages/preview/monash-university-report/x.y.z git@github.com:eric/typst-report-monash.git main
    ```

    You may need to pull sometimes (if the release wasn't fully ready) :

    ```bash
    git subtree pull --prefix=packages/preview/monash-university-report/x.y.z git@github.com:eric/typst-report-monash.git main
    ```

- PR your fork to publish the package.

You do not need to squash the commit history at anytime because Typst packages will do it on merge.
