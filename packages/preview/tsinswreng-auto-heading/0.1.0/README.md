# tsinswreng-auto-heading

A Typst package that provides automatic heading level management.

## Overview

`tsinswreng-auto-heading` provides a simple way to create nested headings without manually tracking heading levels. The `auto-heading` function automatically increments and decrements the heading level as you enter and exit sections.

## Usage

```typst
#import "@preview/tsinswreng-auto-heading:0.1.0": auto-heading

#let H = auto-heading

#H("Chapter 1")[
  This is the content of chapter 1.
  
  #H("Section 1.1")[
    This is section 1.1 content.
    
    #H("Subsection 1.1.1")[
      This is a subsection.
    ]
  ]
  
  #H("Section 1.2")[
    This is section 1.2.
  ]
]
```

## How It Works

The `auto-heading(title, content)` function:
1. Increments the heading level counter
2. Creates a heading at the appropriate level
3. Renders the content
4. Decrements the heading level counter when done

This allows you to nest sections naturally without worrying about the absolute heading level numbers.

## License

MIT License