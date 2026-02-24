# The `tally` Package

The tally package automatically lists all todos in a document and highlights them.

## Usage

```typst
#import "@preview/tally:0.1.1": tally, todo-list
#set text(font: "Barlow")
#show: tally.with(color: red)

#todo-list

= Introduction
#lorem(10)

TODO: Create introduction
```

Output:

![image](https://github.com/user-attachments/assets/bbe787ea-11c7-402f-9e54-b207499f5e00)
