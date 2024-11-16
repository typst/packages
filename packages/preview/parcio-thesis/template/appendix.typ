#counter(heading).update(0)
#heading(numbering: "A.", supplement: "Appendix")[Appendix]<appendix>

#figure(
  caption: "Caption", 
  numbering: n => numbering("A.1", counter(heading).get().first(), n))[
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