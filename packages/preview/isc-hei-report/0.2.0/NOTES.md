# Building notes 
How to to build locally and deploy to Typst app and Typst templates. Since v0.2.0, it is now based on [`justbuild`](https://github.com/just-buildsystem/justbuild)

## Image quantization
To reduce the size of images, which is nice for reducing the template size.

```bash
pngquant *.png --ext .png --force
```

## Integration to the official repos

- Create symlink to this repository from `~/.cache/typst/packages` to `git/packages/packages/preview`. For this : 
    ```bash
    ln -s ~/git/isc-hei-report ~/.cache/typst/packages/preview/isc-hei-report/1.0.0
    ```

    This prevents the download of packages and uses the local versions of this package.

- For local testing and development, once the step above has been done, you can simply build from the `template` directory using `typst watch report.typ`

- Additional testing can be conducted to see if the template instance works correctly with 

    ```bash
    typst init @preview/isc-hei-report:1.0.0
    ```

- Copy the content of this repos to the `typst-template` repository using 

    ```bash
    cp * -R ~/git/packages/packages/preview/isc-hei-report/1.0.0/
    ```

- Do not forget to add a proper `.gitignore` to remove all PDFs

- Lint for kebab-case only

- Create PR as usual.


