# Start a presentation from an existing example

With this package we provide two examples. One example is in Linear Algebra, and one example is in Probability and Statistics.

One could copy-paste the example and [compile it individually](compiling_examples.md). However, we provide the Linear Algebra Example as a "template example". This means that [once the package is installed](Installation.md), we can create presentations starting from the Linear Algebra template.

## Initializing tudelft-PRIME-presentation with the Linear Algebra template

- Open a terminal
- Change directories to were you want to start your presentation. In our case (in Linux or MacOS) we chose
    ```bash
    mkdir -p ~/temp/typst
    cd ~/temp/typst
    ```
- Initialize a presentation with our example:
    ```bash
    typst init @preview/tudelft-PRIME-presentation:0.1.2
    ```
    This creates a new directory called `tudelft-PRIME-presentation`.

- Enter the directory and compile the presentation:
    ```bash
    cd tudelft-PRIME-presentation
    typst compile "Linear Algebra Lecture 5.typ"
    ```
    This will generate a PDF called "Linear Algebra Lecture 5.pdf"

Now you can use the `Linear Algebra Lecture 5.typ` as a template for your presentation. You are free to rename and edit it as you need.

