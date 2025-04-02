#{
// render_code
context zebraw(
  highlight-lines: (
    (3, [to avoid negative numbers]),
    (9, "50 => 12586269025"),
  ),
  lang: true,
  header: "Calculate Fibonacci number using reccursive function",
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
}