# Numblex

How to number the heading like this?

- Appendix A. XXXX
  - A.1. YYY
  - A.2. ZZZ

Or this?

- 一、话题
  - 1\. 论点
    - (1) 证据

You might use a function:

```Typst
#set heading(numbering: (..nums) => {
  if nums.pos().len() == 1 {
    return "Appendix " + numbering("A.", ..nums)
  }
  return numbering("A.1.", ..nums)
}
```

Or set up a couple of `set` rules:

```Typst
#set heading(numbering: "A.1.")
#show heading.where(level: 1): set heading(numbering: (n) => "Appendix " + numbering("A.", n))
// No, you can't use "Appendix A." since Typst would treat the first "A" as a numbering
```

Or simply use Numblex:

```Typst
#import "@preview/numblex:0.2.0": numblex

#set heading(numbering: numblex("{Appendix [A].:d==1;[A].}{[1].}"))
```

## Usage

```typst
#import "@preview/numblex:0.2.0": numblex

#set heading(numbering: numblex("{Section [A].:d==1;[A].}{[1].}{[1])}"))

```

You can read the [Manual](https://github.com/ParaN3xus/numblex/blob/main/manual.pdf) for more information.
