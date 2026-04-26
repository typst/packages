# simple-research-poster

`simple-research-poster` is a simple Typst template for university research posters.
To get started, run

```sh
typst init @preview/simple-research-poster:0.2.0
```

and you should see this:

<a href="https://github.com/aneziac/simple-research-poster/blob/2dab6d622ea191e3eda77ac713041340e22b239a/template/poster.typ">
    <img src="./thumbnail.svg" width="100%" alt="A three column, blue Futurama-themed research poster, with lorem ipsum text.">
</a>

The default file tree is simple: `poster.typ` handles the layout, `sections.typ` handles the actual poster content, and `colors.typ` handles the color styling.
The template is designed to be as generic as possible, so that it supports arbitrary paper size, arbitrary columns, landscape/portrait orientations, etc.
[Open an issue on Github](https://github.com/aneziac/simple-research-poster) if you have any feature requests.

## Example

This template is a generalization of our code for the poster below:

<a href="https://github.com/aneziac/simple-research-poster/tree/2dab6d622ea191e3eda77ac713041340e22b239a/examples/coxeter-groups">
    <img src="./examples/coxeter-groups/poster.svg" width="100%" alt="A three column, green poster on Coxeter Groups and Buildings.">
</a>

Click the image above to see the code.
Note the diagrams are all rendered natively in Typst, via CeTZ.
