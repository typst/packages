# minifig

A really simple implementation of subfigures for typst

![](example.png)

## Usage

1. Import the package
    ```typst
    #import "@preview/minifig:0.1.0": *
    ```
2. Use the show rule
    ```typst
    #show: minifig
    ```
3. Make subfigures
    ```typst
    #subfigures(caption: [An example], sfigure(fig1), sfigure(fig2))
    ```

Docs for the specific functions are in [docs.pdf](docs.pdf)
