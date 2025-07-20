#import "@preview/parcio-thesis:0.2.1": appendix

#appendix(reset: true, label: <appendix>)[Appendix]

#figure(
  caption: "Caption", 
  numbering: n => numbering("A.1", counter(heading).get().first(), n)
)[
  ```c
  printf("Hello World!\n");

  // Comment
  for (int i = 0; i < m; i++) {
    for (int j = 0; j < n; j++) {
      sum += 'a';
    }
  }
  ```
]
