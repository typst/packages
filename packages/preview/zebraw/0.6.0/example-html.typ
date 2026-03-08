// Since we have imported the `html-template` module and `zebraw-html` has been defined in the scope of the module, we can use it here without an explicit import.
// The `zebraw-html` function is used to highlight the code block in the example below, but in HTML.
// #import "/src/lib.typ": zebraw-html

#import "assets/html-template.typ": *
#show: html-example


#exp(````typ
#zebraw(
  highlight-lines: (
    (3, [to avoid negative numbers]),
    (9, "50 => 12586269025"),
  ),
  lang: true,
  block-width: 100%,
  numbering-separator: true,
  wrap: false,
  indentation: 4,
  ```rust
  pub fn fibonacci_reccursive(n: i32) -> u64 {
      if n < 0 {
          panic!("{} is negative!", n);
      }
      match n {
          0 => panic!("zero is not a right argument to fibonacci_reccursive()!"), 0 => panic!("zero is not a right argument to fibonacci_reccursive()!"),
          1 | 2 => 1,
          3 => 2,
          _ => fibonacci_reccursive(n - 1) + fibonacci_reccursive(n - 2),
      }
  }
  ```,
)
````)

#exp(````typ
#zebraw(
  highlight-lines: (
    (3, [to avoid negative numbers]),
    (9, "50 => 12586269025"),
  ),
  lang: true,
  block-width: 100%,
  wrap: true,
  numbering-offset: 300,
  indentation: 4,
  ```rust
  pub fn fibonacci_reccursive(n: i32) -> u64 {
      if n < 0 {
          panic!("{} is negative!", n);
      }
      match n {
          0 => panic!("zero is not a right argument to fibonacci_reccursive()!"),
          1 | 2 => 1,
          3 => 2,
          _ => fibonacci_reccursive(n - 1) + fibonacci_reccursive(n - 2),
      }
  }
  ```,
)
````)

#exp(````typ
#zebraw(
  highlight-lines: (
    (3, [to avoid negative numbers]),
    (9, "50 => 12586269025"),
  ),
  // numbering: false,
  lang: true,
  block-width: 100%,
  wrap: true,
  numbering-separator: true,
  indentation: 4,
  header: [Test],
  ```typst
  = Fibonacci Reccursive Function

  This function calculates the Fibonacci number at the given index using a recursive approach.
  ```,
)
````)

#exp(````typ
#zebraw(
  lang: false,
  highlight-lines: (
    (1, rgb("#edb4b0").lighten(50%)),
    (2, rgb("#a4c9a6").lighten(50%)),
  ),
  ```python
  - device = "cuda"
  + device = accelerator.device
    model.to(device)
  ```,
)
````)
