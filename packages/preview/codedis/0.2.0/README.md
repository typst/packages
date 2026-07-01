# CODEDIS - Simple CODE DISplay for Typst

Used to display code files in Typst. Main feature is that it displays code blocks over multiple pages in a way that implies the code block continues onto the next page. Also a simple and intuitive syntax for displaying code blocks.

Usage:

```typ
// IMPORT PACKAGE
#import "@preview/codedis:0.2.0": code

// READ IN CODE
#let codeblock-1 = read("some_code.py")
#let codeblock-2 = read("some_code.cpp")

#set page(numbering: "1")
#v(80%)

// DEFAULT LANGUAGE IS Python ("py")
#code(codeblock-1)
#code(codeblock-2, lang: "cpp")
```

Renders to: 

![image](https://github.com/AugustinWinther/codedis/assets/30674646/76bb13d5-adc8-457f-bd55-53e3fd5c5df7)


It is very basic and limited, but it does what I need it too, and hope that it may be of help to others. I'm most likely not going to develop it further than this.

