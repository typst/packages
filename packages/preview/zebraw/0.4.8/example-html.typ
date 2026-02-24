// Since we have imported the `html-template` module and `zebraw-html` has been defined in the scope of the module, we can use it here without an explicit import.
// The `zebraw-html` function is used to highlight the code block in the example below, but in HTML.
// #import "/src/lib.typ": zebraw-html

#import "assets/html-template.typ": *
#show: html-example


#exp(````typ
#zebraw-html(
  highlight-lines: (
    (3, [to avoid negative numbers]),
    (9, "50 => 12586269025"),
  ),
  lang: true,
  block-width: 100%,
  line-width: 100%,
  wrap: false,
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
#zebraw-html(
  highlight-lines: (
    (3, [to avoid negative numbers]),
    (9, "50 => 12586269025"),
  ),
  lang: true,
  block-width: 100%,
  line-width: 100%,
  wrap: true,
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
#zebraw-html(
  highlight-lines: (
    (3, [to avoid negative numbers]),
    (9, "50 => 12586269025"),
  ),
  numbering: false,
  lang: true,
  block-width: 100%,
  line-width: 100%,
  wrap: true,
  ```typst
  = Fibonacci Reccursive Function
  
  This function calculates the Fibonacci number at the given index using a recursive approach.
  ```,
)
````)
