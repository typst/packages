#import "../lib/pages/dependencies.typ": *
#show: codly-init
= Features

This chapter is just here to show you how to import several files into the `main.typ`. If you did not see it yet, the `main.typ` file is the entry point of your document. It is the file that you will render to create your final document. The `main.typ` file imports all other files and includes them in the final document. The importing of files is done using the `#include` command. The `#include` command takes a file path as an argument and includes the file in the document. You can also use the `#import` command to import files, but this is not necessary in this case. The `#import` command is used to import files that are not part of the main document, such as libraries or templates.

== Code Highlighting

You might have noticed that the code snippets in this document are highlighted. This is done using the `codly` package. 
In order for the code snippets you provide to be highlighted, you need to wrap them into a `#figure` command. This is because the template targets figures from type `raw` for the code listing.
Mainly because then you can give them a caption, tag them and they will be automatically included in the list of code listings (which is automatically generated and updated when you add or remove code listings from your document).
However you will have to set the `supplement` for this `figure` to "Source code" in order for the template to know that this is a code listing and not a figure.
#figure(
  supplement: "Source code",
```rust
fn main() {
    println!("Hello World!");
}
```,
caption: "Hello World program in Rust")<HelloWorld>


