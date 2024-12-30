# Building notes 
How to to build locally and deploy to Typst app and Typst templates.

## Image quantization
To reduce the size of images, which is nice for reducing the template size.

```bash
pngquant *.png --ext .png --force
```

## Integration to the official repos

- Create symlink to this repository from `~/.cache/typst/packages` to `git/packages/packages/preview`. For this : 
    ```bash
    ln -s ~/git/modern-isc-report ~/.cache/typst/packages/preview/isc-hei-report/0.1.5
    ```

    This prevents the download of packages and uses the local versions of this package.

- For local testing and development, once the step above has been done, you can simply build from the `template` directory using `typst watch report.typ`

- Additional testing can be conducted to see if the template instance works correctly with 

    ```bash
    typst init @preview/isc-hei-report:0.1.5
    ```

- Copy the content of this repos to the `typst-template` repository using 

    ```bash
    cp * -R ~/git/packages/packages/preview/isc-hei-report/0.1.5/
    ```

- Create PR as usual.


