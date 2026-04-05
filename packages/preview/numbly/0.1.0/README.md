# numbly

A package that helps you to specify different numbering formats for different levels of headings.

Suppose you want to specify the following numbering format for your document:

- Appendix A. Guide
  - A.1. Installation
    - Step 1. Download
    - Step 2. Install
  - A.2. Usage

You might use `if` to achieve this:

```typst
#set heading(numbering: (..nums) => {
  nums = nums.pos()
  if nums.len() == 1 {
    return "Appendix " + numbering("A.", ..nums)
  } else if nums.len() == 2 {
    return numbering("A.1.", ..nums)
  } else {
    return "Step " + numbering("1.", nums.last())
  }
})

= Guide
== Installation
=== Download
=== Install
== Usage
```

But with `numbly`, you can do this more easily:

```typst
#import "@preview/numbly:0.1.0": numbly
#set heading(numbering: numbly(
  "Appendix {1:A}.", // use {level:format} to specify the format
  "{1:A}.{2}.", // if format is not specified, arabic numbers will be used
  "Step {3}.", // here, we only want the 3rd level
))
```
