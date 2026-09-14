# CODEDIS - Simple CODE DISplay for Typst

Used to display code files in Typst. Main feature is that it displays code 
blocks over multiple pages in a way that implies the code block continues onto 
the next page. Also a simple and intuitive syntax for displaying code blocks.

Example usage:

```typ
// IMPORT PACKAGE
#import "@preview/codedis:0.3.0": code

// READ IN CODE
#let codeblock-1 = read("some_code.py")
#let codeblock-2 = read("some_long_code.cpp")

#set page(numbering:"1")
#v(80%)

// DEFAULT LANGUAGE IS Python ("py")
#code(codeblock-1)
#code(codeblock-2, lang:"cpp", line-numbers: true, lines:(37, 45))
```

Renders to: 

![image](https://raw.githubusercontent.com/AugustinWinther/codedis/main/example.png)




