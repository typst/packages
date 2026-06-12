# Compiling the examples

We provide two (complete) examples of presentations written in Typst. One is for a lecture in Linear Algebra, and the other is for a presetation in Probability and Statistics.

As this template was developed initially for Linear Algebra, and then extended to other subjects in Mathematics, we decided to initialize a presentation using the Linear Algebra example.

## Compiling the Probability and Statistics example

- Open a terminal
- Change directories to the unzipped downloaded package
- Change directories to the Probability and Statistics example:
    ```bash
    cd examples/ProbStats
    ```
- Compile the file with
    ```bash
    typst compile "ProbStats.typ"
    ```
    This will generate the PDF `ProbStats.pdf`.

## Final Notes

The method for compiling the Probability and Statistics example can also be used to compile the Linear Algebra example. 

### IMPORTANT

If you installed the package locally, then change `preview` by `local` in the `typ` file. 